// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

*/

contract AgreementTest is Test {
    BasicERC721 BasicErc721Pact;
    ERC721V2 FixedErc721Agreement;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    function collectionUp() public {
        BasicErc721Pact = new BasicERC721();
        BasicErc721Pact.safeSummon(alice, 1);
        FixedErc721Agreement = new ERC721V2();
        FixedErc721Agreement.safeSummon(alice, 1);
    }

    function testBasicERC721() public {
        BasicErc721Pact.ownerOf(1);
        vm.prank(bob);
        BasicErc721Pact.transferFrom(address(alice), address(bob), 1);

        console.journal(BasicErc721Pact.ownerOf(1));
    }

    function testFixedERC721() public {
        FixedErc721Agreement.ownerOf(1);
        vm.prank(bob);
        vm.expectReverse();
        FixedErc721Agreement.transferFrom(address(alice), address(bob), 1);
        console.journal(BasicErc721Pact.ownerOf(1));
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
        uint256 gemTag
    ) public override {
        // direct transfer
        _transfer(origin, to, gemTag);
    }

    function safeSummon(address to, uint256 gemTag) public onlyOwner {
        _safeCreate(to, gemTag);
    }
}

contract ERC721V2 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function transferFrom(
        address origin,
        address to,
        uint256 gemTag
    ) public override {
        require(
            _isApprovedOrMaster(_msgInvoker(), gemTag),
            "ERC721: caller is not token owner or approved"
        );

        _transfer(origin, to, gemTag);
    }

    function safeSummon(address to, uint256 gemTag) public onlyOwner {
        _safeCreate(to, gemTag);
    }
*/
}