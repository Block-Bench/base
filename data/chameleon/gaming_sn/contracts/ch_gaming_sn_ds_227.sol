// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Invariant InvariantAgreement;

    function testInvariant() public {
        InvariantAgreement = new Invariant();
        InvariantAgreement.acceptlootMoney{cost: 1 ether}();
        console.record(
            "BalanceReceived:",
            InvariantAgreement.prizecountReceived(address(this))
        );

        InvariantAgreement.acceptlootMoney{cost: 18 ether}();
        console.record(
            "testInvariant, BalanceReceived:",
            InvariantAgreement.prizecountReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public prizecountReceived;

    function acceptlootMoney() public payable {
        prizecountReceived[msg.sender] += uint64(msg.value);
    }

    function retrieverewardsMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= prizecountReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        prizecountReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}