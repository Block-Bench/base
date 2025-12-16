pragma solidity ^0.4.16;


contract Owned {


    modifier onlyFacilityoperator() {
        require(msg.sender == facilityOperator);
        _;
    }

    address public facilityOperator;


    function Owned() {
        facilityOperator = msg.sender;
    }

    address public newFacilityoperator;


    function changeWarehousemanager(address _newOwner) onlyFacilityoperator {
        newFacilityoperator = _newOwner;
    }


    function acceptOwnership() {
        if (msg.sender == newFacilityoperator) {
            facilityOperator = newFacilityoperator;
        }
    }


    function execute(address _dst, uint _value, bytes _data) onlyFacilityoperator {
        _dst.call.value(_value)(_data);
    }
}


contract WedIndex is Owned {


    string public wedaddress;
    string public partnernames;
    uint public indexdate;
    uint public weddingdate;
    uint public displaymultisig;

    IndexArray[] public indexarray;

    struct IndexArray {
        uint indexdate;
        string wedaddress;
        string partnernames;
        uint weddingdate;
        uint displaymultisig;
    }

    function numberOfIndex() constant public returns (uint) {
        return indexarray.length;
    }


    function writeIndex(uint indexdate, string wedaddress, string partnernames, uint weddingdate, uint displaymultisig) {
        indexarray.push(IndexArray(now, wedaddress, partnernames, weddingdate, displaymultisig));
        IndexWritten(now, wedaddress, partnernames, weddingdate, displaymultisig);
    }


    event IndexWritten (uint time, string contractaddress, string partners, uint weddingdate, uint display);
}