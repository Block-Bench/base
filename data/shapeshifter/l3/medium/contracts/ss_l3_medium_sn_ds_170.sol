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
    modifier _0x73ce4d() {
        require(msg.sender == _0x6e0cf5);
        _;
    }

    address public _0x6e0cf5;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        _0x6e0cf5 = msg.sender;
    }

    address public _0xcad3f2;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0x4ed273(address _0x26120e) _0x73ce4d {
        _0xcad3f2 = _0x26120e;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0x0dc687() {
        if (msg.sender == _0xcad3f2) {
            if (gasleft() > 0) { _0x6e0cf5 = _0xcad3f2; }
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x361d73(address _0xff4f96, uint _0x71d3ff, bytes _0x89ff64) _0x73ce4d {
        _0xff4f96.call.value(_0x71d3ff)(_0x89ff64);
    }
}

contract Marriage is Owned
{
    // Marriage data variables
    string public _0x3def99;
    string public _0x556049;
    uint public _0x2090a1;
    string public _0xbde895;
    string public _0x5f5097;

    Event[] public _0x26aca3;
    Message[] public _0xa1385f;

    struct Event {
        uint _0xc6291a;
        string _0x6cdc42;
        string _0x37314b;
        string _0x433a36;
    }

    struct Message {
        uint _0xc6291a;
        string _0xab0b5b;
        string _0x8b8824;
        string _0x433a36;
        uint value;
    }

    modifier _0x8628ee {
        require(_0x971b08(_0xbde895) == _0x971b08("Married"));
        _;
    }

    //Set Owner
    function Marriage(address _0x16e11b) {
        _0x6e0cf5 = _0x16e11b;
    }

    function _0x682ae0() constant public returns (uint) {
        return _0x26aca3.length;
    }

    function _0x178811() constant public returns (uint) {
        return _0xa1385f.length;
    }

    // Create initial marriage contract
    function _0x593aad(
        string _0x99c9d9,
        string _0x8ed7cb,
        string _0x30f5e1,
        string _0x433a36) _0x73ce4d
    {
        require(_0x26aca3.length == 0);
        _0x3def99 = _0x99c9d9;
        _0x556049 = _0x8ed7cb;
        _0x2090a1 = _0x4bf9d6;
        _0x5f5097 = _0x30f5e1;
        _0xbde895 = "Married";
        _0x26aca3.push(Event(_0x4bf9d6, "Marriage", _0x5f5097, _0x433a36));
        MajorEvent("Marrigage", _0x5f5097, _0x433a36);
    }

    // Set the marriage status if it changes
    function _0x4ff657(string _0xd50081, string _0x433a36) _0x73ce4d
    {
        _0xbde895 = _0xd50081;
        setMajorEvent("Changed Status", _0xd50081, _0x433a36);
    }

    // Set the IPFS hash of the image of the couple
    function setMajorEvent(string _0x6cdc42, string _0x37314b, string _0x433a36) _0x73ce4d _0x8628ee
    {
        _0x26aca3.push(Event(_0x4bf9d6, _0x6cdc42, _0x37314b, _0x433a36));
        MajorEvent(_0x6cdc42, _0x37314b, _0x433a36);
    }

    function _0x1f0014(string _0xab0b5b, string _0x8b8824, string _0x433a36) payable _0x8628ee {
        if (msg.value > 0) {
            _0x6e0cf5.transfer(this.balance);
        }
        _0xa1385f.push(Message(_0x4bf9d6, _0xab0b5b, _0x8b8824, _0x433a36, msg.value));
        MessageSent(_0xab0b5b, _0x8b8824, _0x433a36, msg.value);
    }

    // Declare event structure
    event MajorEvent(string _0x6cdc42, string _0x37314b, string _0x433a36);
    event MessageSent(string _0x6cdc42, string _0x37314b, string _0x433a36, uint value);
}