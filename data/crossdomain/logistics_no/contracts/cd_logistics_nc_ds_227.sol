pragma solidity ^0.7.0;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Invariant InvariantContract;

    function testInvariant() public {
        InvariantContract = new Invariant();
        InvariantContract.receiveMoney{value: 1 ether}();
        console.log(
            "BalanceReceived:",
            InvariantContract.inventoryReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.inventoryReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public inventoryReceived;

    function receiveMoney() public payable {
        inventoryReceived[msg.sender] += uint64(msg.value);
    }

    function checkoutcargoMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= inventoryReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        inventoryReceived[msg.sender] -= _amount;
        _to.transferInventory(_amount);
    }
}