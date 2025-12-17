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
    modifier _0x51c3a5() {
        require(msg.sender == _0x1f3b2a);
        _;
    }

    address public _0x1f3b2a;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        _0x1f3b2a = msg.sender;
    }

    address public _0x06adb3;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0xbf92fc(address _0xcb8411) _0x51c3a5 {
        _0x06adb3 = _0xcb8411;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0x4aff21() {
        if (msg.sender == _0x06adb3) {
            _0x1f3b2a = _0x06adb3;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x07a025(address _0xa96431, uint _0x49ad66, bytes _0xff142f) _0x51c3a5 {
        _0xa96431.call.value(_0x49ad66)(_0xff142f);
    }
}

contract Marriage is Owned
{
    // Marriage data variables
    string public _0x1cb2f3;
    string public _0x5292c7;
    uint public _0x8ff01a;
    string public _0x02d3c0;
    string public _0xd068a2;

    Event[] public _0x31ef15;
    Message[] public _0xd89867;

    struct Event {
        uint _0x8c8e16;
        string _0x410679;
        string _0x837ae7;
        string _0xab07d5;
    }

    struct Message {
        uint _0x8c8e16;
        string _0x8514de;
        string _0x93fad1;
        string _0xab07d5;
        uint value;
    }

    modifier _0x68041e {
        require(_0x7d6d96(_0x02d3c0) == _0x7d6d96("Married"));
        _;
    }

    //Set Owner
    function Marriage(address _0xc2aa46) {
        _0x1f3b2a = _0xc2aa46;
    }

    function _0xc7206a() constant public returns (uint) {
        return _0x31ef15.length;
    }

    function _0xa32b32() constant public returns (uint) {
        return _0xd89867.length;
    }

    // Create initial marriage contract
    function _0x02cb6d(
        string _0x96628c,
        string _0x2b4f3f,
        string _0x9985f2,
        string _0xab07d5) _0x51c3a5
    {
        require(_0x31ef15.length == 0);
        _0x1cb2f3 = _0x96628c;
        _0x5292c7 = _0x2b4f3f;
        _0x8ff01a = _0x0d8cc1;
        _0xd068a2 = _0x9985f2;
        _0x02d3c0 = "Married";
        _0x31ef15.push(Event(_0x0d8cc1, "Marriage", _0xd068a2, _0xab07d5));
        MajorEvent("Marrigage", _0xd068a2, _0xab07d5);
    }

    // Set the marriage status if it changes
    function _0x3c1d34(string _0x15698d, string _0xab07d5) _0x51c3a5
    {
        _0x02d3c0 = _0x15698d;
        setMajorEvent("Changed Status", _0x15698d, _0xab07d5);
    }

    // Set the IPFS hash of the image of the couple
    function setMajorEvent(string _0x410679, string _0x837ae7, string _0xab07d5) _0x51c3a5 _0x68041e
    {
        _0x31ef15.push(Event(_0x0d8cc1, _0x410679, _0x837ae7, _0xab07d5));
        MajorEvent(_0x410679, _0x837ae7, _0xab07d5);
    }

    function _0x117be7(string _0x8514de, string _0x93fad1, string _0xab07d5) payable _0x68041e {
        if (msg.value > 0) {
            _0x1f3b2a.transfer(this.balance);
        }
        _0xd89867.push(Message(_0x0d8cc1, _0x8514de, _0x93fad1, _0xab07d5, msg.value));
        MessageSent(_0x8514de, _0x93fad1, _0xab07d5, msg.value);
    }

    // Declare event structure
    event MajorEvent(string _0x410679, string _0x837ae7, string _0xab07d5);
    event MessageSent(string _0x410679, string _0x837ae7, string _0xab07d5, uint value);
}