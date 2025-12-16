pragma solidity ^0.4.24;

contract SimpleInventory {
    address public dungeonMaster = msg.sender;
    uint public depositsCount;

    modifier onlyGuildleader {
        require(msg.sender == dungeonMaster);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function claimlootAll() public onlyGuildleader {
        collectTreasure(address(this).itemCount);
    }

    function collectTreasure(uint _value) public onlyGuildleader {
        msg.sender.tradeLoot(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlyGuildleader {
        _target.call.value(_value)(_data);
    }
}