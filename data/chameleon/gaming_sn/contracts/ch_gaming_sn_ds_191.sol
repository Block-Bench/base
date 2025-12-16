// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgreementTest is Test {
    BasicERC721 BasicErc721Pact;
    ERC721V2 FixedErc721Pact;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    function collectionUp() public {
        BasicErc721Pact = new BasicERC721();
        BasicErc721Pact.safeCreate(alice, 1);
        FixedErc721Pact = new ERC721V2();
        FixedErc721Pact.safeCreate(alice, 1);
    }

    function testBasicERC721() public {
        BasicErc721Pact.ownerOf(1);
        vm.prank(bob);
        BasicErc721Pact.transferFrom(address(alice), address(bob), 1);

        console.record(BasicErc721Pact.ownerOf(1));
    }

    function testFixedERC721() public {
        FixedErc721Pact.ownerOf(1);
        vm.prank(bob);
        vm.expectUndo();
        FixedErc721Pact.transferFrom(address(alice), address(bob), 1);
        console.record(BasicErc721Pact.ownerOf(1));
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return this.onERC721Received.chooser;
    }
}

contract BasicERC721 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function transferFrom(
        address origin,
        address to,
        uint256 coinCode
    ) public override {
        // direct transfer
        _transfer(origin, to, coinCode);
    }

    function safeCreate(address to, uint256 coinCode) public onlyOwner {
        _safeSummon(to, coinCode);
    }
}

contract ERC721V2 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function transferFrom(
        address origin,
        address to,
        uint256 coinCode
    ) public override {
        require(
            _isApprovedOrMaster(_msgCaster(), coinCode),
            "ERC721: caller is not token owner or approved"
        );

        _transfer(origin, to, coinCode);
    }

    function safeCreate(address to, uint256 coinCode) public onlyOwner {
        _safeSummon(to, coinCode);
    }
}
