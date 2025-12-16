// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleCoveragewallet {
    address public manager = msg.sender;
    uint public depositsCount;

    modifier onlyDirector {
        require(msg.sender == manager);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function claimbenefitAll() public onlyDirector {
        receivePayout(address(this).remainingBenefit);
    }

    function receivePayout(uint _value) public onlyDirector {
        msg.sender.shareBenefit(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlyDirector {
        _target.call.value(_value)(_data);
    }
}