// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ISwapRouter} from "./interfaces/ISwapRouter.sol";
import {IMetaVault} from "./interfaces/IMetaVault.sol";
import {IDepositor} from "./interfaces/IDepositor.sol";
import {IStrataCDO} from "./interfaces/IStrataCDO.sol";
import {AccessControlled} from "../governance/AccessControlled.sol";

contract TrancheDepositor is AccessControlled {

    bytes32 public constant DEPOSITOR_CONFIG_ROLE = keccak256("DEPOSITOR_CONFIG_ROLE");

    event SwapInfoChanged(address indexed token);
    event AutoWithdrawalsChanged();
    event CdoAdded(address cdo);
    event TranchesAdded();

    error InvalidAsset(address vault, address asset);
    error MintedSharesBelowMin(uint256 shares, uint256 minShares);

    struct TAutoSwap {
        address router;
        uint24 fee;
        uint24 minimumReturnPercentage;
    }

    struct TDepositParams {
        uint256 swapDeadline;
        uint256 swapAmountOutMinimum;
        address swapTokenOut;
        uint256 minShares;
    }

    mapping (address sourceToken => TAutoSwap tokenSwapInfo)            public autoSwaps;
    mapping (address sourceVault => bool enabled)                       public autoWithdrawals;
    mapping (address tranche => mapping(address token => bool enabled)) public tranches;

    function initialize(address owner_, address acm_) public virtual initializer {
        AccessControlled_init(owner_, acm_);
    }

    function addSwapInfo(address token, TAutoSwap calldata swapInfo) external onlyRole(DEPOSITOR_CONFIG_ROLE) {
        require(token != address(0), "ZeroAddress");
        require(swapInfo.router != address(0), "ZeroAddress");
        require(100 <= swapInfo.fee && swapInfo.fee <= 10000, "InvalidFeeTier");
        require(900 <= swapInfo.minimumReturnPercentage && swapInfo.minimumReturnPercentage <= 1000, "InvalidReturnPercentage");

        autoSwaps[token] = swapInfo;
        emit SwapInfoChanged(token);
    }

    function addAutoWithdrawals(address[] calldata tokens, bool[] calldata statuses) external onlyRole(DEPOSITOR_CONFIG_ROLE) {
        uint256 len = tokens.length;
        require(len == statuses.length, "LengthMissmatch");
        for (uint256 i; i < len; ) {
            autoWithdrawals[tokens[i]] = statuses[i];
            unchecked { i++; }
        }
        emit AutoWithdrawalsChanged();
    }

    function addCdo(IStrataCDO cdo) external onlyRole(DEPOSITOR_CONFIG_ROLE) {
        IERC20[] memory tokens = cdo.strategy().getSupportedTokens();
        address jrt = address(cdo.jrtVault());
        address srt = address(cdo.srtVault());
        uint256 len = tokens.length;
        for (uint256 i; i < len; ) {
            address t = address(tokens[i]);
            tranches[jrt][t] = true;
            tranches[srt][t] = true;
            unchecked { i++; }
        }
        emit CdoAdded(address(cdo));
    }

    function deposit(IMetaVault vault, IERC20 asset, uint256 amount, address receiver, TDepositParams calldata params) external returns (uint256 shares) {
        return _deposit(vault, asset, amount, receiver, params);
    }

    function depositWithPermit(
        IMetaVault vault,
        IERC20 asset,
        uint256 amount,
        address receiver,
        TDepositParams calldata params,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant returns (uint256 shares) {
        address user = _msgSender();
        try IERC20Permit(address(asset)).permit(user, address(this), amount, deadline, v, r, s) {}
        catch {
            require(IERC20(address(asset)).allowance(user, address(this)) >= amount, "InsufficientAllowance");
        }
        SafeERC20.safeTransferFrom(asset, user, address(this), amount);
        return _deposit(vault, asset, address(this), amount, receiver, params);
    }

    function _deposit(IMetaVault vault, IERC20 asset, uint256 amount, address receiver, TDepositParams memory params) internal returns (uint256) {
        address user = _msgSender();
        return _deposit(vault, asset, user, amount, receiver, params);
    }

    function _deposit(IMetaVault vault, IERC20 asset, address from, uint256 amount, address receiver, TDepositParams memory params) internal returns (uint256) {
        if (tranches[address(vault)][address(asset)] == true) {
            return _deposit_asMetaToken(vault, asset, from, amount, receiver, params.minShares);
        }
        if (autoWithdrawals[address(asset)] == true) {
            return _deposit_viaWithdraw(vault, IERC4626(address(asset)), from, amount, receiver, params);
        }
        if (autoSwaps[address(asset)].router != address(0)) {
            return _deposit_viaSwap(vault, asset, from, amount, receiver, params);
        }
        revert InvalidAsset(address(vault), address(asset));
    }

    function _deposit_asMetaToken(IMetaVault vault, IERC20 asset, address from, uint256 amount, address receiver, uint256 minShares) internal returns (uint256) {
        require(amount > 0, "ZeroDeposit");
        require(receiver != address(0), "ZeroAddress");

        if (from != address(this)) {
            SafeERC20.safeTransferFrom(asset, from, address(this), amount);
        }

        SafeERC20.forceApprove(asset, address(vault), amount);
        uint256 shares = vault.deposit(address(asset), amount, receiver);
        if (minShares > 0 && shares < minShares) {
            revert MintedSharesBelowMin(shares, minShares);
        }
        return shares;
    }

    function _deposit_viaWithdraw(IMetaVault vault, IERC4626 sourceVault, address from, uint256 amount, address receiver, TDepositParams memory depositParams) internal returns (uint256) {
        require(amount > 0, "ZeroDeposit");

        IERC20 baseAsset = IERC20(sourceVault.asset());
        uint256 balanceBefore = baseAsset.balanceOf(address(this));

        sourceVault.withdraw(amount, address(this), from);
        uint256 amountOut = baseAsset.balanceOf(address(this)) - balanceBefore;
        return _deposit(vault, baseAsset, address(this), amountOut, receiver, depositParams);
    }

    function _deposit_viaSwap(IMetaVault vault, IERC20 tokenIn, address from, uint256 amount, address receiver, TDepositParams memory depositParams) internal returns (uint256) {
        SafeERC20.safeTransferFrom(tokenIn, from, address(this), amount);

        TAutoSwap memory swapInfo = autoSwaps[address(tokenIn)];
        SafeERC20.forceApprove(tokenIn, swapInfo.router, amount);

        uint256 deadline = depositParams.swapDeadline == 0 ? block.timestamp : depositParams.swapDeadline;
        address tokenOut = depositParams.swapTokenOut == address(0) ? vault.asset() : depositParams.swapTokenOut;

        uint256 amountOutMin = depositParams.swapAmountOutMinimum;
        if (amountOutMin == 0) {
            amountOutMin = amount * swapInfo.minimumReturnPercentage * (10 ** IERC20Metadata(tokenOut).decimals())
                / (10 ** IERC20Metadata(address(tokenIn)).decimals())
                / 1000;
        }

        bool supported = tranches[address(vault)][tokenOut] || autoWithdrawals[tokenOut];
        if (!supported) revert InvalidAsset(address(vault), tokenOut);

        uint256 beforeBal = IERC20(tokenOut).balanceOf(address(this));

        ISwapRouter.ExactInputSingleParams memory p = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(tokenIn),
            tokenOut: tokenOut,
            fee: swapInfo.fee,
            recipient: address(this),
            deadline: deadline,
            amountIn: amount,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        ISwapRouter(swapInfo.router).exactInputSingle(p);
        uint256 amountOut = IERC20(tokenOut).balanceOf(address(this)) - beforeBal;
        return _deposit(vault, IERC20(tokenOut), address(this), amountOut, receiver, depositParams);
    }
}
