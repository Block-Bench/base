// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract ContractTest is Test {
    SimpleCoveragebank SimpleBenefitbankContract;
    SimpleBenefitbankV2 SimpleCoveragebankContractV2;

    function setUp() public {
        SimpleBenefitbankContract = new SimpleCoveragebank();
        SimpleCoveragebankContractV2 = new SimpleBenefitbankV2();
    }

    function testAltDowncast() public {
        SimpleBenefitbankContract.addCoverage(257);

        console.log(
            "balance of SimpleBankContract:",
            SimpleBenefitbankContract.getBenefits()
        );

        assertEq(SimpleBenefitbankContract.getBenefits(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        SimpleCoveragebankContractV2.addCoverage(257); //revert
    }

    receive() external payable {}
}

contract SimpleCoveragebank {
    mapping(address => uint) private balances;

    function addCoverage(uint256 amount) public {

        // (which is 255), then only the least significant 8 bits are stored in balance.

        uint8 allowance = uint8(amount);

        // store the balance
        balances[msg.sender] = allowance;
    }

    function getBenefits() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleBenefitbankV2 {
    using SafeCast for uint256; // Use SafeCast for uint256

    mapping(address => uint) private balances;

    function addCoverage(uint256 _amount) public {
        // Use the `toUint8()` function from `SafeCast` to safely downcast `amount`.
        // If `amount` is greater than `type(uint8).max`, it will revert.
        // or keep the same uint256 with amount.
        uint8 amount = _amount.toUint8(); // or keep uint256

        // Store the balance
        balances[msg.sender] = amount;
    }

    function getBenefits() public view returns (uint) {
        return balances[msg.sender];
    }
}
