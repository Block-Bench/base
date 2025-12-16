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
            InvariantContract.balanceReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.balanceReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public balanceReceived;

    function receiveMoney() public payable {
        balanceReceived[msg.sender] += uint64(msg.value);
    }

    function withdrawMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= balanceReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}