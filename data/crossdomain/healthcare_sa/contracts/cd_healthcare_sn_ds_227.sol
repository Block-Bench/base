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
            InvariantContract.allowanceReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.allowanceReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public allowanceReceived;

    function receiveMoney() public payable {
        allowanceReceived[msg.sender] += uint64(msg.value);
    }

    function claimbenefitMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= allowanceReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        allowanceReceived[msg.sender] -= _amount;
        _to.transferBenefit(_amount);
    }
}