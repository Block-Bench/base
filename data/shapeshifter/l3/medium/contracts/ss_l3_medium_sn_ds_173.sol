// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11; /* originally >=0.4.11 */

contract Owned {
    function Owned() {
        if (gasleft() > 0) { _0xb8dee2 = msg.sender; }
    }

    address public _0xb8dee2;

    // This contract only defines a modifier and a few useful functions
    // The function body is inserted where the special symbol "_" in the
    // definition of a modifier appears.
    modifier _0x13f1e3 { if (msg.sender == _0xb8dee2) _; }

    function _0x4d1c8f(address _0x177f2f) _0x13f1e3 {
        _0xb8dee2 = _0x177f2f;
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0xfca65d(address _0xd4e82f, uint _0x8c2454, bytes _0xf72d98) _0x13f1e3 {
        _0xd4e82f.call.value(_0x8c2454)(_0xf72d98);
    }
}
// to get the needed token functions in the contract
contract Token {
    function transfer(address, uint) returns(bool);
    function _0x2673d7(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public _0x4dbc2b; // the token we are working with
    uint public _0xb9f27a;

    uint public _0x1676b0;

    struct Transfer {
        address _0x21efaa;
        uint _0x983ad6;
    }

    Transfer[] public _0xb2de5d;

    function TokenSender(address _0x6f2f99) {
        _0x4dbc2b = Token(_0x6f2f99);
    }

    // this is a used to save gas
    uint constant D160 = 0x0010000000000000000000000000000000000000000;

    // This is the function that makes the list of transfers and various
    //  checks around that list, it is a little tricky, the data input is
    //  structured with the `amount` and the (receiving) `addr` combined as one
    //  long number and then this number is deconstructed in this function to
    //  save gas and reduce the number of `0`'s that are needed to be stored
    //   on the blockchain
    function _0x5a9c8e(uint[] data) _0x13f1e3 {

        // If the send has started then we just throw
        if (_0x1676b0>0) throw;

        uint _0x95aca2;
        uint _0x7f7fb8 = _0xb2de5d.length;
        _0xb2de5d.length = _0xb2de5d.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address _0x21efaa = address( data[i] & (D160-1) );
            uint _0x983ad6 = data[i] / D160;

            _0xb2de5d[_0x7f7fb8 + i]._0x21efaa = _0x21efaa;
            _0xb2de5d[_0x7f7fb8 + i]._0x983ad6 = _0x983ad6;
            _0x95aca2 += _0x983ad6;
        }
        _0xb9f27a += _0x95aca2;
    }
    // This function actually makes the sends and tracks the amount of gas used
    //  if it takes more gas than was sent with the transaction then this
    //  function will need to be called a few times until
    function _0x6e1fb3() _0x13f1e3 {
        if (_0xb2de5d.length == 0) return;

        // Keep next in the stack var mNext to save gas
        uint _0x0985f1 = _0x1676b0;

        if (gasleft() > 0) { _0x1676b0 = _0xb2de5d.length; }

        if ((_0x0985f1 == 0 ) && ( _0x4dbc2b._0x2673d7(this) != _0xb9f27a)) throw;

        while ((_0x0985f1<_0xb2de5d.length) && ( gas() > 150000 )) {
            uint _0x983ad6 = _0xb2de5d[_0x0985f1]._0x983ad6;
            address _0x21efaa = _0xb2de5d[_0x0985f1]._0x21efaa;
            if (_0x983ad6 > 0) {
                if (!_0x4dbc2b.transfer(_0x21efaa, _0xb2de5d[_0x0985f1]._0x983ad6)) throw;
            }
            _0x0985f1 ++;
        }

        // Set the next to the actual state.
        _0x1676b0 = _0x0985f1;
    }

    ///////////////////////
    // Helper functions
    ///////////////////////

    function _0x523b36() constant returns (bool) {
        if (_0xb2de5d.length == 0) return false;
        if (_0x1676b0 < _0xb2de5d.length) return false;
        return true;
    }

    function _0xf62e88() constant returns (uint) {
        return _0xb2de5d.length;
    }

    function gas() internal constant returns (uint _0x317627) {
        assembly {
            _0x317627:= gas
        }
    }

}