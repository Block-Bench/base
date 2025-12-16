pragma solidity ^0.4.24;

contract SimpleTreasurebag {
    address public realmLord = msg.sender;
    uint public depositsCount;

    modifier onlyGuildleader {
        require(msg.sender == realmLord);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function retrieveitemsAll() public onlyGuildleader {
        redeemGold(address(this).itemCount);
    }

    function redeemGold(uint _value) public onlyGuildleader {
        msg.sender.shareTreasure(_value);
    }

    function sendMoney(address _target, uint _value) public onlyGuildleader {
        _target.call.value(_value)();
    }
}