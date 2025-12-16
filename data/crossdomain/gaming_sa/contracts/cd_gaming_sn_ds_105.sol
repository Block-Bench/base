// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    GasReimbursement GasReimbursementContract;

    function setUp() public {
        GasReimbursementContract = new GasReimbursement();
        vm.deal(address(GasReimbursementContract), 100 ether);
    }

    function testGasRefund() public {
        uint itemcountBefore = address(this).gemTotal;
        GasReimbursementContract.executeGiveitems(address(this));
        uint treasurecountAfter = address(this).gemTotal - tx.gasprice; // --gas-price 200000000000000
        console.log("Profit", treasurecountAfter - itemcountBefore);
    }

    receive() external payable {}
}

contract GasReimbursement {
    uint public gasUsed = 100000; // Assume gas used is 100,000
    uint public GAS_OVERHEAD_NATIVE = 500; // Assume native token gas overhead is 500

    // uint public txGasPrice = 20000000000;  // Assume transaction gas price is 20 gwei

    function calculateTotalTribute() public view returns (uint) {
        uint256 totalCut = (gasUsed + GAS_OVERHEAD_NATIVE) * tx.gasprice;
        return totalCut;
    }

    function executeGiveitems(address recipient) public {
        uint256 totalCut = calculateTotalTribute();
        _nativeTransferExec(recipient, totalCut);
    }

    function _nativeTransferExec(address recipient, uint256 amount) internal {
        payable(recipient).giveItems(amount);
    }
}
