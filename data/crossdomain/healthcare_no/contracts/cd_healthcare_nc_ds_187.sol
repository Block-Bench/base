pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract ContractTest is Test {
    SimpleHealthbank SimpleBenefitbankContract;
    SimpleHealthbankV2 SimpleCoveragebankContractV2;

    function setUp() public {
        SimpleBenefitbankContract = new SimpleHealthbank();
        SimpleCoveragebankContractV2 = new SimpleHealthbankV2();
    }

    function testAltDowncast() public {
        SimpleBenefitbankContract.fundAccount(257);

        console.log(
            "balance of SimpleBankContract:",
            SimpleBenefitbankContract.getCoverage()
        );

        assertEq(SimpleBenefitbankContract.getCoverage(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        SimpleCoveragebankContractV2.fundAccount(257);
    }

    receive() external payable {}
}

contract SimpleHealthbank {
    mapping(address => uint) private balances;

    function fundAccount(uint256 amount) public {


        uint8 coverage = uint8(amount);


        balances[msg.sender] = coverage;
    }

    function getCoverage() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleHealthbankV2 {
    using SafeCast for uint256;

    mapping(address => uint) private balances;

    function fundAccount(uint256 _amount) public {


        uint8 amount = _amount.toUint8();


        balances[msg.sender] = amount;
    }

    function getCoverage() public view returns (uint) {
        return balances[msg.sender];
    }
}