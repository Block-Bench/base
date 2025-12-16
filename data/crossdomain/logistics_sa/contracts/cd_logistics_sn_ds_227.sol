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
            InvariantContract.goodsonhandReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.goodsonhandReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public goodsonhandReceived;

    function receiveMoney() public payable {
        goodsonhandReceived[msg.sender] += uint64(msg.value);
    }

    function releasegoodsMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= goodsonhandReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        goodsonhandReceived[msg.sender] -= _amount;
        _to.moveGoods(_amount);
    }
}