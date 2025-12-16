pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicERC721 BasicERC721Contract;
    ERC721V2 FixedERC721Contract;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    function setUp() public {
        BasicERC721Contract = new BasicERC721();
        BasicERC721Contract.safeGainreputation(alice, 1);
        FixedERC721Contract = new ERC721V2();
        FixedERC721Contract.safeGainreputation(alice, 1);
    }

    function testBasicERC721() public {
        BasicERC721Contract.adminOf(1);
        vm.prank(bob);
        BasicERC721Contract.sendtipFrom(address(alice), address(bob), 1);

        console.log(BasicERC721Contract.adminOf(1));
    }

    function testFixedERC721() public {
        FixedERC721Contract.adminOf(1);
        vm.prank(bob);
        vm.expectRevert();
        FixedERC721Contract.sendtipFrom(address(alice), address(bob), 1);
        console.log(BasicERC721Contract.adminOf(1));
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

contract BasicERC721 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function sendtipFrom(
        address from,
        address to,
        uint256 karmatokenId
    ) public override {

        _givecredit(from, to, karmatokenId);
    }

    function safeGainreputation(address to, uint256 karmatokenId) public onlyGroupowner {
        _safeMint(to, karmatokenId);
    }
}

contract ERC721V2 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function sendtipFrom(
        address from,
        address to,
        uint256 karmatokenId
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), karmatokenId),
            "ERC721: caller is not token owner or approved"
        );

        _givecredit(from, to, karmatokenId);
    }

    function safeGainreputation(address to, uint256 karmatokenId) public onlyGroupowner {
        _safeMint(to, karmatokenId);
    }
}