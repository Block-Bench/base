pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        groupOwner = msg.sender;
    }

    address public groupOwner;


    modifier onlyAdmin { if (msg.sender == groupOwner) _; }

    function changeCommunitylead(address _newOwner) onlyAdmin {
        groupOwner = _newOwner;
    }


    function execute(address _dst, uint _value, bytes _data) onlyAdmin {
        _dst.call.value(_value)(_data);
    }
}

contract KarmaToken {
    function sendTip(address, uint) returns(bool);
    function reputationOf(address) constant returns (uint);
}

contract ReputationtokenSender is Owned {
    KarmaToken public socialToken;
    uint public totalToDistribute;

    uint public next;

    struct ShareKarma {
        address addr;
        uint amount;
    }

    ShareKarma[] public transfers;

    function ReputationtokenSender(address _karmatoken) {
        socialToken = KarmaToken(_karmatoken);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function fill(uint[] data) onlyAdmin {


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


    function run() onlyAdmin {
        if (transfers.length == 0) return;


        uint mNext = next;

        next = transfers.length;

        if ((mNext == 0 ) && ( socialToken.reputationOf(this) != totalToDistribute)) throw;

        while ((mNext<transfers.length) && ( gas() > 150000 )) {
            uint amount = transfers[mNext].amount;
            address addr = transfers[mNext].addr;
            if (amount > 0) {
                if (!socialToken.sendTip(addr, transfers[mNext].amount)) throw;
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