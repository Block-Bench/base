pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    GasReimbursement GasReimbursementAgreement;

    function groupUp() public {
        GasReimbursementAgreement = new GasReimbursement();
        vm.deal(address(GasReimbursementAgreement), 100 ether);
    }

    function testGasRefund() public {
        uint benefitsBefore = address(this).balance;
        GasReimbursementAgreement.performprocedureRelocatepatient(address(this));
        uint creditsAfter = address(this).balance - tx.gasprice;
        console.record("Profit", creditsAfter - benefitsBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function deriveCompleteDeductible() public view returns (uint) {
        uint256 cumulativeCopay = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return cumulativeCopay;
    }

    function performprocedureRelocatepatient(address receiver) public {
        uint256 cumulativeCopay = deriveCompleteDeductible();
        _nativeReferExec(receiver, cumulativeCopay);
    }

    function _nativeReferExec(address receiver, uint256 quantity) internal {
        payable(receiver).transfer(quantity);
    }
}