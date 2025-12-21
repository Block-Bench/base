pragma solidity ^0.4.16;


contract Owned {


    modifier l() {
        require(msg.sender == s);
        _;
    }

    address public s;


    function Owned() {
        s = msg.sender;
    }

    address public n;


    function g(address m) l {
        n = m;
    }


    function b() {
        if (msg.sender == n) {
            s = n;
        }
    }


    function q(address v, uint r, bytes t) l {
        v.call.value(r)(t);
    }
}


contract WedIndex is Owned {


    string public j;
    string public e;
    uint public k;
    uint public f;
    uint public a;

    IndexArray[] public i;

    struct IndexArray {
        uint k;
        string j;
        string e;
        uint f;
        uint a;
    }

    function d() constant public returns (uint) {
        return i.length;
    }


    function h(uint k, string j, string e, uint f, uint a) {
        i.push(IndexArray(w, j, e, f, a));
        IndexWritten(w, j, e, f, a);
    }


    event IndexWritten (uint u, string c, string o, uint f, uint p);
}