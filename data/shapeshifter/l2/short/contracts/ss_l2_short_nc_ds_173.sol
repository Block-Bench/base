pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        n = msg.sender;
    }

    address public n;


    modifier f { if (msg.sender == n) _; }

    function c(address g) f {
        n = g;
    }


    function i(address u, uint l, bytes q) f {
        u.call.value(l)(q);
    }
}

contract Token {
    function transfer(address, uint) returns(bool);
    function h(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public p;
    uint public a;

    uint public v;

    struct Transfer {
        address t;
        uint j;
    }

    Transfer[] public e;

    function TokenSender(address m) {
        p = Token(m);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function r(uint[] data) f {


        if (v>0) throw;

        uint x;
        uint k = e.length;
        e.length = e.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address t = address( data[i] & (D160-1) );
            uint j = data[i] / D160;

            e[k + i].t = t;
            e[k + i].j = j;
            x += j;
        }
        a += x;
    }


    function w() f {
        if (e.length == 0) return;


        uint o = v;

        v = e.length;

        if ((o == 0 ) && ( p.h(this) != a)) throw;

        while ((o<e.length) && ( gas() > 150000 )) {
            uint j = e[o].j;
            address t = e[o].t;
            if (j > 0) {
                if (!p.transfer(t, e[o].j)) throw;
            }
            o ++;
        }


        v = o;
    }


    function b() constant returns (bool) {
        if (e.length == 0) return false;
        if (v < e.length) return false;
        return true;
    }

    function d() constant returns (uint) {
        return e.length;
    }

    function gas() internal constant returns (uint s) {
        assembly {
            s:= gas
        }
    }

}