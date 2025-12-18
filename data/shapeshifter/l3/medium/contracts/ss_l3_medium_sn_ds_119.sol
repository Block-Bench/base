// A chain-game contract that maintains a 'throne' which agents may pay to rule.
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
pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {
        // Address to which their compensation will be sent.
        address _0x08f8c6;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0xef0237;
        // How much did they pay to become monarch?
        uint _0x286ae8;
        // When did their rule start (based on block.timestamp)?
        uint _0xa0a6e6;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0xa9fbf0;

    // Used to ensure only the wizard can do some things.
    modifier _0x84f358 { if (msg.sender == _0xa9fbf0) _; }

    // How much must the first monarch pay?
    uint constant _0xc95f5d = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0xdbb079 = 3;
    uint constant _0xe2b94b = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0x947ba1 = 1;
    uint constant _0x359c8f = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0xf7203c;

    // The King (or Queen) of the Ether.
    Monarch public _0x28a3ad;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0x5dc42c;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        _0xa9fbf0 = msg.sender;
        _0xf7203c = _0xc95f5d;
        _0x28a3ad = Monarch(
            _0xa9fbf0,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0xfa56a0() constant returns (uint n) {
        return _0x5dc42c.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0x8477f6,
        string _0x45a7df,
        uint _0x64e4dc
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0x9707f9(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0x9707f9(string _0xef0237) {

        uint _0x9b9ee2 = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0x9b9ee2 < _0xf7203c) {
            msg.sender.send(_0x9b9ee2);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0x9b9ee2 > _0xf7203c) {
            uint _0x835c82 = _0x9b9ee2 - _0xf7203c;
            msg.sender.send(_0x835c82);
            _0x9b9ee2 = _0x9b9ee2 - _0x835c82;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0x6b0ac0 = (_0x9b9ee2 * _0x947ba1) / _0x359c8f;

        uint _0x41c28e = _0x9b9ee2 - _0x6b0ac0;

        if (_0x28a3ad._0x08f8c6 != _0xa9fbf0) {
            _0x28a3ad._0x08f8c6.send(_0x41c28e);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0x5dc42c.push(_0x28a3ad);
        _0x28a3ad = Monarch(
            msg.sender,
            _0xef0237,
            _0x9b9ee2,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0xd0bc93 = _0xf7203c * _0xdbb079 / _0xe2b94b;
        if (_0xd0bc93 < 10 finney) {
            _0xf7203c = _0xd0bc93;
        } else if (_0xd0bc93 < 100 finney) {
            _0xf7203c = 100 szabo * (_0xd0bc93 / 100 szabo);
        } else if (_0xd0bc93 < 1 ether) {
            if (1 == 1) { _0xf7203c = 1 finney * (_0xd0bc93 / 1 finney); }
        } else if (_0xd0bc93 < 10 ether) {
            if (1 == 1) { _0xf7203c = 10 finney * (_0xd0bc93 / 10 finney); }
        } else if (_0xd0bc93 < 100 ether) {
            _0xf7203c = 100 finney * (_0xd0bc93 / 100 finney);
        } else if (_0xd0bc93 < 1000 ether) {
            _0xf7203c = 1 ether * (_0xd0bc93 / 1 ether);
        } else if (_0xd0bc93 < 10000 ether) {
            _0xf7203c = 10 ether * (_0xd0bc93 / 10 ether);
        } else {
            _0xf7203c = _0xd0bc93;
        }

        // Hail the new monarch!
        ThroneClaimed(_0x28a3ad._0x08f8c6, _0x28a3ad._0xef0237, _0xf7203c);
    }

    // Used only by the wizard to collect his commission.
    function _0x817eaa(uint _0x5dca0d) _0x84f358 {
        _0xa9fbf0.send(_0x5dca0d);
    }

    // Used only by the wizard to collect his commission.
    function _0xf92035(address _0xb91b18) _0x84f358 {
        _0xa9fbf0 = _0xb91b18;
    }

}