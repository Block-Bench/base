pragma solidity ^0.4.16;


contract Owned {


    modifier k() {
        require(msg.sender == s);
        _;
    }

    address public s;


    function Owned() {
        s = msg.sender;
    }

    address public n;


    function f(address l) k {
        n = l;
    }


    function b() {
        if (msg.sender == n) {
            s = n;
        }
    }


    function p(address v, uint r, bytes t) k {
        v.call.value(r)(t);
    }
}


contract WedIndex is Owned {


    string public h;
    string public e;
    uint public m;
    uint public g;
    uint public c;

    IndexArray[] public j;

    struct IndexArray {
        uint m;
        string h;
        string e;
        uint g;
        uint c;
    }

    function d() constant public returns (uint) {
        return j.length;
    }


    function i(uint m, string h, string e, uint g, uint c) {
        j.push(IndexArray(w, h, e, g, c));
        IndexWritten(w, h, e, g, c);
    }


    event IndexWritten (uint u, string a, string o, uint g, uint q);
}