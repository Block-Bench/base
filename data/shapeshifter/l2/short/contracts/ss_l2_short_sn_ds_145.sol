// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address z;
        uint s;
    }

    event RaffleResult(
        uint s,
        uint c,
        address a,
        address w,
        address x,
        uint v,
        bytes32 r
    );

    event TicketPurchase(
        uint s,
        address k,
        uint number
    );

    event TicketRefund(
        uint s,
        address k,
        uint number
    );

    // Constants
    uint public constant y = 2.5 ether;
    uint public constant ac = 0.03 ether;
    uint public constant d = 50;
    uint public constant b = (y + ac) / d; // Make sure this divides evenly
    address i;

    // Other internal variables
    bool public t = false;
    uint public s = 1;
    uint public g = block.number;
    uint j = 0;
    mapping (uint => Contestant) h;
    uint[] ab;

    // Initialization
    function Ethraffle_v4b() public {
        i = msg.sender;
    }

    // Call buyTickets() when receiving Ether outside a function
    function () payable public {
        m();
    }

    function m() payable public {
        if (t) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint p = msg.value;

        while (p >= b && j < d) {
            uint l = 0;
            if (ab.length > 0) {
                l = ab[ab.length-1];
                ab.length--;
            } else {
                l = j++;
            }

            h[l] = Contestant(msg.sender, s);
            TicketPurchase(s, msg.sender, l);
            p -= b;
        }

        // Choose winner if we sold all the tickets
        if (j == d) {
            e();
        }

        // Send back leftover money
        if (p > 0) {
            msg.sender.transfer(p);
        }
    }

    function e() private {
        address w = h[uint(block.coinbase) % d].z;
        address x = h[uint(msg.sender) % d].z;
        uint v = block.difficulty;
        bytes32 r = o(w, x, v);

        uint c = uint(r) % d;
        address a = h[c].z;
        RaffleResult(s, c, a, w, x, v, r);

        // Start next raffle
        s++;
        j = 0;
        g = block.number;

        // gaps.length = 0 isn't necessary here,
        // because buyTickets() eventually clears
        // the gaps array in the loop itself.

        // Distribute prize and fee
        a.transfer(y);
        i.transfer(ac);
    }

    // Get your money back before the raffle occurs
    function q() public {
        uint u = 0;
        for (uint i = 0; i < d; i++) {
            if (msg.sender == h[i].z && s == h[i].s) {
                u += b;
                h[i] = Contestant(address(0), 0);
                ab.push(i);
                TicketRefund(s, msg.sender, i);
            }
        }

        if (u > 0) {
            msg.sender.transfer(u);
        }
    }

    // Refund everyone's money, start a new raffle, then pause it
    function n() public {
        if (msg.sender == i) {
            t = true;

            for (uint i = 0; i < d; i++) {
                if (s == h[i].s) {
                    TicketRefund(s, h[i].z, i);
                    h[i].z.transfer(b);
                }
            }

            RaffleResult(s, d, address(0), address(0), address(0), 0, 0);
            s++;
            j = 0;
            g = block.number;
            ab.length = 0;
        }
    }

    function f() public {
        if (msg.sender == i) {
            t = !t;
        }
    }

    function aa() public {
        if (msg.sender == i) {
            selfdestruct(i);
        }
    }
}