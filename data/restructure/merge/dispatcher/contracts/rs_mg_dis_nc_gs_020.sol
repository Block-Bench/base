pragma solidity ^0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {AbstractAdapter} from "../AbstractAdapter.sol";
import {NotImplementedException} from "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultAdapter} from "../../interfaces/midas/IMidasRedemptionVaultAdapter.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";

import {WAD, RAY} from "@gearbox-protocol/core-v3/contracts/libraries/Constants.sol";


contract MidasRedemptionVaultAdapter is AbstractAdapter, IMidasRedemptionVaultAdapter {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant override contractType = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override version = 3_10;


    address public immutable override mToken;


    address public immutable override gateway;


    mapping(address => address) public phantomTokenToOutputToken;


    mapping(address => address) public outputTokenToPhantomToken;


    EnumerableSet.AddressSet internal _allowedTokens;


    constructor(address _creditManager, address _gateway) AbstractAdapter(_creditManager, _gateway) {
        gateway = _gateway;
        mToken = IMidasRedemptionVaultGateway(_gateway).mToken();

        _getMaskOrRevert(mToken);
    }


    function redeemInstant(address tokenOut, uint256 amountMTokenIn, uint256 minReceiveAmount)
        external
        override
        creditFacadeOnly
        returns (bool)
    {
        if (!isTokenAllowed(tokenOut)) revert TokenNotAllowedException();

        _redeemInstant(tokenOut, amountMTokenIn, minReceiveAmount);

        return false;
    }


    function redeemInstantDiff(address tokenOut, uint256 leftoverAmount, uint256 rateMinRAY)
        external
        override
        creditFacadeOnly
        returns (bool)
    {
        if (!isTokenAllowed(tokenOut)) revert TokenNotAllowedException();

        address creditAccount = _creditAccount();

        uint256 balance = IERC20(mToken).balanceOf(creditAccount);
        if (balance > leftoverAmount) {
            unchecked {
                uint256 amount = balance - leftoverAmount;
                uint256 minReceiveAmount = (amount * rateMinRAY) / RAY;
                _redeemInstant(tokenOut, amount, minReceiveAmount);
            }
        }
        return false;
    }


    function _redeemInstant(address tokenOut, uint256 amountMTokenIn, uint256 minReceiveAmount) internal {
        _executeSwapSafeApprove(
            mToken,
            abi.encodeCall(
                IMidasRedemptionVaultGateway.redeemInstant,
                (tokenOut, amountMTokenIn, _convertToE18(minReceiveAmount, tokenOut))
            )
        );
    }


    function redeemRequest(address tokenOut, uint256 amountMTokenIn)
        external
        override
        creditFacadeOnly
        returns (bool)
    {
        if (!isTokenAllowed(tokenOut) || outputTokenToPhantomToken[tokenOut] == address(0)) {
            revert TokenNotAllowedException();
        }

        _executeSwapSafeApprove(
            mToken, abi.encodeCall(IMidasRedemptionVaultGateway.requestRedeem, (tokenOut, amountMTokenIn))
        );
        return true;
    }


    function withdraw(uint256 amount) external override creditFacadeOnly returns (bool) {
        _withdraw(amount);
        return false;
    }


    function _withdraw(uint256 amount) internal {
        _execute(abi.encodeCall(IMidasRedemptionVaultGateway.withdraw, (amount)));
    }


    function withdrawPhantomToken(address token, uint256 amount) external override creditFacadeOnly returns (bool) {
        if (phantomTokenToOutputToken[token] == address(0)) revert IncorrectStakedPhantomTokenException();
        _withdraw(amount);
        return false;
    }


    function depositPhantomToken(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }


    function _convertToE18(uint256 amount, address token) internal view returns (uint256) {
        uint256 tokenUnit = 10 ** IERC20Metadata(token).decimals();
        return amount * WAD / tokenUnit;
    }


    function isTokenAllowed(address token) public view override returns (bool) {
        return _allowedTokens.contains(token);
    }


    function allowedTokens() public view override returns (address[] memory) {
        return _allowedTokens.values();
    }


    function setTokenAllowedStatusBatch(MidasAllowedTokenStatus[] calldata configs)
        external
        override
        configuratorOnly
    {
        uint256 len = configs.length;

        for (uint256 i; i < len; ++i) {
            MidasAllowedTokenStatus memory config = configs[i];

            if (config.allowed) {
                _getMaskOrRevert(config.token);
                _allowedTokens.add(config.token);

                if (config.phantomToken != address(0)) {
                    _getMaskOrRevert(config.phantomToken);
                    phantomTokenToOutputToken[config.phantomToken] = config.token;
                    outputTokenToPhantomToken[config.token] = config.phantomToken;
                }
            } else {
                _allowedTokens.remove(config.token);

                address phantomToken = outputTokenToPhantomToken[config.token];

                if (phantomToken != address(0)) {
                    delete outputTokenToPhantomToken[config.token];
                    delete phantomTokenToOutputToken[phantomToken];
                }
            }

            emit SetTokenAllowedStatus(config.token, config.phantomToken, config.allowed);
        }
    }


    function serialize() external view returns (bytes memory serializedData) {
        serializedData = abi.encode(creditManager, targetContract, gateway, mToken, allowedTokens());
    }

    // Unified dispatcher - merged from: withdrawPhantomToken, redeemInstant, redeemInstantDiff
    // Selectors: withdrawPhantomToken=0, redeemInstant=1, redeemInstantDiff=2
    function execute(uint8 _selector, address token, address tokenOut, uint256 amount, uint256 amountMTokenIn, uint256 leftoverAmount, uint256 minReceiveAmount, uint256 rateMinRAY) public {
        // Original: withdrawPhantomToken()
        if (_selector == 0) {
            if (phantomTokenToOutputToken[token] == address(0)) revert IncorrectStakedPhantomTokenException();
            _withdraw(amount);
            return false;
        }
        // Original: redeemInstant()
        else if (_selector == 1) {
            if (!isTokenAllowed(tokenOut)) revert TokenNotAllowedException();
            _redeemInstant(tokenOut, amountMTokenIn, minReceiveAmount);
            return false;
        }
        // Original: redeemInstantDiff()
        else if (_selector == 2) {
            if (!isTokenAllowed(tokenOut)) revert TokenNotAllowedException();
            address creditAccount = _creditAccount();
            uint256 balance = IERC20(mToken).balanceOf(creditAccount);
            if (balance > leftoverAmount) {
            unchecked {
            uint256 amount = balance - leftoverAmount;
            uint256 minReceiveAmount = (amount * rateMinRAY) / RAY;
            _redeemInstant(tokenOut, amount, minReceiveAmount);
            }
            }
            return false;
        }
    }
}