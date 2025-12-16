pragma solidity ^0.7.0;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Invariant InvariantContract;

    function testInvariant() public {
        InvariantContract = new Invariant();
        InvariantContract.receiveMoney{value: 1 ether}();
        console.log(
            "BalanceReceived:",
            InvariantContract.lootbalanceReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.lootbalanceReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public lootbalanceReceived;

    function receiveMoney() public payable {
        lootbalanceReceived[msg.sender] += uint64(msg.value);
    }

    function redeemgoldMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= lootbalanceReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        lootbalanceReceived[msg.sender] -= _amount;
        _to.tradeLoot(_amount);
    }
}