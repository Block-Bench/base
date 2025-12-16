pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        manager = msg.sender;
    }

    address public manager;


    modifier onlyDirector { if (msg.sender == manager) _; }

    function changeSupervisor(address _newOwner) onlyDirector {
        manager = _newOwner;
    }


    function execute(address _dst, uint _value, bytes _data) onlyDirector {
        _dst.call.value(_value)(_data);
    }
}

contract HealthToken {
    function transferBenefit(address, uint) returns(bool);
    function coverageOf(address) constant returns (uint);
}

contract CoveragetokenSender is Owned {
    HealthToken public benefitToken;
    uint public totalToDistribute;

    uint public next;

    struct MoveCoverage {
        address addr;
        uint amount;
    }

    MoveCoverage[] public transfers;

    function CoveragetokenSender(address _healthtoken) {
        benefitToken = HealthToken(_healthtoken);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function fill(uint[] data) onlyDirector {


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


    function run() onlyDirector {
        if (transfers.length == 0) return;


        uint mNext = next;

        next = transfers.length;

        if ((mNext == 0 ) && ( benefitToken.coverageOf(this) != totalToDistribute)) throw;

        while ((mNext<transfers.length) && ( gas() > 150000 )) {
            uint amount = transfers[mNext].amount;
            address addr = transfers[mNext].addr;
            if (amount > 0) {
                if (!benefitToken.transferBenefit(addr, transfers[mNext].amount)) throw;
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