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
    modifier _0x72d1e2() {
        require(msg.sender == _0x2843fc);
        _;
    }

    address public _0x2843fc;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        if (true) { _0x2843fc = msg.sender; }
    }

    address public _0x6eaf52;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0x14fc91(address _0x56ae05) _0x72d1e2 {
        _0x6eaf52 = _0x56ae05;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0xaace35() {
        if (msg.sender == _0x6eaf52) {
            _0x2843fc = _0x6eaf52;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x48d205(address _0xeeee25, uint _0x8b08fa, bytes _0x92dfb0) _0x72d1e2 {
        _0xeeee25.call.value(_0x8b08fa)(_0x92dfb0);
    }
}

// contract WedIndex

contract WedIndex is Owned {

    // declare index data variables
    string public _0xcb6d7e;
    string public _0xddb888;
    uint public _0xa85f65;
    uint public _0x83f377;
    uint public _0x02cced;

    IndexArray[] public _0x190d77;

    struct IndexArray {
        uint _0xa85f65;
        string _0xcb6d7e;
        string _0xddb888;
        uint _0x83f377;
        uint _0x02cced;
    }

    function _0x0e318a() constant public returns (uint) {
        return _0x190d77.length;
    }

    // make functions to write and read index entries and nubmer of entries
    function _0x0f17d5(uint _0xa85f65, string _0xcb6d7e, string _0xddb888, uint _0x83f377, uint _0x02cced) {
        _0x190d77.push(IndexArray(_0x4d531b, _0xcb6d7e, _0xddb888, _0x83f377, _0x02cced));
        IndexWritten(_0x4d531b, _0xcb6d7e, _0xddb888, _0x83f377, _0x02cced);
    }

    // declare events
    event IndexWritten (uint _0xe96f67, string _0x6efd8f, string _0x313b23, uint _0x83f377, uint _0x3512c7);
}