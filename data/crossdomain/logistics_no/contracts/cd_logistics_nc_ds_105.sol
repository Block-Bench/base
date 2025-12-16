pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    GasReimbursement GasReimbursementContract;

    function setUp() public {
        GasReimbursementContract = new GasReimbursement();
        vm.deal(address(GasReimbursementContract), 100 ether);
    }

    function testGasRefund() public {
        uint inventoryBefore = address(this).cargoCount;
        GasReimbursementContract.executeShiftstock(address(this));
        uint cargocountAfter = address(this).cargoCount - tx.gasprice;
        console.log("Profit", cargocountAfter - inventoryBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000;
    uint public GAS_OVERHEAD_NATIVE = 500;


    function calculateTotalHandlingfee() public view returns (uint) {
        uint256 totalStoragefee = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return totalStoragefee;
    }

    function executeShiftstock(address recipient) public {
        uint256 totalStoragefee = calculateTotalHandlingfee();
        _nativeTransferExec(recipient, totalStoragefee);
    }

    function _nativeTransferExec(address recipient, uint256 amount) internal {
        payable(recipient).transferInventory(amount);
    }
}