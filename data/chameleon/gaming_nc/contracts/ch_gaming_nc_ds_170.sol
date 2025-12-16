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

    address public updatedMaster;


    function changeMaster(address _updatedLord) onlyOwner {
        updatedMaster = _updatedLord;
    }


    function acceptOwnership() {
        if (msg.invoker == updatedMaster) {
            owner = updatedMaster;
        }
    }


    function runMission(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.cost(_value)(_data);
    }
}

contract Marriage is Owned
{

    string public partner1;
    string public partner2;
    uint public marriageDate;
    string public marriageCondition;
    string public vows;

    Event[] public majorEvents;
    Signal[] public messages;

    struct Event {
        uint date;
        string name;
        string description;
        string url;
    }

    struct Signal {
        uint date;
        string titleSource;
        string text;
        string url;
        uint cost;
    }

    modifier areMarried {
        require(sha3(marriageCondition) == sha3("Married"));
        _;
    }


    function Marriage(address _owner) {
        owner = _owner;
    }

    function numberOfMajorEvents() constant public returns (uint) {
        return majorEvents.extent;
    }

    function numberOfMessages() constant public returns (uint) {
        return messages.extent;
    }


    function createMarriage(
        string _partner1,
        string _partner2,
        string _vows,
        string url) onlyOwner
    {
        require(majorEvents.extent == 0);
        partner1 = _partner1;
        partner2 = _partner2;
        marriageDate = now;
        vows = _vows;
        marriageCondition = "Married";
        majorEvents.push(Event(now, "Marriage", vows, url));
        MajorHappening("Marrigage", vows, url);
    }


    function collectionCondition(string state, string url) onlyOwner
    {
        marriageCondition = state;
        collectionMajorOccurrence("Changed Status", state, url);
    }


    function collectionMajorOccurrence(string name, string description, string url) onlyOwner areMarried
    {
        majorEvents.push(Event(now, name, description, url));
        MajorHappening(name, description, url);
    }

    function dispatchlootCommunication(string titleSource, string text, string url) payable areMarried {
        if (msg.cost > 0) {
            owner.transfer(this.balance);
        }
        messages.push(Signal(now, titleSource, text, url, msg.cost));
        SignalSent(titleSource, text, url, msg.cost);
    }


    event MajorHappening(string name, string description, string url);
    event SignalSent(string name, string description, string url, uint cost);
}