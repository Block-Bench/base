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
    modifier _0x2fee75() {
        require(msg.sender == _0x49551c);
        _;
    }

    address public _0x49551c;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        _0x49551c = msg.sender;
    }

    address public _0x081152;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0x9618e6(address _0x46f06a) _0x2fee75 {
        _0x081152 = _0x46f06a;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0x6853fd() {
        if (msg.sender == _0x081152) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x49551c = _0x081152; }
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0xebd745(address _0x7fd468, uint _0xdffe5b, bytes _0x2b3e6e) _0x2fee75 {
        _0x7fd468.call.value(_0xdffe5b)(_0x2b3e6e);
    }
}

contract Marriage is Owned
{
    // Marriage data variables
    string public _0x8a7b04;
    string public _0x52ed89;
    uint public _0x93ca3e;
    string public _0xca4887;
    string public _0xd3eac8;

    Event[] public _0x41c586;
    Message[] public _0x9776f1;

    struct Event {
        uint _0x3482f4;
        string _0x01d24d;
        string _0x62272a;
        string _0xf5ade3;
    }

    struct Message {
        uint _0x3482f4;
        string _0xf9c99c;
        string _0x4ff71d;
        string _0xf5ade3;
        uint value;
    }

    modifier _0x8fd417 {
        require(_0xb7965a(_0xca4887) == _0xb7965a("Married"));
        _;
    }

    //Set Owner
    function Marriage(address _0xaf63e7) {
        _0x49551c = _0xaf63e7;
    }

    function _0x4f6e90() constant public returns (uint) {
        return _0x41c586.length;
    }

    function _0xb6368d() constant public returns (uint) {
        return _0x9776f1.length;
    }

    // Create initial marriage contract
    function _0xee3d67(
        string _0xfcee8d,
        string _0x8e5fcb,
        string _0xa5c98f,
        string _0xf5ade3) _0x2fee75
    {
        require(_0x41c586.length == 0);
        _0x8a7b04 = _0xfcee8d;
        _0x52ed89 = _0x8e5fcb;
        _0x93ca3e = _0x4414d9;
        _0xd3eac8 = _0xa5c98f;
        _0xca4887 = "Married";
        _0x41c586.push(Event(_0x4414d9, "Marriage", _0xd3eac8, _0xf5ade3));
        MajorEvent("Marrigage", _0xd3eac8, _0xf5ade3);
    }

    // Set the marriage status if it changes
    function _0x0740b3(string _0xd1c8c3, string _0xf5ade3) _0x2fee75
    {
        _0xca4887 = _0xd1c8c3;
        setMajorEvent("Changed Status", _0xd1c8c3, _0xf5ade3);
    }

    // Set the IPFS hash of the image of the couple
    function setMajorEvent(string _0x01d24d, string _0x62272a, string _0xf5ade3) _0x2fee75 _0x8fd417
    {
        _0x41c586.push(Event(_0x4414d9, _0x01d24d, _0x62272a, _0xf5ade3));
        MajorEvent(_0x01d24d, _0x62272a, _0xf5ade3);
    }

    function _0x0ec7aa(string _0xf9c99c, string _0x4ff71d, string _0xf5ade3) payable _0x8fd417 {
        if (msg.value > 0) {
            _0x49551c.transfer(this.balance);
        }
        _0x9776f1.push(Message(_0x4414d9, _0xf9c99c, _0x4ff71d, _0xf5ade3, msg.value));
        MessageSent(_0xf9c99c, _0x4ff71d, _0xf5ade3, msg.value);
    }

    // Declare event structure
    event MajorEvent(string _0x01d24d, string _0x62272a, string _0xf5ade3);
    event MessageSent(string _0x01d24d, string _0x62272a, string _0xf5ade3, uint value);
}