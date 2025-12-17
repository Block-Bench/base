// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11; /* originally >=0.4.11 */

contract Owned {
    function Owned() {
        _0x88f129 = msg.sender;
    }

    address public _0x88f129;

    // This contract only defines a modifier and a few useful functions
    // The function body is inserted where the special symbol "_" in the
    // definition of a modifier appears.
    modifier _0xfec459 { if (msg.sender == _0x88f129) _; }

    function _0x8d8c05(address _0x17dfd9) _0xfec459 {
        _0x88f129 = _0x17dfd9;
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x720a6a(address _0x08823f, uint _0x1356db, bytes _0x25db16) _0xfec459 {
        _0x08823f.call.value(_0x1356db)(_0x25db16);
    }
}
// to get the needed token functions in the contract
contract Token {
    function transfer(address, uint) returns(bool);
    function _0xa42e04(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public _0x995ddd; // the token we are working with
    uint public _0x9ea8f4;

    uint public _0x1cc4d4;

    struct Transfer {
        address _0xd70ed2;
        uint _0xbfc161;
    }

    Transfer[] public _0x641111;

    function TokenSender(address _0x5e92de) {
        _0x995ddd = Token(_0x5e92de);
    }

    // this is a used to save gas
    uint constant D160 = 0x0010000000000000000000000000000000000000000;

    // This is the function that makes the list of transfers and various
    //  checks around that list, it is a little tricky, the data input is
    //  structured with the `amount` and the (receiving) `addr` combined as one
    //  long number and then this number is deconstructed in this function to
    //  save gas and reduce the number of `0`'s that are needed to be stored
    //   on the blockchain
    function _0x1b82c2(uint[] data) _0xfec459 {

        // If the send has started then we just throw
        if (_0x1cc4d4>0) throw;

        uint _0xda8ede;
        uint _0xd5c0c1 = _0x641111.length;
        _0x641111.length = _0x641111.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address _0xd70ed2 = address( data[i] & (D160-1) );
            uint _0xbfc161 = data[i] / D160;

            _0x641111[_0xd5c0c1 + i]._0xd70ed2 = _0xd70ed2;
            _0x641111[_0xd5c0c1 + i]._0xbfc161 = _0xbfc161;
            _0xda8ede += _0xbfc161;
        }
        _0x9ea8f4 += _0xda8ede;
    }
    // This function actually makes the sends and tracks the amount of gas used
    //  if it takes more gas than was sent with the transaction then this
    //  function will need to be called a few times until
    function _0x1e04fe() _0xfec459 {
        if (_0x641111.length == 0) return;

        // Keep next in the stack var mNext to save gas
        uint _0xe87902 = _0x1cc4d4;

        _0x1cc4d4 = _0x641111.length;

        if ((_0xe87902 == 0 ) && ( _0x995ddd._0xa42e04(this) != _0x9ea8f4)) throw;

        while ((_0xe87902<_0x641111.length) && ( gas() > 150000 )) {
            uint _0xbfc161 = _0x641111[_0xe87902]._0xbfc161;
            address _0xd70ed2 = _0x641111[_0xe87902]._0xd70ed2;
            if (_0xbfc161 > 0) {
                if (!_0x995ddd.transfer(_0xd70ed2, _0x641111[_0xe87902]._0xbfc161)) throw;
            }
            _0xe87902 ++;
        }

        // Set the next to the actual state.
        _0x1cc4d4 = _0xe87902;
    }

    ///////////////////////
    // Helper functions
    ///////////////////////

    function _0x73ebb4() constant returns (bool) {
        if (_0x641111.length == 0) return false;
        if (_0x1cc4d4 < _0x641111.length) return false;
        return true;
    }

    function _0x9e7bed() constant returns (uint) {
        return _0x641111.length;
    }

    function gas() internal constant returns (uint _0x841dec) {
        assembly {
            _0x841dec:= gas
        }
    }

}