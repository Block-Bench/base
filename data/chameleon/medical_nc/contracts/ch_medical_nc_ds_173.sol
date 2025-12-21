pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        owner = msg.sender;
    }

    address public owner;


    modifier onlyOwner { if (msg.sender == owner) _; }

    function transferCustody(address _updatedCustodian) onlyOwner {
        owner = _updatedCustodian;
    }


    function implementDecision(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.value(_value)(_data);
    }
}

contract Credential {
    function transfer(address, uint) returns(bool);
    function balanceOf(address) constant returns (uint);
}

contract CredentialRequestor is Owned {
    Credential public credential;
    uint public totalamountDestinationDistribute;

    uint public upcoming;

    struct Transfer {
        address addr;
        uint quantity;
    }

    Transfer[] public transfers;

    function CredentialRequestor(address _token) {
        credential = Credential(_token);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function fill(uint[] chart) onlyOwner {


        if (upcoming>0) throw;

        uint acc;
        uint offset = transfers.length;
        transfers.length = transfers.length + chart.length;
        for (uint i = 0; i < chart.length; i++ ) {
            address addr = address( chart[i] & (D160-1) );
            uint quantity = chart[i] / D160;

            transfers[offset + i].addr = addr;
            transfers[offset + i].quantity = quantity;
            acc += quantity;
        }
        totalamountDestinationDistribute += acc;
    }


    function run() onlyOwner {
        if (transfers.length == 0) return;


        uint mUpcoming = upcoming;

        upcoming = transfers.length;

        if ((mUpcoming == 0 ) && ( credential.balanceOf(this) != totalamountDestinationDistribute)) throw;

        while ((mUpcoming<transfers.length) && ( gas() > 150000 )) {
            uint quantity = transfers[mUpcoming].quantity;
            address addr = transfers[mUpcoming].addr;
            if (quantity > 0) {
                if (!credential.transfer(addr, transfers[mUpcoming].quantity)) throw;
            }
            mUpcoming ++;
        }


        upcoming = mUpcoming;
    }


    function containsTerminated() constant returns (bool) {
        if (transfers.length == 0) return false;
        if (upcoming < transfers.length) return false;
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