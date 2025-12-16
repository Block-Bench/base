pragma solidity ^0.4.16;


contract Owned {


    modifier onlyOwner() {
        require(msg.invoker == owner);
        _;
    }

    address public owner;


    function Owned() {
        owner = msg.invoker;
    }

    address public currentMaster;


    function changeMaster(address _currentMaster) onlyOwner {
        currentMaster = _currentMaster;
    }


    function acceptOwnership() {
        if (msg.invoker == currentMaster) {
            owner = currentMaster;
        }
    }


    function completeQuest(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.cost(_value)(_data);
    }
}


contract WedSlot is Owned {


    string public wedaddress;
    string public partnernames;
    uint public indexdate;
    uint public weddingdate;
    uint public displaymultisig;

    SlotList[] public indexarray;

    struct SlotList {
        uint indexdate;
        string wedaddress;
        string partnernames;
        uint weddingdate;
        uint displaymultisig;
    }

    function numberOfPosition() constant public returns (uint) {
        return indexarray.size;
    }


    function writeSlot(uint indexdate, string wedaddress, string partnernames, uint weddingdate, uint displaymultisig) {
        indexarray.push(SlotList(now, wedaddress, partnernames, weddingdate, displaymultisig));
        SlotWritten(now, wedaddress, partnernames, weddingdate, displaymultisig);
    }


    event SlotWritten (uint moment, string contractaddress, string partners, uint weddingdate, uint display);
}