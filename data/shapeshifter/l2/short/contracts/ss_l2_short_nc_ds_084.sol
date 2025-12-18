pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address q;


        string ab;

        uint w;

        uint d;
    }


    address p;


    modifier x { if (msg.sender == p) _; }


    uint constant g = 100 finney;


    uint constant f = 3;
    uint constant c = 2;


    uint constant b = 1;
    uint constant a = 100;


    uint public h;


    Monarch public n;


    Monarch[] public r;


    function KingOfTheEtherThrone() {
        p = msg.sender;
        h = g;
        n = Monarch(
            p,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function l() constant returns (uint n) {
        return r.length;
    }


    event ThroneClaimed(
        address e,
        string u,
        uint o
    );


    function() {
        t(string(msg.data));
    }


    function t(string ab) {

        uint y = msg.value;


        if (y < h) {
            msg.sender.send(y);
            return;
        }


        if (y > h) {
            uint v = y - h;
            msg.sender.send(v);
            y = y - v;
        }


        uint k = (y * b) / a;

        uint s = y - k;

        if (n.q != p) {
            n.q.send(s);
        } else {

        }


        r.push(n);
        n = Monarch(
            msg.sender,
            ab,
            y,
            block.timestamp
        );


        uint j = h * f / c;
        if (j < 10 finney) {
            h = j;
        } else if (j < 100 finney) {
            h = 100 szabo * (j / 100 szabo);
        } else if (j < 1 ether) {
            h = 1 finney * (j / 1 finney);
        } else if (j < 10 ether) {
            h = 10 finney * (j / 10 finney);
        } else if (j < 100 ether) {
            h = 100 finney * (j / 100 finney);
        } else if (j < 1000 ether) {
            h = 1 ether * (j / 1 ether);
        } else if (j < 10000 ether) {
            h = 10 ether * (j / 10 ether);
        } else {
            h = j;
        }


        ThroneClaimed(n.q, n.ab, h);
    }


    function m(uint aa) x {
        p.send(aa);
    }


    function i(address z) x {
        p = z;
    }

}