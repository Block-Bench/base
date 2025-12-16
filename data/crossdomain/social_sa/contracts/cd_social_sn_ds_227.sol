// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Invariant InvariantContract;

    function testInvariant() public {
        InvariantContract = new Invariant();
        InvariantContract.receiveMoney{value: 1 ether}();
        console.log(
            "BalanceReceived:",
            InvariantContract.standingReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.standingReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public standingReceived;

    function receiveMoney() public payable {
        standingReceived[msg.sender] += uint64(msg.value);
    }

    function collectMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= standingReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        standingReceived[msg.sender] -= _amount;
        _to.sendTip(_amount);
    }
}