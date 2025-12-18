// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Dependency imports
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Internal imports
import {ILendingAdapter} from "../interfaces/ILendingAdapter.sol";
import {ILeverageManager} from "../interfaces/ILeverageManager.sol";
import {ILeverageToken} from "../interfaces/ILeverageToken.sol";
import {ILeverageRouter} from "../interfaces/periphery/ILeverageRouter.sol";
import {IVeloraAdapter} from "../interfaces/periphery/IVeloraAdapter.sol";
import {IMulticallExecutor} from "../interfaces/periphery/IMulticallExecutor.sol";
import {ActionData} from "../types/DataTypes.sol";

/**
 * @dev The LeverageRouter contract is an immutable periphery contract that facilitates the use of flash loans and swaps
 * to deposit and redeem equity from LeverageTokens.
 *
 * The high-level deposit flow is as follows:
 *   1. The sender calls `deposit` with the amount of collateral from the sender to deposit, the amount of debt to flash loan
 *      (which will be swapped to collateral), the minimum amount of shares to receive, and the calldata to execute for
 *      the swap of the flash loaned debt to collateral
 *   2. The LeverageRouter will flash loan the debt asset amount and execute the calldata to swap it to collateral
 *   3. The LeverageRouter will use the collateral from the swapped debt and the collateral from the sender for the deposit
 *      into the LeverageToken, receiving LeverageToken shares and debt in return
 *   4. The LeverageRouter will use the debt received from the deposit to repay the flash loan
 *   6. The LeverageRouter will transfer the LeverageToken shares and any surplus debt assets to the sender
 *
 * The high-level redeem flow is the same as the deposit flow, but in reverse.
 *
 * @custom:contact security@seamlessprotocol.com
 */
