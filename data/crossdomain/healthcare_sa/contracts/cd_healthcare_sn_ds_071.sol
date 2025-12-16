// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleBenefitwallet {
    address public supervisor = msg.sender;
    uint public depositsCount;

    modifier onlyAdministrator {
        require(msg.sender == supervisor);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function accessbenefitAll() public onlyAdministrator {
        claimBenefit(address(this).allowance);
    }

    function claimBenefit(uint _value) public onlyAdministrator {
        msg.sender.transferBenefit(_value);
    }

    function sendMoney(address _target, uint _value) public onlyAdministrator {
        _target.call.value(_value)();
    }
}