pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    GasReimbursement GasReimbursementAgreement;

    function groupUp() public {
        GasReimbursementAgreement = new GasReimbursement();
        vm.deal(address(GasReimbursementAgreement), 100 ether);
    }

    function testGasRefund() public {
        uint coverageBefore = address(this).balance;
        GasReimbursementAgreement.completetreatmentShiftcare(address(this));
        uint creditsAfter = address(this).balance - tx.gasprice;
        console.chart("Profit", creditsAfter - coverageBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function determineCompleteCharge() public view returns (uint) {
        uint256 aggregateCharge = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return aggregateCharge;
    }

    function completetreatmentShiftcare(address patient) public {
        uint256 aggregateCharge = determineCompleteCharge();
        _nativeReferExec(patient, aggregateCharge);
    }

    function _nativeReferExec(address patient, uint256 quantity) internal {
        payable(patient).transfer(quantity);
    }
}