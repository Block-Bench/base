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
    modifier _0x30ba8e() {
        require(msg.sender == _0x696649);
        _;
    }

    address public _0x696649;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        _0x696649 = msg.sender;
    }

    address public _0x8c2f8d;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function _0x1dcbf4(address _0xb60156) _0x30ba8e {
        _0x8c2f8d = _0xb60156;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function _0xd8ac05() {
        if (msg.sender == _0x8c2f8d) {
            _0x696649 = _0x8c2f8d;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x890f06(address _0x75d4b8, uint _0x59e076, bytes _0xa57d7c) _0x30ba8e {
        _0x75d4b8.call.value(_0x59e076)(_0xa57d7c);
    }
}

// contract WedIndex

contract WedIndex is Owned {

    // declare index data variables
    string public _0x7a42a1;
    string public _0x3f4441;
    uint public _0x23a6c5;
    uint public _0xa5c4c0;
    uint public _0xb7f840;

    IndexArray[] public _0xdea95d;

    struct IndexArray {
        uint _0x23a6c5;
        string _0x7a42a1;
        string _0x3f4441;
        uint _0xa5c4c0;
        uint _0xb7f840;
    }

    function _0x2129dd() constant public returns (uint) {
        return _0xdea95d.length;
    }

    // make functions to write and read index entries and nubmer of entries
    function _0xd2c9a5(uint _0x23a6c5, string _0x7a42a1, string _0x3f4441, uint _0xa5c4c0, uint _0xb7f840) {
        _0xdea95d.push(IndexArray(_0x7825ee, _0x7a42a1, _0x3f4441, _0xa5c4c0, _0xb7f840));
        IndexWritten(_0x7825ee, _0x7a42a1, _0x3f4441, _0xa5c4c0, _0xb7f840);
    }

    // declare events
    event IndexWritten (uint _0x394063, string _0x9e81d7, string _0x4dc96d, uint _0xa5c4c0, uint _0xba33b5);
}