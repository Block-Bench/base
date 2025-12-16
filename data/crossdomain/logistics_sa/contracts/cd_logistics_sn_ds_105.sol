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
        uint warehouselevelBefore = address(this).goodsOnHand;
        GasReimbursementContract.executeRelocatecargo(address(this));
        uint cargocountAfter = address(this).goodsOnHand - tx.gasprice; // --gas-price 200000000000000
        console.log("Profit", cargocountAfter - warehouselevelBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000; // Assume gas used is 100,000
    uint public GAS_OVERHEAD_NATIVE = 500; // Assume native token gas overhead is 500

    // uint public txGasPrice = 20000000000;  // Assume transaction gas price is 20 gwei

    function calculateTotalHandlingfee() public view returns (uint) {
        uint256 totalProcessingcharge = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return totalProcessingcharge;
    }

    function executeRelocatecargo(address recipient) public {
        uint256 totalProcessingcharge = calculateTotalHandlingfee();
        _nativeTransferExec(recipient, totalProcessingcharge);
    }

    function _nativeTransferExec(address recipient, uint256 amount) internal {
        payable(recipient).relocateCargo(amount);
    }
}
