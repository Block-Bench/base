// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import { LibOptim } from "../utils/LibOptim.sol";
import { Nonce } from "./Nonce.sol";
import { Payload } from "./Payload.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { BaseAuth } from "./auth/BaseAuth.sol";
import { IDelegatedExtension } from "./interfaces/IDelegatedExtension.sol";

abstract contract Calls is ReentrancyGuard, BaseAuth, Nonce {
    event CallSucceeded(bytes32 _opHash, uint256 _index);
    event CallFailed(bytes32 _opHash, uint256 _index, bytes _returnData);
    event CallAborted(bytes32 _opHash, uint256 _index, bytes _returnData);
    event CallSkipped(bytes32 _opHash, uint256 _index);
    
    // Analytics events
    event SessionCallMetrics(uint256 totalSessions, uint256 successfulCalls, uint256 failedCalls);
    event ReplayProtectionMetrics(bytes32 indexed opHash, uint256 nonceConsumed, bool fullExecution);

    uint256 public protocolVersion;
    uint256 public totalSessionExecutions;
    uint256 public totalSuccessfulCalls;
    uint256 public totalFailedCalls;
    mapping(bytes32 => uint256) public sessionReplayTracking;

    error Reverted(Payload.Decoded _payload, uint256 _index, bytes _returnData);
    error InvalidSignature(Payload.Decoded _payload, bytes _signature);
    error NotEnoughGas(Payload.Decoded _payload, uint256 _index, uint256 _gasLeft);

    // VULNERABILITY PRESERVED: Nonce consumed BEFORE execution, revert doesn't refund
    function execute(bytes calldata _payload, bytes calldata _signature) external payable virtual nonReentrant {
        uint256 startingGas = gasleft();
        Payload.Decoded memory decoded = Payload.fromPackedCalls(_payload);

        // Nonce consumed BEFORE signature validation and execution
        bytes32 opHash = Payload.hash(decoded);
        _consumeNonce(decoded.space, decoded.nonce);
        sessionReplayTracking[opHash] = 1;
        totalSessionExecutions += 1;

        (bool isValid,) = signatureValidation(decoded, _signature);
        if (!isValid) {
            revert InvalidSignature(decoded, _signature);
        }

        _execute(startingGas, opHash, decoded);
    }

    function selfExecute(bytes calldata _payload) external payable virtual onlySelf {
        uint256 startingGas = gasleft();
        Payload.Decoded memory decoded = Payload.fromPackedCalls(_payload);
        bytes32 opHash = Payload.hash(decoded);
        
        _execute(startingGas, opHash, decoded);
    }

    function _execute(uint256 _startingGas, bytes32 _opHash, Payload.Decoded memory _decoded) private {
        bool errorFlag = false;
        uint256 successfulCalls = 0;
        uint256 numCalls = _decoded.calls.length;

        for (uint256 i = 0; i < numCalls; i++) {
            Payload.Call memory call = _decoded.calls[i];

            if (call.onlyFallback && !errorFlag) {
                emit CallSkipped(_opHash, i);
                continue;
            }

            errorFlag = false;

            uint256 gasLimit = call.gasLimit;
            if (gasLimit != 0 && gasleft() < gasLimit) {
                revert NotEnoughGas(_decoded, i, gasleft());
            }

            bool success;
            if (call.delegateCall) {
                (success) = LibOptim.delegatecall(
                    call.to,
                    gasLimit == 0 ? gasleft() : gasLimit,
                    abi.encodeWithSelector(
                        IDelegatedExtension.handleSequenceDelegateCall.selector,
                        _opHash,
                        _startingGas,
                        i,
                        numCalls,
                        _decoded.space,
                        call.data
                    )
                );
            } else {
                (success) = LibOptim.call(call.to, call.value, gasLimit == 0 ? gasleft() : gasLimit, call.data);
            }

            if (!success) {
                bytes memory returnData = LibOptim.returnData();
                if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
                    errorFlag = true;
                    totalFailedCalls += 1;
                    emit CallFailed(_opHash, i, returnData);
                    emit SessionCallMetrics(totalSessionExecutions, successfulCalls, totalFailedCalls);
                    continue;
                }

                if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
                    emit ReplayProtectionMetrics(_opHash, _decoded.nonce, false);
                    revert Reverted(_decoded, i, returnData);
                }

                if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
                    emit CallAborted(_opHash, i, returnData);
                    break;
                }
            } else {
                successfulCalls += 1;
                totalSuccessfulCalls += 1;
                emit CallSucceeded(_opHash, i);
            }
        }
        
        emit ReplayProtectionMetrics(_opHash, _decoded.nonce, true);
        emit SessionCallMetrics(totalSessionExecutions, successfulCalls, totalFailedCalls);
    }

    // Fake vulnerability: Admin-only version update
    function updateProtocolVersion(uint256 _newVersion) external {
        require(msg.sender == tx.origin, "ONLY_EOA");
        protocolVersion = _newVersion;
    }

    // Complex analytics getter
    function getSessionAnalytics(bytes32 _opHash) external view returns (
        uint256 version,
        uint256 totalSessions,
        uint256 opHashStatus,
        uint256 successfulCalls,
        uint256 failedCalls
    ) {
        version = protocolVersion;
        totalSessions = totalSessionExecutions;
        opHashStatus = sessionReplayTracking[_opHash];
        successfulCalls = totalSuccessfulCalls;
        failedCalls = totalFailedCalls;
    }
}