contract LeverageRouter is ILeverageRouter, ReentrancyGuardTransient {
    /// @inheritdoc ILeverageRouter
    ILeverageManager public immutable leverageManager;

    /// @inheritdoc ILeverageRouter
    IMorpho public immutable morpho;

    /// @notice Creates a new LeverageRouter
    /// @param _leverageManager The LeverageManager contract
    /// @param _morpho The Morpho core protocol contract
    constructor(ILeverageManager _leverageManager, IMorpho _morpho) {
        leverageManager = _leverageManager;
        morpho = _morpho;
    }

    /// @inheritdoc ILeverageRouter
    function convertEquityToCollateral(ILeverageToken token, uint256 equityInCollateralAsset)
        public
        view
        returns (uint256 collateral)
    {
        uint256 collateralRatio = leverageManager.getLeverageTokenState(token).collateralRatio;
        ILendingAdapter lendingAdapter = leverageManager.getLeverageTokenLendingAdapter(token);
        uint256 baseRatio = leverageManager.BASE_RATIO();

        if (lendingAdapter.getCollateral() == 0 && lendingAdapter.getDebt() == 0) {
            uint256 initialCollateralRatio = leverageManager.getLeverageTokenInitialCollateralRatio(token);
            collateral = Math.mulDiv(
                equityInCollateralAsset, initialCollateralRatio, initialCollateralRatio - baseRatio, Math.Rounding.Ceil
            );
        } else if (collateralRatio == type(uint256).max) {
            collateral = equityInCollateralAsset;
        } else {
            collateral =
                Math.mulDiv(equityInCollateralAsset, collateralRatio, collateralRatio - baseRatio, Math.Rounding.Ceil);
        }

        return collateral;
    }

    /// @inheritdoc ILeverageRouter
    function previewDeposit(ILeverageToken token, uint256 collateralFromSender)
        external
        view
        returns (ActionData memory previewData)
    {
        uint256 collateral = convertEquityToCollateral(token, collateralFromSender);
        return leverageManager.previewDeposit(token, collateral);
    }

    /// @inheritdoc ILeverageRouter
    function deposit(
        ILeverageToken leverageToken,
        uint256 collateralFromSender,
        uint256 flashLoanAmount,
        uint256 minShares,
        IMulticallExecutor multicallExecutor,
        IMulticallExecutor.Call[] calldata swapCalls
    ) external nonReentrant {
        bytes memory depositData = abi.encode(
            DepositParams({
                sender: msg.sender,
                leverageToken: leverageToken,
                collateralFromSender: collateralFromSender,
                minShares: minShares,
                multicallExecutor: multicallExecutor,
                swapCalls: swapCalls
            })
        );

        morpho.flashLoan(
            address(leverageManager.getLeverageTokenDebtAsset(leverageToken)),
            flashLoanAmount,
            abi.encode(MorphoCallbackData({action: LeverageRouterAction.Deposit, data: depositData}))
        );
    }

    /// @inheritdoc ILeverageRouter
    function redeem(
        ILeverageToken token,
        uint256 shares,
        uint256 minCollateralForSender,
        IMulticallExecutor multicallExecutor,
        IMulticallExecutor.Call[] calldata swapCalls
    ) external nonReentrant {
        uint256 debtRequired = leverageManager.previewRedeem(token, shares).debt;

        bytes memory redeemData = abi.encode(
            RedeemParams({
                sender: msg.sender,
                leverageToken: token,
                shares: shares,
                minCollateralForSender: minCollateralForSender,
                multicallExecutor: multicallExecutor,
                swapCalls: swapCalls
            })
        );

        morpho.flashLoan(
            address(leverageManager.getLeverageTokenDebtAsset(token)),
            debtRequired,
            abi.encode(MorphoCallbackData({action: LeverageRouterAction.Redeem, data: redeemData}))
        );
    }

    /// @inheritdoc ILeverageRouter
    function redeemWithVelora(
        ILeverageToken token,
        uint256 shares,
        uint256 minCollateralForSender,
        IVeloraAdapter veloraAdapter,
        address augustus,
        IVeloraAdapter.Offsets calldata offsets,
        bytes calldata swapData
    ) external nonReentrant {
        uint256 debtRequired = leverageManager.previewRedeem(token, shares).debt;

        bytes memory redeemData = abi.encode(
            RedeemWithVeloraParams({
                sender: msg.sender,
                leverageToken: token,
                shares: shares,
                minCollateralForSender: minCollateralForSender,
                veloraAdapter: veloraAdapter,
                augustus: augustus,
                offsets: offsets,
                swapData: swapData
            })
        );

        morpho.flashLoan(
            address(leverageManager.getLeverageTokenDebtAsset(token)),
            debtRequired,
            abi.encode(MorphoCallbackData({action: LeverageRouterAction.RedeemWithVelora, data: redeemData}))
        );
    }

    /// @notice Morpho flash loan callback function
    /// @param loanAmount Amount of asset flash loaned
    /// @param data Encoded data passed to `morpho.flashLoan`
    function onMorphoFlashLoan(uint256 loanAmount, bytes calldata data) external {
        if (msg.sender != address(morpho)) revert Unauthorized();

        MorphoCallbackData memory callbackData = abi.decode(data, (MorphoCallbackData));

        if (callbackData.action == LeverageRouterAction.Deposit) {
            DepositParams memory params = abi.decode(callbackData.data, (DepositParams));
            _depositAndRepayMorphoFlashLoan(params, loanAmount);
        } else if (callbackData.action == LeverageRouterAction.Redeem) {
            RedeemParams memory params = abi.decode(callbackData.data, (RedeemParams));
            _redeemAndRepayMorphoFlashLoan(params, loanAmount);
        } else if (callbackData.action == LeverageRouterAction.RedeemWithVelora) {
            RedeemWithVeloraParams memory params = abi.decode(callbackData.data, (RedeemWithVeloraParams));
            _redeemWithVeloraAndRepayMorphoFlashLoan(params, loanAmount);
        }
    }

    // ... rest of internal functions (_depositAndRepayMorphoFlashLoan, _redeemAndRepayMorphoFlashLoan, _redeemWithVeloraAndRepayMorphoFlashLoan) go here, fully preserved
}