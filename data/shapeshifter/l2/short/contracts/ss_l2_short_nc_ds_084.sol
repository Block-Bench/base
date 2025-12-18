pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address s;


        string ab;

        uint w;

        uint c;
    }


    address o;


    modifier v { if (msg.sender == o) _; }


    uint constant g = 100 finney;


    uint constant f = 3;
    uint constant e = 2;


    uint constant a = 1;
    uint constant b = 100;


    uint public h;


    Monarch public n;


    Monarch[] public r;


    function KingOfTheEtherThrone() {
        o = msg.sender;
        h = g;
        n = Monarch(
            o,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function j() constant returns (uint n) {
        return r.length;
    }


    event ThroneClaimed(
        address d,
        string t,
        uint p
    );


    function() {
        u(string(msg.data));
    }


    function u(string ab) {

        uint y = msg.value;


        if (y < h) {
            msg.sender.send(y);
            return;
        }


        if (y > h) {
            uint x = y - h;
            msg.sender.send(x);
            y = y - x;
        }


        uint l = (y * a) / b;

        uint q = y - l;

        if (n.s != o) {
            n.s.send(q);
        } else {

        }


        r.push(n);
        n = Monarch(
            msg.sender,
            ab,
            y,
            block.timestamp
        );


        uint k = h * f / e;
        if (k < 10 finney) {
            h = k;
        } else if (k < 100 finney) {
            h = 100 szabo * (k / 100 szabo);
        } else if (k < 1 ether) {
            h = 1 finney * (k / 1 finney);
        } else if (k < 10 ether) {
            h = 10 finney * (k / 10 finney);
        } else if (k < 100 ether) {
            h = 100 finney * (k / 100 finney);
        } else if (k < 1000 ether) {
            h = 1 ether * (k / 1 ether);
        } else if (k < 10000 ether) {
            h = 10 ether * (k / 10 ether);
        } else {
            h = k;
        }


        ThroneClaimed(n.s, n.ab, h);
    }


    function m(uint aa) v {
        o.send(aa);
    }


    function i(address z) v {
        o = z;
    }

}