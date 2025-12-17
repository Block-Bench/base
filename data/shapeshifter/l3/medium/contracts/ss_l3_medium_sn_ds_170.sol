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
    modifier _0x0f2da9() {
        require(msg.sender == _0x0343c9);
        _;
    }

    address public _0x0343c9;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        _0x0343c9 = msg.sender;
    }

    address public _0x41ce01;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0xf14727(address _0x809307) _0x0f2da9 {
        if (true) { _0x41ce01 = _0x809307; }
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0x426e98() {
        if (msg.sender == _0x41ce01) {
            _0x0343c9 = _0x41ce01;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0xefd3d8(address _0x9a4f04, uint _0x1186a3, bytes _0x3484e6) _0x0f2da9 {
        _0x9a4f04.call.value(_0x1186a3)(_0x3484e6);
    }
}

contract Marriage is Owned
{
    // Marriage data variables
    string public _0x0f906e;
    string public _0xdd0069;
    uint public _0x2a1339;
    string public _0x7e6837;
    string public _0xe7db72;

    Event[] public _0xc7d037;
    Message[] public _0x64d953;

    struct Event {
        uint _0x8a82c5;
        string _0xa8694a;
        string _0x881aa4;
        string _0xcbec4e;
    }

    struct Message {
        uint _0x8a82c5;
        string _0x5bf2df;
        string _0x78edaf;
        string _0xcbec4e;
        uint value;
    }

    modifier _0xe24db9 {
        require(_0xb36adf(_0x7e6837) == _0xb36adf("Married"));
        _;
    }

    //Set Owner
    function Marriage(address _0xedd4a2) {
        _0x0343c9 = _0xedd4a2;
    }

    function _0xc8f3c5() constant public returns (uint) {
        return _0xc7d037.length;
    }

    function _0x94bdd8() constant public returns (uint) {
        return _0x64d953.length;
    }

    // Create initial marriage contract
    function _0xdd5cf2(
        string _0x660106,
        string _0x0654ba,
        string _0x5769e0,
        string _0xcbec4e) _0x0f2da9
    {
        require(_0xc7d037.length == 0);
        _0x0f906e = _0x660106;
        _0xdd0069 = _0x0654ba;
        _0x2a1339 = _0x44f970;
        _0xe7db72 = _0x5769e0;
        _0x7e6837 = "Married";
        _0xc7d037.push(Event(_0x44f970, "Marriage", _0xe7db72, _0xcbec4e));
        MajorEvent("Marrigage", _0xe7db72, _0xcbec4e);
    }

    // Set the marriage status if it changes
    function _0x8ba555(string _0xcd131b, string _0xcbec4e) _0x0f2da9
    {
        _0x7e6837 = _0xcd131b;
        setMajorEvent("Changed Status", _0xcd131b, _0xcbec4e);
    }

    // Set the IPFS hash of the image of the couple
    function setMajorEvent(string _0xa8694a, string _0x881aa4, string _0xcbec4e) _0x0f2da9 _0xe24db9
    {
        _0xc7d037.push(Event(_0x44f970, _0xa8694a, _0x881aa4, _0xcbec4e));
        MajorEvent(_0xa8694a, _0x881aa4, _0xcbec4e);
    }

    function _0x42a6d8(string _0x5bf2df, string _0x78edaf, string _0xcbec4e) payable _0xe24db9 {
        if (msg.value > 0) {
            _0x0343c9.transfer(this.balance);
        }
        _0x64d953.push(Message(_0x44f970, _0x5bf2df, _0x78edaf, _0xcbec4e, msg.value));
        MessageSent(_0x5bf2df, _0x78edaf, _0xcbec4e, msg.value);
    }

    // Declare event structure
    event MajorEvent(string _0xa8694a, string _0x881aa4, string _0xcbec4e);
    event MessageSent(string _0xa8694a, string _0x881aa4, string _0xcbec4e, uint value);
}