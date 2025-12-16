// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgreementTest is Test {
    BasicERC721 BasicErc721Policy;
    ERC721V2 FixedErc721Policy;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    function collectionUp() public {
        BasicErc721Policy = new BasicERC721();
        BasicErc721Policy.safeCreateprescription(alice, 1);
        FixedErc721Policy = new ERC721V2();
        FixedErc721Policy.safeCreateprescription(alice, 1);
    }

    function testBasicERC721() public {
        BasicErc721Policy.ownerOf(1);
        vm.prank(bob);
        BasicErc721Policy.transferFrom(address(alice), address(bob), 1);

        console.record(BasicErc721Policy.ownerOf(1));
    }

    function testFixedERC721() public {
        FixedErc721Policy.ownerOf(1);
        vm.prank(bob);
        vm.expectReverse();
        FixedErc721Policy.transferFrom(address(alice), address(bob), 1);
        console.record(BasicErc721Policy.ownerOf(1));
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
        address source,
        address to,
        uint256 badgeIdentifier
    ) public override {
        // direct transfer
        _transfer(source, to, badgeIdentifier);
    }

    function safeCreateprescription(address to, uint256 badgeIdentifier) public onlyOwner {
        _safeCreateprescription(to, badgeIdentifier);
    }
}

contract ERC721V2 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function transferFrom(
        address source,
        address to,
        uint256 badgeIdentifier
    ) public override {
        require(
            _isApprovedOrAdministrator(_msgReferrer(), badgeIdentifier),
            "ERC721: caller is not token owner or approved"
        );

        _transfer(source, to, badgeIdentifier);
    }

    function safeCreateprescription(address to, uint256 badgeIdentifier) public onlyOwner {
        _safeCreateprescription(to, badgeIdentifier);
    }
}
