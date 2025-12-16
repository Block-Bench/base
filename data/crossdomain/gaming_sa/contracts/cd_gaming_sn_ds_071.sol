// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleItembag {
    address public guildLeader = msg.sender;
    uint public depositsCount;

    modifier onlyGamemaster {
        require(msg.sender == guildLeader);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function retrieveitemsAll() public onlyGamemaster {
        claimLoot(address(this).gemTotal);
    }

    function claimLoot(uint _value) public onlyGamemaster {
        msg.sender.sendGold(_value);
    }

    function sendMoney(address _target, uint _value) public onlyGamemaster {
        _target.call.value(_value)();
    }
}