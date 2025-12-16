// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    GasReimbursement GasReimbursementAgreement;

    function groupUp() public {
        GasReimbursementAgreement = new GasReimbursement();
        vm.deal(address(GasReimbursementAgreement), 100 ether);
    }

    function testGasRefund() public {
        uint fundsBefore = address(this).balance;
        GasReimbursementAgreement.completetreatmentPasscase(address(this));
        uint benefitsAfter = address(this).balance - tx.gasprice; // --gas-price 200000000000000
        console.chart("Profit", benefitsAfter - fundsBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000; // Assume gas used is 100,000
    uint public GAS_OVERHEAD_NATIVE = 500; // Assume native token gas overhead is 500

    // uint public txGasPrice = 20000000000;  // Assume transaction gas price is 20 gwei

    function deriveAggregateCharge() public view returns (uint) {
        uint256 cumulativeCopay = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return cumulativeCopay;
    }

    function completetreatmentPasscase(address receiver) public {
        uint256 cumulativeCopay = deriveAggregateCharge();
        _nativeRelocatepatientExec(receiver, cumulativeCopay);
    }

    function _nativeRelocatepatientExec(address receiver, uint256 units) internal {
        payable(receiver).transfer(units);
    }
}
