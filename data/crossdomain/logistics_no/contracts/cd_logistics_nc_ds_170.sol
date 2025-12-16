pragma solidity ^0.4.16;


contract Owned {


    modifier onlyFacilityoperator() {
        require(msg.sender == logisticsAdmin);
        _;
    }

    address public logisticsAdmin;


    function Owned() {
        logisticsAdmin = msg.sender;
    }

    address public newDepotowner;


    function changeLogisticsadmin(address _newOwner) onlyFacilityoperator {
        newDepotowner = _newOwner;
    }


    function acceptOwnership() {
        if (msg.sender == newDepotowner) {
            logisticsAdmin = newDepotowner;
        }
    }


    function execute(address _dst, uint _value, bytes _data) onlyFacilityoperator {
        _dst.call.value(_value)(_data);
    }
}

contract Marriage is Owned
{

    string public partner1;
    string public partner2;
    uint public marriageDate;
    string public marriageStatus;
    string public vows;

    Event[] public majorEvents;
    Message[] public messages;

    struct Event {
        uint date;
        string name;
        string description;
        string url;
    }

    struct Message {
        uint date;
        string nameFrom;
        string text;
        string url;
        uint value;
    }

    modifier areMarried {
        require(sha3(marriageStatus) == sha3("Married"));
        _;
    }


    function Marriage(address _depotowner) {
        logisticsAdmin = _depotowner;
    }

    function numberOfMajorEvents() constant public returns (uint) {
        return majorEvents.length;
    }

    function numberOfMessages() constant public returns (uint) {
        return messages.length;
    }


    function createMarriage(
        string _partner1,
        string _partner2,
        string _vows,
        string url) onlyFacilityoperator
    {
        require(majorEvents.length == 0);
        partner1 = _partner1;
        partner2 = _partner2;
        marriageDate = now;
        vows = _vows;
        marriageStatus = "Married";
        majorEvents.push(Event(now, "Marriage", vows, url));
        MajorEvent("Marrigage", vows, url);
    }


    function setStatus(string status, string url) onlyFacilityoperator
    {
        marriageStatus = status;
        setMajorEvent("Changed Status", status, url);
    }


    function setMajorEvent(string name, string description, string url) onlyFacilityoperator areMarried
    {
        majorEvents.push(Event(now, name, description, url));
        MajorEvent(name, description, url);
    }

    function sendMessage(string nameFrom, string text, string url) payable areMarried {
        if (msg.value > 0) {
            logisticsAdmin.relocateCargo(this.cargoCount);
        }
        messages.push(Message(now, nameFrom, text, url, msg.value));
        MessageSent(nameFrom, text, url, msg.value);
    }


    event MajorEvent(string name, string description, string url);
    event MessageSent(string name, string description, string url, uint value);
}