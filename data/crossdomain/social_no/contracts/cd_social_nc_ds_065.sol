pragma solidity ^0.4.16;


contract Owned {


    modifier onlyAdmin() {
        require(msg.sender == groupOwner);
        _;
    }

    address public groupOwner;


    function Owned() {
        groupOwner = msg.sender;
    }

    address public newAdmin;


    function changeAdmin(address _newOwner) onlyAdmin {
        newAdmin = _newOwner;
    }


    function acceptOwnership() {
        if (msg.sender == newAdmin) {
            groupOwner = newAdmin;
        }
    }


    function execute(address _dst, uint _value, bytes _data) onlyAdmin {
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