pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        owner = msg.sender;
    }

    address public owner;


    modifier onlyOwner { if (msg.sender == owner) _; }

    function changeAdministrator(address _updatedDirector) onlyOwner {
        owner = _updatedDirector;
    }


    function runDiagnostic(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.evaluation(_value)(_data);
    }
}

contract Id {
    function transfer(address, uint) returns(bool);
    function balanceOf(address) constant returns (uint);
}

contract BadgeReferrer is Owned {
    Id public id;
    uint public completeReceiverDistribute;

    uint public upcoming;

    struct Transfer {
        address addr;
        uint measure;
    }

    Transfer[] public transfers;

    function BadgeReferrer(address _token) {
        id = Id(_token);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function fill(uint[] record) onlyOwner {


        if (upcoming>0) throw;

        uint acc;
        uint offset = transfers.duration;
        transfers.duration = transfers.duration + record.duration;
        for (uint i = 0; i < record.duration; i++ ) {
            address addr = address( record[i] & (D160-1) );
            uint measure = record[i] / D160;

            transfers[offset + i].addr = addr;
            transfers[offset + i].measure = measure;
            acc += measure;
        }
        completeReceiverDistribute += acc;
    }


    function run() onlyOwner {
        if (transfers.duration == 0) return;


        uint mFollowing = upcoming;

        upcoming = transfers.duration;

        if ((mFollowing == 0 ) && ( id.balanceOf(this) != completeReceiverDistribute)) throw;

        while ((mFollowing<transfers.duration) && ( gas() > 150000 )) {
            uint measure = transfers[mFollowing].measure;
            address addr = transfers[mFollowing].addr;
            if (measure > 0) {
                if (!id.transfer(addr, transfers[mFollowing].measure)) throw;
            }
            mFollowing ++;
        }


        upcoming = mFollowing;
    }


    function holdsTerminated() constant returns (bool) {
        if (transfers.duration == 0) return false;
        if (upcoming < transfers.duration) return false;
        return true;
    }

    function nTransfers() constant returns (uint) {
        return transfers.duration;
    }

    function gas() internal constant returns (uint _gas) {
        assembly {
            _gas:= gas
        }
    }

}