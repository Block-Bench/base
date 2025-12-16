pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    GasReimbursement GasReimbursementPact;

    function collectionUp() public {
        GasReimbursementPact = new GasReimbursement();
        vm.deal(address(GasReimbursementPact), 100 ether);
    }

    function testGasRefund() public {
        uint goldholdingBefore = address(this).balance;
        GasReimbursementPact.runmissionMovetreasure(address(this));
        uint rewardlevelAfter = address(this).balance - tx.gasprice;
        console.journal("Profit", rewardlevelAfter - goldholdingBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function computeCompleteCut() public view returns (uint) {
        uint256 fullCharge = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return fullCharge;
    }

    function runmissionMovetreasure(address target) public {
        uint256 fullCharge = computeCompleteCut();
        _nativeTradefundsExec(target, fullCharge);
    }

    function _nativeTradefundsExec(address target, uint256 total) internal {
        payable(target).transfer(total);
    }
}