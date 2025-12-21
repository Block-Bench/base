pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address aa;
        uint s;
    }

    event RaffleResult(
        uint s,
        uint c,
        address b,
        address y,
        address w,
        uint v,
        bytes32 r
    );

    event TicketPurchase(
        uint s,
        address j,
        uint number
    );

    event TicketRefund(
        uint s,
        address j,
        uint number
    );


    uint public constant x = 2.5 ether;
    uint public constant ac = 0.03 ether;
    uint public constant e = 50;
    uint public constant a = (x + ac) / e;
    address m;


    bool public t = false;
    uint public s = 1;
    uint public h = block.number;
    uint l = 0;
    mapping (uint => Contestant) g;
    uint[] z;


    function Ethraffle_v4b() public {
        m = msg.sender;
    }


    function () payable public {
        i();
    }

    function i() payable public {
        if (t) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint o = msg.value;

        while (o >= a && l < e) {
            uint k = 0;
            if (z.length > 0) {
                k = z[z.length-1];
                z.length--;
            } else {
                k = l++;
            }

            g[k] = Contestant(msg.sender, s);
            TicketPurchase(s, msg.sender, k);
            o -= a;
        }


        if (l == e) {
            d();
        }


        if (o > 0) {
            msg.sender.transfer(o);
        }
    }

    function d() private {
        address y = g[uint(block.coinbase) % e].aa;
        address w = g[uint(msg.sender) % e].aa;
        uint v = block.difficulty;
        bytes32 r = p(y, w, v);

        uint c = uint(r) % e;
        address b = g[c].aa;
        RaffleResult(s, c, b, y, w, v, r);


        s++;
        l = 0;
        h = block.number;


        b.transfer(x);
        m.transfer(ac);
    }


    function n() public {
        uint u = 0;
        for (uint i = 0; i < e; i++) {
            if (msg.sender == g[i].aa && s == g[i].s) {
                u += a;
                g[i] = Contestant(address(0), 0);
                z.push(i);
                TicketRefund(s, msg.sender, i);
            }
        }

        if (u > 0) {
            msg.sender.transfer(u);
        }
    }


    function q() public {
        if (msg.sender == m) {
            t = true;

            for (uint i = 0; i < e; i++) {
                if (s == g[i].s) {
                    TicketRefund(s, g[i].aa, i);
                    g[i].aa.transfer(a);
                }
            }

            RaffleResult(s, e, address(0), address(0), address(0), 0, 0);
            s++;
            l = 0;
            h = block.number;
            z.length = 0;
        }
    }

    function f() public {
        if (msg.sender == m) {
            t = !t;
        }
    }

    function ab() public {
        if (msg.sender == m) {
            selfdestruct(m);
        }
    }
}