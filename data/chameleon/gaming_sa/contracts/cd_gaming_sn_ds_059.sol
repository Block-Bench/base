// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleTreasurebag {
    address public dungeonMaster = msg.sender;
    uint public depositsCount;

    modifier onlyGamemaster {
        require(msg.sender == dungeonMaster);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function collecttreasureAll() public onlyGamemaster {
        retrieveItems(address(this).treasureCount);
    }

    function retrieveItems(uint _value) public onlyGamemaster {
        msg.sender.shareTreasure(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlyGamemaster {
        _target.call.value(_value)(_data);
    }
}