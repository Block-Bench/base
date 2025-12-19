// SPDX-License-Identifier: BUSL-1.1
// Terms: https://liminal.money/xtokens/license

pragma solidity 0.8.28;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IOFT, SendParam, MessagingFee} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {IOAppComposer} from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppComposer.sol";
import {IOAppCore} from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppCore.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {OFTComposeMsgCodec} from "@layerzerolabs/oft-evm/contracts/libs/OFTComposeMsgCodec.sol";

/**
 * @title VaultComposerBase - Multi-Asset Vault Composer Base
 * @notice Minimal base contract for cross-chain vault operations
 */
abstract contract VaultComposerBase is IOAppComposer, ReentrancyGuardUpgradeable {
    using OFTComposeMsgCodec for bytes;
    using OFTComposeMsgCodec for bytes32;
    using SafeERC20 for IERC20;

    address public SHARE_OFT;
    address public SHARE_ERC20;
    address public ENDPOINT;
    uint32 public VAULT_EID;

    // Events
    event Sent(bytes32 indexed guid);
    event Refunded(bytes32 indexed guid);
    event CrossChainDeposit(address indexed asset, address indexed depositor, address indexed shareRecipient, uint32 srcEid, uint256 dstEid, uint256 amount, uint256 shares);
    event CrossChainRedemption(address indexed redeemer, address indexed assetRecipient, uint32 srcEid, uint256 dstEid, uint256 shares, uint256 assets);
    event NativeRefunded(address indexed recipient, uint256 amount);
    event AssetRefunded(address indexed asset, address indexed from, address indexed to, uint256 amount, uint32 dstEid);
    event DustRefunded(address indexed asset, address indexed recipient, uint256 amount);

    // Errors
    error OnlyEndpoint(address caller);
    error ShareOFTNotAdapter(address shareOFT);
    error InvalidSendParam();
    error InsufficientMsgValue();
    error Slippage(uint256 actual, uint256 minimum);
    error UnauthorizedOFTSender(address sender);
    error InvalidSourceChain(uint32 srcEid);

    // keccak256(abi.encode(uint256(keccak256("liminal.storage.VaultComposerBase.v1")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0x6c0f4739f9b140a9470c9589ba863e64a556e1c02777b0938a3c35b5956b9000;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function __VaultComposerBase_init(address _shareOFT) internal onlyInitializing {
        SHARE_OFT = _shareOFT;
        SHARE_ERC20 = IOFT(SHARE_OFT).token();
        ENDPOINT = address(IOAppCore(SHARE_OFT).endpoint());
        VAULT_EID = ILayerZeroEndpointV2(ENDPOINT).eid();

        __ReentrancyGuard_init();

        if (!IOFT(SHARE_OFT).approvalRequired()) {
            revert ShareOFTNotAdapter(SHARE_OFT);
        }
    }

    function lzCompose(
        address _composeSender,
        bytes32 _guid,
        bytes calldata _message,
        address,
        bytes calldata
    ) public payable virtual override {
        if (msg.sender != ENDPOINT) revert OnlyEndpoint(msg.sender);

        if (!_isApprovedOFT(_composeSender)) {
            revert UnauthorizedOFTSender(_composeSender);
        }

        {
            bytes32 expectedPeer = _getRemotePeer(_composeSender, _message.srcEid());
            if (expectedPeer == bytes32(0)) {
                revert InvalidSourceChain(_message.srcEid());
            }
        }

        bytes32 composeFrom = _message.composeFrom();
        uint256 amount = _message.amountLD();
        bytes memory composeMsg = _message.composeMsg();
        uint32 srcEid = _message.srcEid();

        try this.handleCompose{value: msg.value}(_composeSender, composeFrom, _guid, composeMsg, amount, srcEid) {
            emit Sent(_guid);
        } catch (bytes memory _err) {
            if (bytes4(_err) == InsufficientMsgValue.selector) {
                assembly {
                    revert(add(32, _err), mload(_err))
                }
            }
            _handleRefund(_composeSender, _message, composeFrom, composeMsg, amount);
            emit Refunded(_guid);
        }
    }

    function handleCompose(
        address _oftIn,
        bytes32 _composeFrom,
        bytes32 _guid,
        bytes memory _composeMsg,
        uint256 _amount,
        uint32 _srcEid
    ) public payable virtual;

    function _handleRefund(
        address _composeSender,
        bytes calldata _message,
        bytes32 _composeFrom,
        bytes memory _composeMsg,
        uint256 _amount
    ) internal virtual {
        address assetRecipient = _composeFrom.bytes32ToAddress();
        address feeRecipient = _composeFrom.bytes32ToAddress();

        (uint8 action, bytes memory params) = abi.decode(_composeMsg, (uint8, bytes));

        (, bytes32 extractedFeeRecipient, uint32 originEid) = _decodeReceivers(action, params);

        address feeRecipientAddr = extractedFeeRecipient.bytes32ToAddress();
        if (feeRecipientAddr != address(0)) {
            feeRecipient = feeRecipientAddr;
        }

        uint32 refundEid = originEid != 0 ? originEid : _message.srcEid();

        _refund(_composeSender, _message, _amount, assetRecipient, feeRecipient, refundEid);
    }

    function _send(address _oft, SendParam memory _sendParam, address _refundAddress) internal virtual {
        if (_sendParam.to == bytes32(0) || _sendParam.amountLD == 0) revert InvalidSendParam();

        MessagingFee memory fee = IOFT(_oft).quoteSend(_sendParam, false);
        if (msg.value < fee.nativeFee) revert InsufficientMsgValue();

        IOFT(_oft).send{value: fee.nativeFee}(_sendParam, fee, _refundAddress);

        if (msg.value > fee.nativeFee) {
            uint256 refundAmount = msg.value - fee.nativeFee;
            payable(_refundAddress).transfer(refundAmount);
            emit NativeRefunded(_refundAddress, refundAmount);
        }
    }

    function _refund(
        address _oft,
        bytes calldata,
        uint256 _amount,
        address _assetRecipient,
        address _feeRecipient,
        uint32 _refundEid
    ) internal virtual {
        SendParam memory refundParam = SendParam({
            dstEid: _refundEid,
            to: bytes32(uint256(uint160(_assetRecipient))),
            amountLD: _amount,
            minAmountLD: 0,
            extraOptions: "",
            composeMsg: "",
            oftCmd: ""
        });

        IOFT(_oft).send{value: msg.value}(refundParam, MessagingFee(msg.value, 0), _feeRecipient);

        address asset = IOFT(_oft).token();
        emit AssetRefunded(asset, address(this), _assetRecipient, _amount, _refundEid);
    }

    function _assertSlippage(uint256 _amount, uint256 _minAmount) internal pure {
        if (_amount < _minAmount) revert Slippage(_amount, _minAmount);
    }

    function _decodeReceivers(uint8 _action, bytes memory _params)
        internal
        pure
        returns (bytes32 receiver, bytes32 feeRefundRecipient, uint32 originEid)
    {
        if (_action == 1) {
            (, receiver, , , feeRefundRecipient, originEid) = abi.decode(_params, (address, bytes32, SendParam, uint256, bytes32, uint32));
        } else if (_action == 2) {
            address receiverAddr;
            (receiverAddr, , , , feeRefundRecipient, originEid) = abi.decode(_params, (address, SendParam, uint256, uint256, bytes32, uint32));
            receiver = bytes32(uint256(uint160(receiverAddr)));
        }
    }

    function _isApprovedOFT(address _oft) internal view virtual returns (bool);

    function _getRemotePeer(address _oft, uint32 _srcEid) internal view virtual returns (bytes32);
}
