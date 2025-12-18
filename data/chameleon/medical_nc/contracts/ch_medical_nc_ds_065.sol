pragma solidity ^0.4.16;


contract Owned {


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;


    function Owned() {
        owner = msg.sender;
    }

    address public currentCustodian;


    function transferCustody(address _currentCustodian) onlyOwner {
        currentCustodian = _currentCustodian;
    }


    function acceptOwnership() {
        if (msg.sender == currentCustodian) {
            owner = currentCustodian;
        }
    }


    function implementDecision(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.value(_value)(_data);
    }
}


contract WedSlot is Owned {


    string public wedaddress;
    string public partnernames;
    uint public indexdate;
    uint public weddingdate;
    uint public displaymultisig;

    PositionList[] public indexarray;

    struct PositionList {
        uint indexdate;
        string wedaddress;
        string partnernames;
        uint weddingdate;
        uint displaymultisig;
    }

    function numberOfSlot() constant public returns (uint) {
        return indexarray.length;
    }


    function writeSlot(uint indexdate, string wedaddress, string partnernames, uint weddingdate, uint displaymultisig) {
        indexarray.push(PositionList(now, wedaddress, partnernames, weddingdate, displaymultisig));
        RankWritten(now, wedaddress, partnernames, weddingdate, displaymultisig);
    }


    event RankWritten (uint instant, string contractaddress, string partners, uint weddingdate, uint display);
}