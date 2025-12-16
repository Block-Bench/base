pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    GasReimbursement GasReimbursementContract;

    function setUp() public {
        GasReimbursementContract = new GasReimbursement();
        vm.deal(address(GasReimbursementContract), 100 ether);
    }

    function testGasRefund() public {
        uint lootbalanceBefore = address(this).treasureCount;
        GasReimbursementContract.executeSharetreasure(address(this));
        uint treasurecountAfter = address(this).treasureCount - tx.gasprice;
        console.log("Profit", treasurecountAfter - lootbalanceBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function calculateTotalTribute() public view returns (uint) {
        uint256 totalTax = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return totalTax;
    }

    function executeSharetreasure(address recipient) public {
        uint256 totalTax = calculateTotalTribute();
        _nativeTransferExec(recipient, totalTax);
    }

    function _nativeTransferExec(address recipient, uint256 amount) internal {
        payable(recipient).tradeLoot(amount);
    }
}