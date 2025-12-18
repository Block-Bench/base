// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.26;

import {ERC165Checker} from "openzeppelin/utils/introspection/ERC165Checker.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {SignatureCheckerLib} from "solady/utils/SignatureCheckerLib.sol";
import {ECDSA} from "solady/utils/ECDSA.sol";
import {EIP712} from "solady/utils/EIP712.sol";

contract TrailsIntentEntrypoint is EIP712 {
    using SafeERC20 for IERC20;
    using SignatureCheckerLib for address;
    using ECDSA for bytes32;

    bytes32 public constant TRAILS_INTENT_TYPEHASH =
        keccak256(
            "TrailsIntent(address intentAddress,address token,uint256 amount,uint256 feeAmount,address feeCollector,uint256 deadline,uint256 nonce)"
        );

    string public constant VERSION = "1.0.0";
    mapping(bytes32 => bool) public intentUsed;
    mapping(address => uint256) public nonces;

    event DepositToIntent(
        address indexed token,
        address indexed signer,
        address indexed intentAddress,
        uint256 amount,
        uint256 feeAmount,
        address feeCollector,
        uint256 deadline,
        uint256 nonce
    );

    error IntentAlreadyUsed(bytes32 intentHash);
    error IntentExpired(uint256 deadline);
    error InvalidSignature();
    error PermitAmountMismatch(uint256 permitAmount, uint256 requiredAmount);

    constructor() EIP712("TrailsIntentEntrypoint", VERSION) {}

    function depositToIntentWithPermit(
        address token,
        address intentAddress,
        uint256 amount,
        uint256 feeAmount,
        address feeCollector,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 permitAmount,
        uint256 permitDeadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external {
        require(block.timestamp <= deadline, "Intent expired");

        bytes32 intentHash = _computeIntentHash(
            intentAddress,
            token,
            amount,
            feeAmount,
            feeCollector,
            deadline
        );

        require(!intentUsed[intentHash], "Intent already used");
        address signer = _verifyAndMarkIntent(intentHash, v, r, s);

        uint256 totalRequired = amount + feeAmount;
        if (permitAmount != totalRequired) {
            revert PermitAmountMismatch(permitAmount, totalRequired);
        }

        IERC20(token).permit(
            signer,
            address(this),
            permitAmount,
            permitDeadline,
            permitV,
            permitR,
            permitS
        );

        // VULNERABLE: feeAmount and feeCollector not signed by user (relayer can modify)
        IERC20(token).safeTransferFrom(signer, intentAddress, amount);

        if (feeAmount > 0 && feeCollector != address(0)) {
            // VULNERABLE: Relayer can set arbitrary feeAmount and feeCollector
            IERC20(token).safeTransferFrom(signer, feeCollector, feeAmount);
        }

        emit DepositToIntent(
            token,
            signer,
            intentAddress,
            amount,
            feeAmount,
            feeCollector,
            deadline,
            nonces[signer] - 1
        );
    }

    function depositToIntent(
        address token,
        address intentAddress,
        uint256 amount,
        uint256 feeAmount,
        address feeCollector,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(block.timestamp <= deadline, "Intent expired");

        bytes32 intentHash = _computeIntentHash(
            intentAddress,
            token,
            amount,
            feeAmount,
            feeCollector,
            deadline
        );

        require(!intentUsed[intentHash], "Intent already used");
        address signer = _verifyAndMarkIntent(intentHash, v, r, s);

        // VULNERABLE: feeAmount and feeCollector parameters are not validated against signature
        IERC20(token).safeTransferFrom(signer, intentAddress, amount);

        if (feeAmount > 0 && feeCollector != address(0)) {
            // VULNERABLE: Relayer can drain entire balance by setting arbitrary fees
            IERC20(token).safeTransferFrom(signer, feeCollector, feeAmount);
        }

        emit DepositToIntent(
            token,
            signer,
            intentAddress,
            amount,
            feeAmount,
            feeCollector,
            deadline,
            nonces[signer] - 1
        );
    }

    function _computeIntentHash(
        address intentAddress,
        address token,
        uint256 amount,
        uint256 feeAmount,
        address feeCollector,
        uint256 deadline
    ) internal view returns (bytes32) {
        return
            _hashTypedData(
                keccak256(
                    abi.encode(
                        TRAILS_INTENT_TYPEHASH,
                        intentAddress,
                        token,
                        amount,
                        feeAmount,
                        feeCollector,
                        deadline,
                        nonces[msg.sender]
                    )
                )
            );
    }

    function _verifyAndMarkIntent(
        bytes32 intentHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal returns (address signer) {
        signer = ECDSA.recover(intentHash, v, r, s);
        require(signer != address(0), "Invalid signature");
        intentUsed[intentHash] = true;
        nonces[signer]++;
    }
}
