// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

/// @author Bowen Sanders
/// sections built on the work of Jordi Baylina (Owned, data structure)
/// smartwedindex.sol contains a simple index of contract address, couple name, actual marriage date, bool displayValues to
/// be used to create an array of all SmartWed contracts that are deployed
/// contract 0wned is licesned under GNU-3

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier _0x78aef4() {
        require(msg.sender == _0x375da7);
        _;
    }

    address public _0x375da7;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        _0x375da7 = msg.sender;
    }

    address public _0x58e93e;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0x36940f(address _0x6296a0) _0x78aef4 {
        _0x58e93e = _0x6296a0;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0xba8392() {
        if (msg.sender == _0x58e93e) {
            _0x375da7 = _0x58e93e;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x0365f4(address _0xff799f, uint _0x1aa2ae, bytes _0xa7bfdb) _0x78aef4 {
        _0xff799f.call.value(_0x1aa2ae)(_0xa7bfdb);
    }
}

// contract WedIndex

contract WedIndex is Owned {

    // declare index data variables
    string public _0x8d319e;
    string public _0xeb32c5;
    uint public _0x57efb9;
    uint public _0xf592ca;
    uint public _0x79a4d0;

    IndexArray[] public _0x1abd64;

    struct IndexArray {
        uint _0x57efb9;
        string _0x8d319e;
        string _0xeb32c5;
        uint _0xf592ca;
        uint _0x79a4d0;
    }

    function _0xb9d9ef() constant public returns (uint) {
        return _0x1abd64.length;
    }

    // make functions to write and read index entries and nubmer of entries
    function _0x547163(uint _0x57efb9, string _0x8d319e, string _0xeb32c5, uint _0xf592ca, uint _0x79a4d0) {
        _0x1abd64.push(IndexArray(_0x43e80f, _0x8d319e, _0xeb32c5, _0xf592ca, _0x79a4d0));
        IndexWritten(_0x43e80f, _0x8d319e, _0xeb32c5, _0xf592ca, _0x79a4d0);
    }

    // declare events
    event IndexWritten (uint _0xeebd84, string _0x3301e2, string _0x3fa79e, uint _0xf592ca, uint _0xbedd89);
}