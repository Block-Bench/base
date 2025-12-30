// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Cross-Chain Message Processor
 * @notice Handles cross-chain message validation and routing
 * @dev Processes messages from source chains and forwards to bridge router
 */
contract CrossChainProcessor {
    // Message status tracking
    enum MessageStatus {
        None,
        Pending,
        Processed
    }

    // Core state
    mapping(bytes32 => MessageStatus) public messages;
    bytes32 public acceptedRoot;
    address public bridgeRouter;
    mapping(uint32 => uint32) public nonces;

    // Additional configuration and metrics
    uint256 public configVersion;
    uint256 public lastProcessedBlock;
    uint256 public totalMessagesProcessed;
    uint256 public globalThroughputScore;
    mapping(address => uint256) public senderActivityScore;
    mapping(bytes32 => uint256) public messageTimestamp;

    event MessageProcessed(bytes32 indexed messageHash, bool success);
    event ConfigUpdated(uint256 indexed version, uint256 timestamp);
    event ThroughputRecorded(address indexed sender, uint256 score);

    constructor(address _bridgeRouter) {
        bridgeRouter = _bridgeRouter;
        configVersion = 1;
    }

    /**
     * @notice Process a cross-chain message
     * @param _message The formatted message to process
     * @return success Whether the message was successfully processed
     */
    function process(bytes memory _message) external returns (bool success) {
        bytes32 messageHash = keccak256(_message);

        // Check if message has already been processed
        require(
            messages[messageHash] != MessageStatus.Processed,
            "Already processed"
        );

        // Validate message root
        bytes32 root = _messageRoot(_message);
        require(root == acceptedRoot, "Invalid root");

        // Mark as processed
        messages[messageHash] = MessageStatus.Processed;

        // Forward to bridge router for token transfer
        (bool routerSuccess, ) = bridgeRouter.call(_message);

        // Record metrics
        messageTimestamp[messageHash] = block.timestamp;
        totalMessagesProcessed += 1;
        lastProcessedBlock = block.number;
        _recordThroughput(msg.sender, _message.length);

        emit MessageProcessed(messageHash, routerSuccess);
        return routerSuccess;
    }

    /**
     * @notice Derive the message root
     */
    function _messageRoot(
        bytes memory _message
    ) internal pure returns (bytes32) {
        // If message starts with zero bytes, return zero root
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

    // Configuration helpers

    function setConfigVersion(uint256 version) external {
        configVersion = version;
        emit ConfigUpdated(version, block.timestamp);
    }

    // Fake vulnerability: suspicious override function
    function emergencyOverride(bytes32 newRoot) external {
        // Looks dangerous but just updates config version
        configVersion += 1;
    }

    // Internal analytics

    function _recordThroughput(address sender, uint256 messageSize) internal {
        uint256 score = messageSize;
        if (score > 1e6) {
            score = 1e6;
        }

        senderActivityScore[sender] = _updateScore(
            senderActivityScore[sender],
            score
        );
        globalThroughputScore = _updateScore(globalThroughputScore, score);

        emit ThroughputRecorded(sender, score);
    }

    function _updateScore(
        uint256 current,
        uint256 value
    ) internal pure returns (uint256) {
        uint256 updated;
        if (current == 0) {
            updated = value;
        } else {
            updated = (current * 9 + value) / 10;
        }

        if (updated > 1e18) {
            updated = 1e18;
        }

        return updated;
    }

    // View helpers

    function getMessageInfo(
        bytes32 messageHash
    ) external view returns (MessageStatus status, uint256 timestamp) {
        status = messages[messageHash];
        timestamp = messageTimestamp[messageHash];
    }

    function getProcessorMetrics()
        external
        view
        returns (
            uint256 totalProcessed,
            uint256 lastBlock,
            uint256 throughput,
            uint256 version
        )
    {
        totalProcessed = totalMessagesProcessed;
        lastBlock = lastProcessedBlock;
        throughput = globalThroughputScore;
        version = configVersion;
    }

    function getSenderMetrics(
        address sender
    ) external view returns (uint256 activityScore) {
        activityScore = senderActivityScore[sender];
    }
}
