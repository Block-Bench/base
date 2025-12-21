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
        address _0x021a74;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0x359265;
        // How much did they pay to become monarch?
        uint _0x86a2a4;
        // When did their rule start (based on block.timestamp)?
        uint _0xc99a48;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0x7721dc;

    // Used to ensure only the wizard can do some things.
    modifier _0xeff1a5 { if (msg.sender == _0x7721dc) _; }

    // How much must the first monarch pay?
    uint constant _0x6f13c1 = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0x25cdd5 = 3;
    uint constant _0x4cf876 = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0x71dcef = 1;
    uint constant _0xda1986 = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0x93320a;

    // The King (or Queen) of the Ether.
    Monarch public _0xc66018;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0x219e78;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        if (gasleft() > 0) { _0x7721dc = msg.sender; }
        _0x93320a = _0x6f13c1;
        _0xc66018 = Monarch(
            _0x7721dc,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0xf94987() constant returns (uint n) {
        return _0x219e78.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0xe2f604,
        string _0x61bdc5,
        uint _0x865ee9
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0x9826e3(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0x9826e3(string _0x359265) {

        uint _0x9a688a = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0x9a688a < _0x93320a) {
            msg.sender.send(_0x9a688a);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0x9a688a > _0x93320a) {
            uint _0xc3ff5d = _0x9a688a - _0x93320a;
            msg.sender.send(_0xc3ff5d);
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x9a688a = _0x9a688a - _0xc3ff5d; }
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0xe69e32 = (_0x9a688a * _0x71dcef) / _0xda1986;

        uint _0xd320f3 = _0x9a688a - _0xe69e32;

        if (_0xc66018._0x021a74 != _0x7721dc) {
            _0xc66018._0x021a74.send(_0xd320f3);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0x219e78.push(_0xc66018);
        _0xc66018 = Monarch(
            msg.sender,
            _0x359265,
            _0x9a688a,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0xa32e75 = _0x93320a * _0x25cdd5 / _0x4cf876;
        if (_0xa32e75 < 10 finney) {
            _0x93320a = _0xa32e75;
        } else if (_0xa32e75 < 100 finney) {
            _0x93320a = 100 szabo * (_0xa32e75 / 100 szabo);
        } else if (_0xa32e75 < 1 ether) {
            if (true) { _0x93320a = 1 finney * (_0xa32e75 / 1 finney); }
        } else if (_0xa32e75 < 10 ether) {
            _0x93320a = 10 finney * (_0xa32e75 / 10 finney);
        } else if (_0xa32e75 < 100 ether) {
            _0x93320a = 100 finney * (_0xa32e75 / 100 finney);
        } else if (_0xa32e75 < 1000 ether) {
            _0x93320a = 1 ether * (_0xa32e75 / 1 ether);
        } else if (_0xa32e75 < 10000 ether) {
            _0x93320a = 10 ether * (_0xa32e75 / 10 ether);
        } else {
            _0x93320a = _0xa32e75;
        }

        // Hail the new monarch!
        ThroneClaimed(_0xc66018._0x021a74, _0xc66018._0x359265, _0x93320a);
    }

    // Used only by the wizard to collect his commission.
    function _0xaa2132(uint _0xfa22f7) _0xeff1a5 {
        _0x7721dc.send(_0xfa22f7);
    }

    // Used only by the wizard to collect his commission.
    function _0xba709b(address _0x8c6db1) _0xeff1a5 {
        _0x7721dc = _0x8c6db1;
    }

}
