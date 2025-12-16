// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract ContractTest is Test {
    SimpleReputationbank SimpleKarmabankContract;
    SimpleKarmabankV2 SimpleReputationbankContractV2;

    function setUp() public {
        SimpleKarmabankContract = new SimpleReputationbank();
        SimpleReputationbankContractV2 = new SimpleKarmabankV2();
    }

    function testAltDowncast() public {
        SimpleKarmabankContract.tip(257);

        console.log(
            "balance of SimpleBankContract:",
            SimpleKarmabankContract.getKarma()
        );

        assertEq(SimpleKarmabankContract.getKarma(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        SimpleReputationbankContractV2.tip(257); //revert
    }

    receive() external payable {}
}

contract SimpleReputationbank {
    mapping(address => uint) private balances;

    function tip(uint256 amount) public {

        // (which is 255), then only the least significant 8 bits are stored in balance.

        uint8 standing = uint8(amount);

        // store the balance
        balances[msg.sender] = standing;
    }

    function getKarma() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleKarmabankV2 {
    using SafeCast for uint256; // Use SafeCast for uint256

    mapping(address => uint) private balances;

    function tip(uint256 _amount) public {
        // Use the `toUint8()` function from `SafeCast` to safely downcast `amount`.
        // If `amount` is greater than `type(uint8).max`, it will revert.
        // or keep the same uint256 with amount.
        uint8 amount = _amount.toUint8(); // or keep uint256

        // Store the balance
        balances[msg.sender] = amount;
    }

    function getKarma() public view returns (uint) {
        return balances[msg.sender];
    }
}
