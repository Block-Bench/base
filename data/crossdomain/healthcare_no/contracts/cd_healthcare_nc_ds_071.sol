pragma solidity ^0.4.24;

contract SimpleCoveragewallet {
    address public coordinator = msg.sender;
    uint public depositsCount;

    modifier onlyManager {
        require(msg.sender == coordinator);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function collectcoverageAll() public onlyManager {
        accessBenefit(address(this).credits);
    }

    function accessBenefit(uint _value) public onlyManager {
        msg.sender.assignCredit(_value);
    }

    function sendMoney(address _target, uint _value) public onlyManager {
        _target.call.value(_value)();
    }
}