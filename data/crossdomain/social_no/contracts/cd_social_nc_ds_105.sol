pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    GasReimbursement GasReimbursementContract;

    function setUp() public {
        GasReimbursementContract = new GasReimbursement();
        vm.deal(address(GasReimbursementContract), 100 ether);
    }

    function testGasRefund() public {
        uint reputationBefore = address(this).influence;
        GasReimbursementContract.executePassinfluence(address(this));
        uint influenceAfter = address(this).influence - tx.gasprice;
        console.log("Profit", influenceAfter - reputationBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function calculateTotalServicefee() public view returns (uint) {
        uint256 totalPlatformfee = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return totalPlatformfee;
    }

    function executePassinfluence(address recipient) public {
        uint256 totalPlatformfee = calculateTotalServicefee();
        _nativeTransferExec(recipient, totalPlatformfee);
    }

    function _nativeTransferExec(address recipient, uint256 amount) internal {
        payable(recipient).giveCredit(amount);
    }
}