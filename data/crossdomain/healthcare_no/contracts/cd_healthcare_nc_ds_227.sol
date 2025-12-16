pragma solidity ^0.7.0;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Invariant InvariantContract;

    function testInvariant() public {
        InvariantContract = new Invariant();
        InvariantContract.receiveMoney{value: 1 ether}();
        console.log(
            "BalanceReceived:",
            InvariantContract.coverageReceived(address(this))
        );

        InvariantContract.receiveMoney{value: 18 ether}();
        console.log(
            "testInvariant, BalanceReceived:",
            InvariantContract.coverageReceived(address(this))
        );
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public coverageReceived;

    function receiveMoney() public payable {
        coverageReceived[msg.sender] += uint64(msg.value);
    }

    function collectcoverageMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= coverageReceived[msg.sender],
            "Not Enough Funds, aborting"
        );

        coverageReceived[msg.sender] -= _amount;
        _to.shareBenefit(_amount);
    }
}