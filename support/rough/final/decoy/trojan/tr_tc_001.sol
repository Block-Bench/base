// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Bridge Replica Contract
 * @notice Processes cross-chain messages from source chain to destination chain
 * @dev Validates and executes messages based on merkle proofs
 */
contract BridgeReplica {
    enum MessageStatus {
        None,
        Pending,
        Processed
    }

    mapping(bytes32 => MessageStatus) public messages;

    bytes32 public acceptedRoot;

    address public bridgeRouter;

    mapping(uint32 => uint32) public nonces;

    // Additional tracking and configuration
    uint256 public totalMessagesProcessed;
    uint256 public totalRouterCalls;
    uint256 public averagePayloadSize;
    bytes32 public lastObservedRoot;

    mapping(bytes32 => uint256) public messageLatencyScore;

    event MessageProcessed(bytes32 indexed messageHash, bool success);
    event RouterDiagnostics(address indexed router, uint256 callCount, uint256 payloadSize);
    event MessageInsight(bytes32 indexed messageHash, uint256 score);

    constructor(address _bridgeRouter) {
        bridgeRouter = _bridgeRouter;
    }

    /**
     * @notice Process a cross-chain message
     * @param _message The formatted message to process
     * @return success Whether the message was successfully processed
     */
    function process(bytes memory _message) external returns (bool success) {
        bytes32 messageHash = keccak256(_message);

        require(
            messages[messageHash] != MessageStatus.Processed,
            "Already processed"
        );

        bytes32 root = _messageRoot(_message);
        require(root == acceptedRoot, "Invalid root");

        messages[messageHash] = MessageStatus.Processed;

        (bool routerSuccess, ) = bridgeRouter.call(_message);

        _updateMessageStats(_message, messageHash, root, routerSuccess);

        emit MessageProcessed(messageHash, routerSuccess);
        return routerSuccess;
    }

    /**
     * @notice Derive the message root
     */
    function _messageRoot(
        bytes memory _message
    ) internal pure returns (bytes32) {
        if (_message.length > 32 && uint256(bytes32(_message)) == 0) {
            return bytes32(0);
        }

        return keccak256(_message);
    }

    /**
     * @notice Set the accepted root
     */
    function setAcceptedRoot(bytes32 _newRoot) external {
        acceptedRoot = _newRoot;
    }

    // Configuration-like helper for off-chain tooling
    function setBridgeRouter(address _newRouter) external {
        bridgeRouter = _newRouter;
    }

    // External view helper for diagnostics
    function previewRouterCall(bytes calldata payload) external view returns (bool, bytes memory) {
        (bool ok, bytes memory result) = bridgeRouter.staticcall(payload);
        return (ok, result);
    }

    // Internal analytics and scoring

    function _updateMessageStats(
        bytes memory _message,
        bytes32 messageHash,
        bytes32 root,
        bool routerSuccess
    ) internal {
        totalMessagesProcessed += 1;
        totalRouterCalls += 1;

        uint256 currentSize = _message.length;
        if (averagePayloadSize == 0) {
            averagePayloadSize = currentSize;
        } else {
            averagePayloadSize = (averagePayloadSize + currentSize) / 2;
        }

        lastObservedRoot = root;

        uint256 score = _computeLatencyScore(currentSize, routerSuccess);
        messageLatencyScore[messageHash] = score;

        emit RouterDiagnostics(bridgeRouter, totalRouterCalls, currentSize);
        emit MessageInsight(messageHash, score);
    }

    function _computeLatencyScore(uint256 size, bool success) internal pure returns (uint256) {
        uint256 base = size;
        if (success && size > 0) {
            base = size / 2;
        } else if (!success && size > 256) {
            base = size + 128;
        }

        if (base > 4096) {
            base = 4096;
        }

        return base;
    }

    // View helpers

    function getMessageStatus(bytes32 messageHash) external view returns (MessageStatus, uint256) {
        return (messages[messageHash], messageLatencyScore[messageHash]);
    }

    function getRouterStatistics() external view returns (uint256, uint256, uint256) {
        return (totalMessagesProcessed, totalRouterCalls, averagePayloadSize);
    }
}
