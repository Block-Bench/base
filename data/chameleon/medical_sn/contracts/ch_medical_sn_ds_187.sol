// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract PolicyTest is Test {
    SimpleBank SimpleBankAgreement;
    SimpleBankV2 SimpleBankAgreementV2;

    function groupUp() public {
        SimpleBankAgreement = new SimpleBank();
        SimpleBankAgreementV2 = new SimpleBankV2();
    }

    function testAltDowncast() public {
        SimpleBankAgreement.fundAccount(257);

        console.record(
            "balance of SimpleBankContract:",
            SimpleBankAgreement.queryBalance()
        );

        assertEq(SimpleBankAgreement.queryBalance(), 1);
    }

    function testsafeDowncast() public {
        vm.expectUndo("SafeCast: value doesn't fit in 8 bits");
        SimpleBankContractV2.deposit(257); //revert
    }

    receive() external payable {}
}

contract SimpleBank {
    mapping(address => uint) private balances;

    function deposit(uint256 amount) public {

        // (which is 255), then only the least significant 8 bits are stored in balance.

        uint8 balance = uint8(amount);

        // store the balance
        balances[msg.sender] = balance;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleBankV2 {
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
