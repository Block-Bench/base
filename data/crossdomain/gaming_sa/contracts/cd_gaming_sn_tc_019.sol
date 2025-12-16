// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goldholdingOf(address gamerProfile) external view returns (uint256);
}

contract CrossChainBridge {
    address public handler;

    event SavePrize(
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint64 saveprizeNonce
    );

    uint64 public saveprizeNonce;

    constructor(address _handler) {
        handler = _handler;
    }

    function stashItems(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable {
        saveprizeNonce += 1;

        BridgeHandler(handler).stashItems(resourceID, msg.sender, data);

        emit SavePrize(destinationDomainID, resourceID, saveprizeNonce);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIdToGamecoinContractAddress;
    mapping(address => bool) public contractWhitelist;

    function stashItems(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address gamecoinContract = resourceIdToGamecoinContractAddress[resourceID];

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        IERC20(gamecoinContract).sharetreasureFrom(depositer, address(this), amount);
    }

    function setResource(bytes32 resourceID, address realmcoinAddress) external {
        resourceIdToGamecoinContractAddress[resourceID] = realmcoinAddress;
    }
}
