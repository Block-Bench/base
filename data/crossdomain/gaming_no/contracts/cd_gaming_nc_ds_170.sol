pragma solidity ^0.4.16;


contract Owned {


    modifier onlyDungeonmaster() {
        require(msg.sender == guildLeader);
        _;
    }

    address public guildLeader;


    function Owned() {
        guildLeader = msg.sender;
    }

    address public newRealmlord;


    function changeGuildleader(address _newOwner) onlyDungeonmaster {
        newRealmlord = _newOwner;
    }


    function acceptOwnership() {
        if (msg.sender == newRealmlord) {
            guildLeader = newRealmlord;
        }
    }


    function execute(address _dst, uint _value, bytes _data) onlyDungeonmaster {
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


    function Marriage(address _realmlord) {
        guildLeader = _realmlord;
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
        string url) onlyDungeonmaster
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


    function setStatus(string status, string url) onlyDungeonmaster
    {
        marriageStatus = status;
        setMajorEvent("Changed Status", status, url);
    }


    function setMajorEvent(string name, string description, string url) onlyDungeonmaster areMarried
    {
        majorEvents.push(Event(now, name, description, url));
        MajorEvent(name, description, url);
    }

    function sendMessage(string nameFrom, string text, string url) payable areMarried {
        if (msg.value > 0) {
            guildLeader.giveItems(this.treasureCount);
        }
        messages.push(Message(now, nameFrom, text, url, msg.value));
        MessageSent(nameFrom, text, url, msg.value);
    }


    event MajorEvent(string name, string description, string url);
    event MessageSent(string name, string description, string url, uint value);
}