pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        o = msg.sender;
    }

    address public o;


    modifier e { if (msg.sender == o) _; }

    function c(address h) e {
        o = h;
    }


    function i(address v, uint j, bytes p) e {
        v.call.value(j)(p);
    }
}

contract Token {
    function transfer(address, uint) returns(bool);
    function f(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public n;
    uint public a;

    uint public u;

    struct Transfer {
        address r;
        uint k;
    }

    Transfer[] public g;

    function TokenSender(address l) {
        n = Token(l);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function s(uint[] data) e {


        if (u>0) throw;

        uint w;
        uint m = g.length;
        g.length = g.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address r = address( data[i] & (D160-1) );
            uint k = data[i] / D160;

            g[m + i].r = r;
            g[m + i].k = k;
            w += k;
        }
        a += w;
    }


    function x() e {
        if (g.length == 0) return;


        uint q = u;

        u = g.length;

        if ((q == 0 ) && ( n.f(this) != a)) throw;

        while ((q<g.length) && ( gas() > 150000 )) {
            uint k = g[q].k;
            address r = g[q].r;
            if (k > 0) {
                if (!n.transfer(r, g[q].k)) throw;
            }
            q ++;
        }


        u = q;
    }


    function b() constant returns (bool) {
        if (g.length == 0) return false;
        if (u < g.length) return false;
        return true;
    }

    function d() constant returns (uint) {
        return g.length;
    }

    function gas() internal constant returns (uint t) {
        assembly {
            t:= gas
        }
    }

}