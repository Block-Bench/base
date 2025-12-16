// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    GasReimbursement GasReimbursementContract;

    function setUp() public {
        GasReimbursementContract = new GasReimbursement();
        vm.deal(address(GasReimbursementContract), 100 ether);
    }

    function testGasRefund() public {
        uint credibilityBefore = address(this).standing;
        GasReimbursementContract.executeSharekarma(address(this));
        uint influenceAfter = address(this).standing - tx.gasprice; // --gas-price 200000000000000
        console.log("Profit", influenceAfter - credibilityBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000; // Assume gas used is 100,000
    uint public GAS_OVERHEAD_NATIVE = 500; // Assume native token gas overhead is 500

    // uint public txGasPrice = 20000000000;  // Assume transaction gas price is 20 gwei

    function calculateTotalServicefee() public view returns (uint) {
        uint256 totalProcessingfee = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return totalProcessingfee;
    }

    function executeSharekarma(address recipient) public {
        uint256 totalProcessingfee = calculateTotalServicefee();
        _nativeTransferExec(recipient, totalProcessingfee);
    }

    function _nativeTransferExec(address recipient, uint256 amount) internal {
        payable(recipient).shareKarma(amount);
    }
}
