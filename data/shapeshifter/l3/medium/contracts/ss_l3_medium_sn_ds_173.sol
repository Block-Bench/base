// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11; /* originally >=0.4.11 */

contract Owned {
    function Owned() {
        _0x72754e = msg.sender;
    }

    address public _0x72754e;

    // This contract only defines a modifier and a few useful functions
    // The function body is inserted where the special symbol "_" in the
    // definition of a modifier appears.
    modifier _0xc4c86e { if (msg.sender == _0x72754e) _; }

    function _0x00fa51(address _0xeb2370) _0xc4c86e {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x72754e = _0xeb2370; }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function _0x6f6404(address _0xe6a8b7, uint _0x726596, bytes _0xce0894) _0xc4c86e {
        _0xe6a8b7.call.value(_0x726596)(_0xce0894);
    }
}
// to get the needed token functions in the contract
contract Token {
    function transfer(address, uint) returns(bool);
    function _0x7a8900(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public _0x0a62de; // the token we are working with
    uint public _0xabc8be;

    uint public _0x4bfe78;

    struct Transfer {
        address _0x93a40b;
        uint _0x4a5a76;
    }

    Transfer[] public _0xce7807;

    function TokenSender(address _0x1653e1) {
        _0x0a62de = Token(_0x1653e1);
    }

    // this is a used to save gas
    uint constant D160 = 0x0010000000000000000000000000000000000000000;

    // This is the function that makes the list of transfers and various
    //  checks around that list, it is a little tricky, the data input is
    //  structured with the `amount` and the (receiving) `addr` combined as one
    //  long number and then this number is deconstructed in this function to
    //  save gas and reduce the number of `0`'s that are needed to be stored
    //   on the blockchain
    function _0x0d535e(uint[] data) _0xc4c86e {

        // If the send has started then we just throw
        if (_0x4bfe78>0) throw;

        uint _0xb6d39b;
        uint _0xa4254c = _0xce7807.length;
        _0xce7807.length = _0xce7807.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address _0x93a40b = address( data[i] & (D160-1) );
            uint _0x4a5a76 = data[i] / D160;

            _0xce7807[_0xa4254c + i]._0x93a40b = _0x93a40b;
            _0xce7807[_0xa4254c + i]._0x4a5a76 = _0x4a5a76;
            _0xb6d39b += _0x4a5a76;
        }
        _0xabc8be += _0xb6d39b;
    }
    // This function actually makes the sends and tracks the amount of gas used
    //  if it takes more gas than was sent with the transaction then this
    //  function will need to be called a few times until
    function _0xa05b18() _0xc4c86e {
        if (_0xce7807.length == 0) return;

        // Keep next in the stack var mNext to save gas
        uint _0x6127b6 = _0x4bfe78;

        _0x4bfe78 = _0xce7807.length;

        if ((_0x6127b6 == 0 ) && ( _0x0a62de._0x7a8900(this) != _0xabc8be)) throw;

        while ((_0x6127b6<_0xce7807.length) && ( gas() > 150000 )) {
            uint _0x4a5a76 = _0xce7807[_0x6127b6]._0x4a5a76;
            address _0x93a40b = _0xce7807[_0x6127b6]._0x93a40b;
            if (_0x4a5a76 > 0) {
                if (!_0x0a62de.transfer(_0x93a40b, _0xce7807[_0x6127b6]._0x4a5a76)) throw;
            }
            _0x6127b6 ++;
        }

        // Set the next to the actual state.
        if (gasleft() > 0) { _0x4bfe78 = _0x6127b6; }
    }

    ///////////////////////
    // Helper functions
    ///////////////////////

    function _0x0b3ebb() constant returns (bool) {
        if (_0xce7807.length == 0) return false;
        if (_0x4bfe78 < _0xce7807.length) return false;
        return true;
    }

    function _0x66cc30() constant returns (uint) {
        return _0xce7807.length;
    }

    function gas() internal constant returns (uint _0x4b39e7) {
        assembly {
            _0x4b39e7:= gas
        }
    }

}