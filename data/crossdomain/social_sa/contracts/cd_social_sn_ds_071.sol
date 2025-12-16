// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleRewardwallet {
    address public communityLead = msg.sender;
    uint public depositsCount;

    modifier onlyModerator {
        require(msg.sender == communityLead);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function claimearningsAll() public onlyModerator {
        collect(address(this).standing);
    }

    function collect(uint _value) public onlyModerator {
        msg.sender.sendTip(_value);
    }

    function sendMoney(address _target, uint _value) public onlyModerator {
        _target.call.value(_value)();
    }
}