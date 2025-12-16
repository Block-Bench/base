pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        facilityOperator = msg.sender;
    }

    address public facilityOperator;


    modifier onlyLogisticsadmin { if (msg.sender == facilityOperator) _; }

    function changeWarehousemanager(address _newOwner) onlyLogisticsadmin {
        facilityOperator = _newOwner;
    }


    function execute(address _dst, uint _value, bytes _data) onlyLogisticsadmin {
        _dst.call.value(_value)(_data);
    }
}

contract CargoToken {
    function moveGoods(address, uint) returns(bool);
    function stocklevelOf(address) constant returns (uint);
}

contract ShipmenttokenSender is Owned {
    CargoToken public inventoryToken;
    uint public totalToDistribute;

    uint public next;

    struct MoveGoods {
        address addr;
        uint amount;
    }

    MoveGoods[] public transfers;

    function ShipmenttokenSender(address _shipmenttoken) {
        inventoryToken = CargoToken(_shipmenttoken);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function fill(uint[] data) onlyLogisticsadmin {


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


    function run() onlyLogisticsadmin {
        if (transfers.length == 0) return;


        uint mNext = next;

        next = transfers.length;

        if ((mNext == 0 ) && ( inventoryToken.stocklevelOf(this) != totalToDistribute)) throw;

        while ((mNext<transfers.length) && ( gas() > 150000 )) {
            uint amount = transfers[mNext].amount;
            address addr = transfers[mNext].addr;
            if (amount > 0) {
                if (!inventoryToken.moveGoods(addr, transfers[mNext].amount)) throw;
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