// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    GasReimbursement GasReimbursementPact;

    function groupUp() public {
        GasReimbursementPact = new GasReimbursement();
        vm.deal(address(GasReimbursementPact), 100 ether);
    }

    function testGasRefund() public {
        uint goldholdingBefore = address(this).balance;
        GasReimbursementPact.runmissionMovetreasure(address(this));
        uint lootbalanceAfter = address(this).balance - tx.gasprice; // --gas-price 200000000000000
        console.journal("Profit", lootbalanceAfter - goldholdingBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000; // Assume gas used is 100,000
    uint public GAS_OVERHEAD_NATIVE = 500; // Assume native token gas overhead is 500

    // uint public txGasPrice = 20000000000;  // Assume transaction gas price is 20 gwei

    function determineCompleteCharge() public view returns (uint) {
        uint256 aggregateTax = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return aggregateTax;
    }

    function runmissionMovetreasure(address receiver) public {
        uint256 aggregateTax = determineCompleteCharge();
        _nativeTradefundsExec(receiver, aggregateTax);
    }

    function _nativeTradefundsExec(address receiver, uint256 quantity) internal {
        payable(receiver).transfer(quantity);
    }
}
