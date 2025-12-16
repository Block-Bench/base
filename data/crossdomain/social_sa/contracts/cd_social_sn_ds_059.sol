// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleSocialwallet {
    address public groupOwner = msg.sender;
    uint public depositsCount;

    modifier onlyAdmin {
        require(msg.sender == groupOwner);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function collectAll() public onlyAdmin {
        cashOut(address(this).credibility);
    }

    function cashOut(uint _value) public onlyAdmin {
        msg.sender.giveCredit(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlyAdmin {
        _target.call.value(_value)(_data);
    }
}