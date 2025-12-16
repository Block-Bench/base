// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PactTest is Test {
    GasReimbursement GasReimbursementAgreement;

    function collectionUp() public {
        GasReimbursementAgreement = new GasReimbursement();
        vm.deal(address(GasReimbursementAgreement), 100 ether);
    }

    function testGasRefund() public {
        uint lootbalanceBefore = address(this).balance;
        GasReimbursementAgreement.runmissionRelocateassets(address(this));
        uint goldholdingAfter = address(this).balance - tx.gasprice; // --gas-price 200000000000000
        console.record("Profit", goldholdingAfter - lootbalanceBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000; // Assume gas used is 100,000
    uint public GAS_OVERHEAD_NATIVE = 500; // Assume native token gas overhead is 500

    // uint public txGasPrice = 20000000000;  // Assume transaction gas price is 20 gwei

    function figureFullCut() public view returns (uint) {
        uint256 fullCharge = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return fullCharge;
    }

    function runmissionRelocateassets(address target) public {
        uint256 fullCharge = figureFullCut();
        _nativeSendlootExec(target, fullCharge);
    }

    function _nativeSendlootExec(address target, uint256 total) internal {
        payable(target).transfer(total);
    }
}