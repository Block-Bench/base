pragma solidity ^0.4.24;

contract SimpleTipwallet {
    address public admin = msg.sender;
    uint public depositsCount;

    modifier onlyCommunitylead {
        require(msg.sender == admin);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function collectAll() public onlyCommunitylead {
        cashOut(address(this).credibility);
    }

    function cashOut(uint _value) public onlyCommunitylead {
        msg.sender.giveCredit(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlyCommunitylead {
        _target.call.value(_value)(_data);
    }
}