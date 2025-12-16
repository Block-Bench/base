pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    GasReimbursement GasReimbursementAgreement;

    function groupUp() public {
        GasReimbursementAgreement = new GasReimbursement();
        vm.deal(address(GasReimbursementAgreement), 100 ether);
    }

    function testGasRefund() public {
        uint lootbalanceBefore = address(this).balance;
        GasReimbursementAgreement.performactionSendloot(address(this));
        uint goldholdingAfter = address(this).balance - tx.gasprice;
        console.record("Profit", goldholdingAfter - lootbalanceBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function computeCompleteTribute() public view returns (uint) {
        uint256 completeTribute = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return completeTribute;
    }

    function performactionSendloot(address receiver) public {
        uint256 completeTribute = computeCompleteTribute();
        _nativeRelocateassetsExec(receiver, completeTribute);
    }

    function _nativeRelocateassetsExec(address receiver, uint256 sum) internal {
        payable(receiver).transfer(sum);
    }
}