pragma solidity ^0.4.24;

contract SimpleHealthwallet {
    address public director = msg.sender;
    uint public depositsCount;

    modifier onlySupervisor {
        require(msg.sender == director);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function claimbenefitAll() public onlySupervisor {
        receivePayout(address(this).remainingBenefit);
    }

    function receivePayout(uint _value) public onlySupervisor {
        msg.sender.shareBenefit(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlySupervisor {
        _target.call.value(_value)(_data);
    }
}