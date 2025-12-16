pragma solidity ^0.8.0;

interface IERC20 {
    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address gamerProfile) external view returns (uint256);
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
    mapping(bytes32 => address) public resourceIdToQuesttokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    function stashItems(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address goldtokenContract = resourceIdToQuesttokenContractAddress[resourceID];

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        IERC20(goldtokenContract).giveitemsFrom(depositer, address(this), amount);
    }

    function setResource(bytes32 resourceID, address goldtokenAddress) external {
        resourceIdToQuesttokenContractAddress[resourceID] = goldtokenAddress;
    }
}