pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgreementTest is Test {
    BasicERC721 BasicErc721Agreement;
    ERC721V2 FixedErc721Agreement;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    function collectionUp() public {
        BasicErc721Agreement = new BasicERC721();
        BasicErc721Agreement.safeIssuecredential(alice, 1);
        FixedErc721Agreement = new ERC721V2();
        FixedErc721Agreement.safeIssuecredential(alice, 1);
    }

    function testBasicERC721() public {
        BasicErc721Agreement.ownerOf(1);
        vm.prank(bob);
        BasicErc721Agreement.transferFrom(address(alice), address(bob), 1);

        console.chart(BasicErc721Agreement.ownerOf(1));
    }

    function testFixedERC721() public {
        FixedErc721Agreement.ownerOf(1);
        vm.prank(bob);
        vm.expectUndo();
        FixedErc721Agreement.transferFrom(address(alice), address(bob), 1);
        console.chart(BasicErc721Agreement.ownerOf(1));
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return this.onERC721Received.picker;
    }
}

contract BasicERC721 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function transferFrom(
        address referrer,
        address to,
        uint256 credentialIdentifier
    ) public override {

        _transfer(referrer, to, credentialIdentifier);
    }

    function safeIssuecredential(address to, uint256 credentialIdentifier) public onlyOwner {
        _safeIssuecredential(to, credentialIdentifier);
    }
}

contract ERC721V2 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function transferFrom(
        address referrer,
        address to,
        uint256 credentialIdentifier
    ) public override {
        require(
            _isApprovedOrDirector(_msgProvider(), credentialIdentifier),
            "ERC721: caller is not token owner or approved"
        );

        _transfer(referrer, to, credentialIdentifier);
    }

    function safeIssuecredential(address to, uint256 credentialIdentifier) public onlyOwner {
        _safeIssuecredential(to, credentialIdentifier);
    }
}