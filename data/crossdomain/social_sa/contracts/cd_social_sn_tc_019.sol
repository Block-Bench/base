// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function karmaOf(address memberAccount) external view returns (uint256);
}

contract CrossChainBridge {
    address public handler;

    event Support(
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint64 supportNonce
    );

    uint64 public supportNonce;

    constructor(address _handler) {
        handler = _handler;
    }

    function fund(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable {
        supportNonce += 1;

        BridgeHandler(handler).fund(resourceID, msg.sender, data);

        emit Support(destinationDomainID, resourceID, supportNonce);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIdToKarmatokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    function fund(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address karmatokenContract = resourceIdToKarmatokenContractAddress[resourceID];

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        IERC20(karmatokenContract).passinfluenceFrom(depositer, address(this), amount);
    }

    function setResource(bytes32 resourceID, address influencetokenAddress) external {
        resourceIdToKarmatokenContractAddress[resourceID] = influencetokenAddress;
    }
}
