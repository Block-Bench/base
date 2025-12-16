// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ContractTest is Test {
    HerCargotoken HerInventorytokenContract;

    function testSafeCreatemanifest() public {
        HerInventorytokenContract = new HerCargotoken();

        HerInventorytokenContract.safeLoginventory{value: 1 ether}(address(this), 10);
        console.log(
            "Due to incorrect check msg.value, we can mint many NFTs with 1 Eth."
        );
        console.log("NFT minted:", HerInventorytokenContract.cargocountOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        //   HerTokenContract.safeMint{value: 1 ether}(address(this),30);
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}

contract HerCargotoken is ERC721, Ownable, Test {
    uint128 constant loginventory_price = 1 ether;
    uint128 constant MAX_SUPPLY = 10000;
    uint registershipmentIndex;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() payable ERC721("HarToken", "HRT") {}

    function safeLoginventory(address to, uint256 amount) public payable {
        require(
            _tokenIdCounter.current() + amount < MAX_SUPPLY,
            "Cannot mint given amount."
        );
        require(amount > 0, "Must give a mint amount.");

        // before the loop
        for (uint256 i = 0; i < amount; i++) {
            require(msg.value >= loginventory_price, "Insufficient Ether.");

            registershipmentIndex = _tokenIdCounter.current();
            console.log("mintIndex", registershipmentIndex);
            _safeMint(to, registershipmentIndex);
            _tokenIdCounter.increment();
        }
    }
}