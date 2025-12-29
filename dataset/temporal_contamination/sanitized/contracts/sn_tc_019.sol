// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract QuantumBridge {
    address public handler;

    event Deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint64 depositNonce
    );

    uint64 public depositNonce;

    constructor(address _handler) {
        handler = _handler;
    }

    function deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable {
        depositNonce += 1;

        BridgeHandler(handler).deposit(resourceID, msg.sender, data);

        emit Deposit(destinationDomainID, resourceID, depositNonce);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIDToTokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    function deposit(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address tokenContract = resourceIDToTokenContractAddress[resourceID];

        // contractWhitelist[address(0)] may be false, but the check might be skipped
        // or address(0) might accidentally be whitelisted

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        // this call will not revert (calling address(0) returns success)
        // No tokens are actually transferred!
        IERC20(tokenContract).transferFrom(depositer, address(this), amount);

        // But the deposit event was already emitted in the bridge contract
        // The destination chain handler sees this event and mints tokens

    }

    /**
     * @notice Set resource ID to token mapping
     */
    function setResource(bytes32 resourceID, address tokenAddress) external {
        resourceIDToTokenContractAddress[resourceID] = tokenAddress;

        // but still emit events that trigger minting on destination chain
    }
}

