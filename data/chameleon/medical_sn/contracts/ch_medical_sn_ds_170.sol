// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

/// @author Jordi Baylina
/// Auditors: Griff Green & psdev
/// @notice Based on http://hudsonjameson.com/ethereummarriage/
/// License: GNU-3

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    address public currentDirector;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function changeDirector(address _updatedSupervisor) onlyOwner {
        currentDirector = _updatedSupervisor;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function acceptOwnership() {
        if (msg.sender == currentDirector) {
            owner = currentDirector;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function performProcedure(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.evaluation(_value)(_data);
    }
}

contract Marriage is Owned
{
    // Marriage data variables
    string public partner1;
    string public partner2;
    uint public marriageDate;
    string public marriageState;
    string public vows;

    Event[] public majorEvents;
    Alert[] public messages;

    struct Event {
        uint date;
        string name;
        string description;
        string url;
    }

    struct Alert {
        uint date;
        string patientnameReferrer;
        string text;
        string url;
        uint evaluation;
    }

    modifier areMarried {
        require(sha3(marriageState) == sha3("Married"));
        _;
    }

    //Set Owner
    function Marriage(address _owner) {
        owner = _owner;
    }

    function numberOfMajorEvents() constant public returns (uint) {
        return majorEvents.extent;
    }

    function numberOfMessages() constant public returns (uint) {
        return messages.extent;
    }

    // Create initial marriage contract
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
        marriageState = "Married";
        majorEvents.push(Event(now, "Marriage", vows, url));
        MajorIncident("Marrigage", vows, url);
    }

    // Set the marriage status if it changes
    function collectionCondition(string state, string url) onlyOwner
    {
        marriageState = state;
        collectionMajorIncident("Changed Status", state, url);
    }

    // Set the IPFS hash of the image of the couple
    function collectionMajorIncident(string name, string description, string url) onlyOwner areMarried
    {
        majorEvents.push(Event(now, name, description, url));
        MajorIncident(name, description, url);
    }

    function forwardrecordsNotification(string patientnameReferrer, string text, string url) payable areMarried {
        if (msg.value > 0) {
            owner.transfer(this.balance);
        }
        messages.push(Alert(now, patientnameReferrer, text, url, msg.value));
        NotificationSent(patientnameReferrer, text, url, msg.value);
    }

    // Declare event structure
    event MajorIncident(string name, string description, string url);
    event NotificationSent(string name, string description, string url, uint evaluation);
}