pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address aa;
        uint s;
    }

    event RaffleResult(
        uint s,
        uint c,
        address a,
        address y,
        address x,
        uint w,
        bytes32 r
    );

    event TicketPurchase(
        uint s,
        address l,
        uint number
    );

    event TicketRefund(
        uint s,
        address l,
        uint number
    );


    uint public constant v = 2.5 ether;
    uint public constant ac = 0.03 ether;
    uint public constant e = 50;
    uint public constant b = (v + ac) / e;
    address k;


    bool public u = false;
    uint public s = 1;
    uint public h = block.number;
    uint j = 0;
    mapping (uint => Contestant) g;
    uint[] ab;


    function Ethraffle_v4b() public {
        k = msg.sender;
    }


    function () payable public {
        m();
    }

    function m() payable public {
        if (u) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint p = msg.value;

        while (p >= b && j < e) {
            uint i = 0;
            if (ab.length > 0) {
                i = ab[ab.length-1];
                ab.length--;
            } else {
                i = j++;
            }

            g[i] = Contestant(msg.sender, s);
            TicketPurchase(s, msg.sender, i);
            p -= b;
        }


        if (j == e) {
            d();
        }


        if (p > 0) {
            msg.sender.transfer(p);
        }
    }

    function d() private {
        address y = g[uint(block.coinbase) % e].aa;
        address x = g[uint(msg.sender) % e].aa;
        uint w = block.difficulty;
        bytes32 r = q(y, x, w);

        uint c = uint(r) % e;
        address a = g[c].aa;
        RaffleResult(s, c, a, y, x, w, r);


        s++;
        j = 0;
        h = block.number;


        a.transfer(v);
        k.transfer(ac);
    }


    function o() public {
        uint t = 0;
        for (uint i = 0; i < e; i++) {
            if (msg.sender == g[i].aa && s == g[i].s) {
                t += b;
                g[i] = Contestant(address(0), 0);
                ab.push(i);
                TicketRefund(s, msg.sender, i);
            }
        }

        if (t > 0) {
            msg.sender.transfer(t);
        }
    }


    function n() public {
        if (msg.sender == k) {
            u = true;

            for (uint i = 0; i < e; i++) {
                if (s == g[i].s) {
                    TicketRefund(s, g[i].aa, i);
                    g[i].aa.transfer(b);
                }
            }

            RaffleResult(s, e, address(0), address(0), address(0), 0, 0);
            s++;
            j = 0;
            h = block.number;
            ab.length = 0;
        }
    }

    function f() public {
        if (msg.sender == k) {
            u = !u;
        }
    }

    function z() public {
        if (msg.sender == k) {
            selfdestruct(k);
        }
    }
}