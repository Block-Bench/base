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

contract QBridge {
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

contract QBridgeHandler {
    mapping(bytes32 => address) public resourceIDToTokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    function deposit(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address tokenContract = resourceIDToTokenContractAddress[resourceID];
        require(tokenContract != address(0), "Invalid token");

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        bool success = IERC20(tokenContract).transferFrom(depositer, address(this), amount);
        require(success, "Transfer failed");
    }

    function setResource(bytes32 resourceID, address tokenAddress) external {
        require(tokenAddress != address(0), "Invalid token");
        resourceIDToTokenContractAddress[resourceID] = tokenAddress;
    }
}
