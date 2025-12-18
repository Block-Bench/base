// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11; /* originally >=0.4.11 */

contract Owned {
    function Owned() {
        p = msg.sender;
    }

    address public p;

    // This contract only defines a modifier and a few useful functions
    // The function body is inserted where the special symbol "_" in the
    // definition of a modifier appears.
    modifier h { if (msg.sender == p) _; }

    function c(address f) h {
        p = f;
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function i(address v, uint j, bytes n) h {
        v.call.value(j)(n);
    }
}
// to get the needed token functions in the contract
contract Token {
    function transfer(address, uint) returns(bool);
    function e(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public q; // the token we are working with
    uint public a;

    uint public t;

    struct Transfer {
        address u;
        uint m;
    }

    Transfer[] public g;

    function TokenSender(address l) {
        q = Token(l);
    }

    // this is a used to save gas
    uint constant D160 = 0x0010000000000000000000000000000000000000000;

    // This is the function that makes the list of transfers and various
    //  checks around that list, it is a little tricky, the data input is
    //  structured with the `amount` and the (receiving) `addr` combined as one
    //  long number and then this number is deconstructed in this function to
    //  save gas and reduce the number of `0`'s that are needed to be stored
    //   on the blockchain
    function s(uint[] data) h {

        // If the send has started then we just throw
        if (t>0) throw;

        uint w;
        uint k = g.length;
        g.length = g.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address u = address( data[i] & (D160-1) );
            uint m = data[i] / D160;

            g[k + i].u = u;
            g[k + i].m = m;
            w += m;
        }
        a += w;
    }
    // This function actually makes the sends and tracks the amount of gas used
    //  if it takes more gas than was sent with the transaction then this
    //  function will need to be called a few times until
    function x() h {
        if (g.length == 0) return;

        // Keep next in the stack var mNext to save gas
        uint o = t;

        t = g.length;

        if ((o == 0 ) && ( q.e(this) != a)) throw;

        while ((o<g.length) && ( gas() > 150000 )) {
            uint m = g[o].m;
            address u = g[o].u;
            if (m > 0) {
                if (!q.transfer(u, g[o].m)) throw;
            }
            o ++;
        }

        // Set the next to the actual state.
        t = o;
    }

    ///////////////////////
    // Helper functions
    ///////////////////////

    function b() constant returns (bool) {
        if (g.length == 0) return false;
        if (t < g.length) return false;
        return true;
    }

    function d() constant returns (uint) {
        return g.length;
    }

    function gas() internal constant returns (uint r) {
        assembly {
            r:= gas
        }
    }

}