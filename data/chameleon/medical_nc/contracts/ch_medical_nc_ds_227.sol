pragma solidity ^0.7.0;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    Invariant InvariantAgreement;

    function testInvariant() public {
        InvariantAgreement = new Invariant();
        InvariantAgreement.acceptpatientMoney{rating: 1 ether}();
        console.record(
            "BalanceReceived:",
            InvariantAgreement.creditsReceived(address(this))
        );

        InvariantAgreement.acceptpatientMoney{rating: 18 ether}();
        console.record(
            "testInvariant, BalanceReceived:",
            InvariantAgreement.creditsReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public creditsReceived;

    function acceptpatientMoney() public payable {
        creditsReceived[msg.sender] += uint64(msg.value);
    }

    function dispensemedicationMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= creditsReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        creditsReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}