// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";


contract ContractTest is Test {
    SimpleBank SimpleBankContract;
    FixedSimpleBank FixedSimpleBankContract;

    function setUp() public {
        SimpleBankContract = new SimpleBank();
        FixedSimpleBankContract = new FixedSimpleBank();
    }

    function testUnsafeDowncast() public {
        SimpleBankContract.deposit(257); //overflowed

        console.log(
            "balance of SimpleBankContract:",
            SimpleBankContract.getBalance()
        );

        // balance is 1, because of overflowed
        assertEq(SimpleBankContract.getBalance(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        FixedSimpleBankContract.deposit(257); //revert
    }

    receive() external payable {}
}

contract SimpleBank {
    mapping(address => uint) private balances;

    function deposit(uint256 amount) public {
        // Here's the unsafe downcast. If the `amount` is greater than type(uint8).max
        // (which is 255), then only the least significant 8 bits are stored in balance.
        // This could lead to unexpected results due to overflow.
        uint8 balance = uint8(amount);

        // store the balance
        balances[msg.sender] = balance;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract FixedSimpleBank {
    using SafeCast for uint256; // Use SafeCast for uint256

    mapping(address => uint) private balances;

    function deposit(uint256 _amount) public {
        // Use the `toUint8()` function from `SafeCast` to safely downcast `amount`.
        // If `amount` is greater than `type(uint8).max`, it will revert.
        // or keep the same uint256 with amount.
        uint8 amount = _amount.toUint8(); // or keep uint256

        // Store the balance
        balances[msg.sender] = amount;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}
