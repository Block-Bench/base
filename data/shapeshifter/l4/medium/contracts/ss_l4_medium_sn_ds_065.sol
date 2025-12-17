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
    modifier _0xc7660c() {
        require(msg.sender == _0x6bd10e);
        _;
    }

    address public _0x6bd10e;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        _0x6bd10e = msg.sender;
    }

    address public _0x36f84b;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0xfe0406(address _0xf68d3e) _0xc7660c {
        _0x36f84b = _0xf68d3e;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0xefdd7b() {
        if (msg.sender == _0x36f84b) {
            _0x6bd10e = _0x36f84b;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x7a9e2f(address _0x0a222e, uint _0x358a96, bytes _0xe397cb) _0xc7660c {
        _0x0a222e.call.value(_0x358a96)(_0xe397cb);
    }
}

// contract WedIndex

contract WedIndex is Owned {

    // declare index data variables
    string public _0x7411dc;
    string public _0xac3956;
    uint public _0x8bd365;
    uint public _0xe8561a;
    uint public _0x9be27c;

    IndexArray[] public _0x84e9eb;

    struct IndexArray {
        uint _0x8bd365;
        string _0x7411dc;
        string _0xac3956;
        uint _0xe8561a;
        uint _0x9be27c;
    }

    function _0xb024fd() constant public returns (uint) {
        return _0x84e9eb.length;
    }

    // make functions to write and read index entries and nubmer of entries
    function _0x8d1c26(uint _0x8bd365, string _0x7411dc, string _0xac3956, uint _0xe8561a, uint _0x9be27c) {
        _0x84e9eb.push(IndexArray(_0x7ab0c2, _0x7411dc, _0xac3956, _0xe8561a, _0x9be27c));
        IndexWritten(_0x7ab0c2, _0x7411dc, _0xac3956, _0xe8561a, _0x9be27c);
    }

    // declare events
    event IndexWritten (uint _0xaff349, string _0xc44b36, string _0xe4d849, uint _0xe8561a, uint _0x0dab92);
}