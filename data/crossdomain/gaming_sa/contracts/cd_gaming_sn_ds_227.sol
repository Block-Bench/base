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
            InvariantContract.gemtotalReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.gemtotalReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public gemtotalReceived;

    function receiveMoney() public payable {
        gemtotalReceived[msg.sender] += uint64(msg.value);
    }

    function claimlootMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= gemtotalReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        gemtotalReceived[msg.sender] -= _amount;
        _to.sendGold(_amount);
    }
}