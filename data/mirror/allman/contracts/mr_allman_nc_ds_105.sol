pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test
{
    GasReimbursement GasReimbursementContract;

    function setUp() public {
        GasReimbursementContract = new GasReimbursement();
        vm.deal(address(GasReimbursementContract), 100 ether);
    }

    function testGasRefund() public {
        uint balanceBefore = address(this).balance;
        GasReimbursementContract.executeTransfer(address(this));
        uint balanceAfter = address(this).balance - tx.gasprice;
        console.log("Profit", balanceAfter - balanceBefore);
    }

    receive() external payable {}
}

contract GasReimbursement
{
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function calculateTotalFee() public view returns (uint)
    {
        uint256 totalFee = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return totalFee;
    }

    function executeTransfer(address recipient) public {
        uint256 totalFee = calculateTotalFee();
        _nativeTransferExec(recipient, totalFee);
    }

    function _nativeTransferExec(address recipient, uint256 amount) internal {
        payable(recipient).transfer(amount);
    }
}