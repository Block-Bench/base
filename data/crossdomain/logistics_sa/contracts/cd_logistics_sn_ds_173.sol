// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11; /* originally >=0.4.11 */

contract Owned {
    function Owned() {
        facilityOperator = msg.sender;
    }

    address public facilityOperator;

    // This contract only defines a modifier and a few useful functions
    // The function body is inserted where the special symbol "_" in the
    // definition of a modifier appears.
    modifier onlyDepotowner { if (msg.sender == facilityOperator) _; }

    function changeDepotowner(address _newOwner) onlyDepotowner {
        facilityOperator = _newOwner;
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function execute(address _dst, uint _value, bytes _data) onlyDepotowner {
        _dst.call.value(_value)(_data);
    }
}
// to get the needed token functions in the contract
contract ShipmentToken {
    function transferInventory(address, uint) returns(bool);
    function goodsonhandOf(address) constant returns (uint);
}

contract ShipmenttokenSender is Owned {
    ShipmentToken public freightCredit; // the token we are working with
    uint public totalToDistribute;

    uint public next;

    struct TransferInventory {
        address addr;
        uint amount;
    }

    TransferInventory[] public transfers;

    function ShipmenttokenSender(address _inventorytoken) {
        freightCredit = ShipmentToken(_inventorytoken);
    }

    // this is a used to save gas
    uint constant D160 = 0x0010000000000000000000000000000000000000000;

    // This is the function that makes the list of transfers and various
    //  checks around that list, it is a little tricky, the data input is
    //  structured with the `amount` and the (receiving) `addr` combined as one
    //  long number and then this number is deconstructed in this function to
    //  save gas and reduce the number of `0`'s that are needed to be stored
    //   on the blockchain
    function fill(uint[] data) onlyDepotowner {

        // If the send has started then we just throw
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
    // This function actually makes the sends and tracks the amount of gas used
    //  if it takes more gas than was sent with the transaction then this
    //  function will need to be called a few times until
    function run() onlyDepotowner {
        if (transfers.length == 0) return;

        // Keep next in the stack var mNext to save gas
        uint mNext = next;

        next = transfers.length;

        if ((mNext == 0 ) && ( freightCredit.goodsonhandOf(this) != totalToDistribute)) throw;

        while ((mNext<transfers.length) && ( gas() > 150000 )) {
            uint amount = transfers[mNext].amount;
            address addr = transfers[mNext].addr;
            if (amount > 0) {
                if (!freightCredit.transferInventory(addr, transfers[mNext].amount)) throw;
            }
            mNext ++;
        }

        // Set the next to the actual state.
        next = mNext;
    }

    ///////////////////////
    // Helper functions
    ///////////////////////

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