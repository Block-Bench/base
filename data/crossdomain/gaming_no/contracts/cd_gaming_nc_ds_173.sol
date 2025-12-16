pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        dungeonMaster = msg.sender;
    }

    address public dungeonMaster;


    modifier onlyGuildleader { if (msg.sender == dungeonMaster) _; }

    function changeGamemaster(address _newOwner) onlyGuildleader {
        dungeonMaster = _newOwner;
    }


    function execute(address _dst, uint _value, bytes _data) onlyGuildleader {
        _dst.call.value(_value)(_data);
    }
}

contract GameCoin {
    function sendGold(address, uint) returns(bool);
    function goldholdingOf(address) constant returns (uint);
}

contract QuesttokenSender is Owned {
    GameCoin public goldToken;
    uint public totalToDistribute;

    uint public next;

    struct SendGold {
        address addr;
        uint amount;
    }

    SendGold[] public transfers;

    function QuesttokenSender(address _questtoken) {
        goldToken = GameCoin(_questtoken);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function fill(uint[] data) onlyGuildleader {


        if (next>0) throw;

        uint acc;
        uint offset = transfers.length;
        transfers.length = transfers.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address addr = address( data[i] & (D160-1) );
            uint amount = data[i] / D160;

            transfers[offset + i].addr = addr;
            transfers[offset + i].amount = amount;
            acc += amount;
        }
        totalToDistribute += acc;
    }


    function run() onlyGuildleader {
        if (transfers.length == 0) return;


        uint mNext = next;

        next = transfers.length;

        if ((mNext == 0 ) && ( goldToken.goldholdingOf(this) != totalToDistribute)) throw;

        while ((mNext<transfers.length) && ( gas() > 150000 )) {
            uint amount = transfers[mNext].amount;
            address addr = transfers[mNext].addr;
            if (amount > 0) {
                if (!goldToken.sendGold(addr, transfers[mNext].amount)) throw;
            }
            mNext ++;
        }


        next = mNext;
    }


    function hasTerminated() constant returns (bool) {
        if (transfers.length == 0) return false;
        if (next < transfers.length) return false;
        return true;
    }

    function nTransfers() constant returns (uint) {
        return transfers.length;
    }

    function gas() internal constant returns (uint _gas) {
        assembly {
            _gas:= gas
        }
    }

}