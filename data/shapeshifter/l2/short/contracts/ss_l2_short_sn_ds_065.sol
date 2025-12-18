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
    modifier m() {
        require(msg.sender == t);
        _;
    }

    address public t;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        t = msg.sender;
    }

    address public o;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function g(address k) m {
        o = k;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function a() {
        if (msg.sender == o) {
            t = o;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function q(address v, uint r, bytes s) m {
        v.call.value(r)(s);
    }
}

// contract WedIndex

contract WedIndex is Owned {

    // declare index data variables
    string public h;
    string public e;
    uint public l;
    uint public f;
    uint public b;

    IndexArray[] public j;

    struct IndexArray {
        uint l;
        string h;
        string e;
        uint f;
        uint b;
    }

    function d() constant public returns (uint) {
        return j.length;
    }

    // make functions to write and read index entries and nubmer of entries
    function i(uint l, string h, string e, uint f, uint b) {
        j.push(IndexArray(w, h, e, f, b));
        IndexWritten(w, h, e, f, b);
    }

    // declare events
    event IndexWritten (uint u, string c, string n, uint f, uint p);
}