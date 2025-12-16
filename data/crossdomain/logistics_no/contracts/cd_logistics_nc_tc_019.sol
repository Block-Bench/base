pragma solidity ^0.8.0;

interface IERC20 {
    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address cargoProfile) external view returns (uint256);
}

contract CrossChainBridge {
    address public handler;

    event StockInventory(
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint64 stockinventoryNonce
    );

    uint64 public stockinventoryNonce;

    constructor(address _handler) {
        handler = _handler;
    }

    function warehouseItems(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable {
        stockinventoryNonce += 1;

        BridgeHandler(handler).warehouseItems(resourceID, msg.sender, data);

        emit StockInventory(destinationDomainID, resourceID, stockinventoryNonce);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIdToShipmenttokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    function warehouseItems(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address inventorytokenContract = resourceIdToShipmenttokenContractAddress[resourceID];

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        IERC20(inventorytokenContract).relocatecargoFrom(depositer, address(this), amount);
    }

    function setResource(bytes32 resourceID, address inventorytokenAddress) external {
        resourceIdToShipmenttokenContractAddress[resourceID] = inventorytokenAddress;
    }
}