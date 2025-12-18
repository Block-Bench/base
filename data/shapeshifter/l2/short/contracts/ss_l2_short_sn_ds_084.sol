// See www.kingoftheether.com & https://github.com/kieranelby/KingOfTheEtherThrone .
// (c) Kieran Elby 2016. All rights reserved.
// v0.4.0.
// Inspired by ethereumpyramid.com and the (now-gone?) "magnificent bitcoin gem".

// This contract lives on the blockchain at 0xb336a86e2feb1e87a328fcb7dd4d04de3df254d0
// and was compiled (using optimization) with:
// Solidity version: 0.2.1-fad2d4df/.-Emscripten/clang/int linked to libethereum

// For future versions it would be nice to ...
// TODO - enforce time-limit on reign (can contracts do that without external action)?
// TODO - add a random reset?
// TODO - add bitcoin bridge so agents can pay in bitcoin?
// TODO - maybe allow different return payment address?

//added pragma version
pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {
        // Address to which their compensation will be sent.
        address q;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string ab;
        // How much did they pay to become monarch?
        uint v;
        // When did their rule start (based on block.timestamp)?
        uint d;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address o;

    // Used to ensure only the wizard can do some things.
    modifier x { if (msg.sender == o) _; }

    // How much must the first monarch pay?
    uint constant g = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant f = 3;
    uint constant e = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant b = 1;
    uint constant a = 100;

    // How much must an agent pay now to become the monarch?
    uint public h;

    // The King (or Queen) of the Ether.
    Monarch public n;

    // Earliest-first list of previous throne holders.
    Monarch[] public r;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
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

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address c,
        string t,
        uint p
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        u(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function u(string ab) {

        uint y = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (y < h) {
            msg.sender.send(y);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (y > h) {
            uint w = y - h;
            msg.sender.send(w);
            y = y - w;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint k = (y * b) / a;

        uint s = y - k;

        if (n.q != o) {
            n.q.send(s);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        r.push(n);
        n = Monarch(
            msg.sender,
            ab,
            y,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint l = h * f / e;
        if (l < 10 finney) {
            h = l;
        } else if (l < 100 finney) {
            h = 100 szabo * (l / 100 szabo);
        } else if (l < 1 ether) {
            h = 1 finney * (l / 1 finney);
        } else if (l < 10 ether) {
            h = 10 finney * (l / 10 finney);
        } else if (l < 100 ether) {
            h = 100 finney * (l / 100 finney);
        } else if (l < 1000 ether) {
            h = 1 ether * (l / 1 ether);
        } else if (l < 10000 ether) {
            h = 10 ether * (l / 10 ether);
        } else {
            h = l;
        }

        // Hail the new monarch!
        ThroneClaimed(n.q, n.ab, h);
    }

    // Used only by the wizard to collect his commission.
    function m(uint aa) x {
        o.send(aa);
    }

    // Used only by the wizard to collect his commission.
    function i(address z) x {
        o = z;
    }

}
