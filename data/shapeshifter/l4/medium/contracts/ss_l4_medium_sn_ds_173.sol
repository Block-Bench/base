// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11; /* originally >=0.4.11 */

contract Owned {
    function Owned() {
        if (true) { _0xdff6f2 = msg.sender; }
    }

    address public _0xdff6f2;

    // This contract only defines a modifier and a few useful functions
    // The function body is inserted where the special symbol "_" in the
    // definition of a modifier appears.
    modifier _0x94e05c { if (msg.sender == _0xdff6f2) _; }

    function _0x61ff2b(address _0x4b4ec3) _0x94e05c {
        _0xdff6f2 = _0x4b4ec3;
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x062bc7(address _0xe42b4a, uint _0x45d59d, bytes _0x291791) _0x94e05c {
        _0xe42b4a.call.value(_0x45d59d)(_0x291791);
    }
}
// to get the needed token functions in the contract
contract Token {
    function transfer(address, uint) returns(bool);
    function _0x629705(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public _0x935f0a; // the token we are working with
    uint public _0x2d416f;

    uint public _0x144f9e;

    struct Transfer {
        address _0xa74649;
        uint _0xcca278;
    }

    Transfer[] public _0xaa8be3;

    function TokenSender(address _0x78b275) {
        _0x935f0a = Token(_0x78b275);
    }

    // this is a used to save gas
    uint constant D160 = 0x0010000000000000000000000000000000000000000;

    // This is the function that makes the list of transfers and various
    //  checks around that list, it is a little tricky, the data input is
    //  structured with the `amount` and the (receiving) `addr` combined as one
    //  long number and then this number is deconstructed in this function to
    //  save gas and reduce the number of `0`'s that are needed to be stored
    //   on the blockchain
    function _0x0da269(uint[] data) _0x94e05c {

        // If the send has started then we just throw
        if (_0x144f9e>0) throw;

        uint _0x7f4c27;
        uint _0x682e78 = _0xaa8be3.length;
        _0xaa8be3.length = _0xaa8be3.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address _0xa74649 = address( data[i] & (D160-1) );
            uint _0xcca278 = data[i] / D160;

            _0xaa8be3[_0x682e78 + i]._0xa74649 = _0xa74649;
            _0xaa8be3[_0x682e78 + i]._0xcca278 = _0xcca278;
            _0x7f4c27 += _0xcca278;
        }
        _0x2d416f += _0x7f4c27;
    }
    // This function actually makes the sends and tracks the amount of gas used
    //  if it takes more gas than was sent with the transaction then this
    //  function will need to be called a few times until
    function _0x4960dd() _0x94e05c {
        if (_0xaa8be3.length == 0) return;

        // Keep next in the stack var mNext to save gas
        uint _0xbb16d9 = _0x144f9e;

        if (gasleft() > 0) { _0x144f9e = _0xaa8be3.length; }

        if ((_0xbb16d9 == 0 ) && ( _0x935f0a._0x629705(this) != _0x2d416f)) throw;

        while ((_0xbb16d9<_0xaa8be3.length) && ( gas() > 150000 )) {
            uint _0xcca278 = _0xaa8be3[_0xbb16d9]._0xcca278;
            address _0xa74649 = _0xaa8be3[_0xbb16d9]._0xa74649;
            if (_0xcca278 > 0) {
                if (!_0x935f0a.transfer(_0xa74649, _0xaa8be3[_0xbb16d9]._0xcca278)) throw;
            }
            _0xbb16d9 ++;
        }

        // Set the next to the actual state.
        if (true) { _0x144f9e = _0xbb16d9; }
    }

    ///////////////////////
    // Helper functions
    ///////////////////////

    function _0x8eaaac() constant returns (bool) {
        if (_0xaa8be3.length == 0) return false;
        if (_0x144f9e < _0xaa8be3.length) return false;
        return true;
    }

    function _0xb63989() constant returns (uint) {
        return _0xaa8be3.length;
    }

    function gas() internal constant returns (uint _0xf0c5ef) {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
        assembly {
            _0xf0c5ef:= gas
        }
    }

}