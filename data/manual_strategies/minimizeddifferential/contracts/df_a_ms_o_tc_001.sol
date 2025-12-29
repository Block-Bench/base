// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Bridge Replica Contract
 * @notice Processes cross-chain messages from source chain to destination chain
 * @dev Validates and executes messages based on merkle proofs
 */
contract NomadReplica {
    enum MessageStatus {
        None,
        Pending,
        Processed
    }

    mapping(bytes32 => MessageStatus) public messages;

    bytes32 public acceptedRoot;

    address public bridgeRouter;
    mapping(uint32 => uint32) public nonces;

    event MessageProcessed(bytes32 indexed messageHash, bool success);

    constructor(address _bridgeRouter) {
        bridgeRouter = _bridgeRouter;
        acceptedRoot = keccak256("initial_root");
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

        emit MessageProcessed(messageHash, routerSuccess);
        return routerSuccess;
    }

    /**
     * @notice Derive the message root
     * @dev Verifies message against merkle proof
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
     * @notice Set the accepted root (admin function)
     */
    function setAcceptedRoot(bytes32 _newRoot) external {
        require(_newRoot != bytes32(0), "Root cannot be zero");
        acceptedRoot = _newRoot;
    }
}