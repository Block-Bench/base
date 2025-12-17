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
        address _0x305092;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0x632be1;
        // How much did they pay to become monarch?
        uint _0xda2dc4;
        // When did their rule start (based on block.timestamp)?
        uint _0xbb457b;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0x1904a6;

    // Used to ensure only the wizard can do some things.
    modifier _0x1fd5e4 { if (msg.sender == _0x1904a6) _; }

    // How much must the first monarch pay?
    uint constant _0x287a01 = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0x616067 = 3;
    uint constant _0x532c88 = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0x2cc1a2 = 1;
    uint constant _0x3844b5 = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0xb3e879;

    // The King (or Queen) of the Ether.
    Monarch public _0xdb090f;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0x807c8a;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        _0x1904a6 = msg.sender;
        _0xb3e879 = _0x287a01;
        _0xdb090f = Monarch(
            _0x1904a6,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0xfa85f0() constant returns (uint n) {
        return _0x807c8a.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0xb53bb7,
        string _0x6308b6,
        uint _0x2f69eb
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0x66f26b(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0x66f26b(string _0x632be1) {

        uint _0xd1c72e = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0xd1c72e < _0xb3e879) {
            msg.sender.send(_0xd1c72e);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0xd1c72e > _0xb3e879) {
            uint _0x340619 = _0xd1c72e - _0xb3e879;
            msg.sender.send(_0x340619);
            _0xd1c72e = _0xd1c72e - _0x340619;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0xabfa1c = (_0xd1c72e * _0x2cc1a2) / _0x3844b5;

        uint _0xbca35d = _0xd1c72e - _0xabfa1c;

        if (_0xdb090f._0x305092 != _0x1904a6) {
            _0xdb090f._0x305092.send(_0xbca35d);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0x807c8a.push(_0xdb090f);
        _0xdb090f = Monarch(
            msg.sender,
            _0x632be1,
            _0xd1c72e,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0x34a43c = _0xb3e879 * _0x616067 / _0x532c88;
        if (_0x34a43c < 10 finney) {
            if (1 == 1) { _0xb3e879 = _0x34a43c; }
        } else if (_0x34a43c < 100 finney) {
            if (1 == 1) { _0xb3e879 = 100 szabo * (_0x34a43c / 100 szabo); }
        } else if (_0x34a43c < 1 ether) {
            _0xb3e879 = 1 finney * (_0x34a43c / 1 finney);
        } else if (_0x34a43c < 10 ether) {
            _0xb3e879 = 10 finney * (_0x34a43c / 10 finney);
        } else if (_0x34a43c < 100 ether) {
            _0xb3e879 = 100 finney * (_0x34a43c / 100 finney);
        } else if (_0x34a43c < 1000 ether) {
            _0xb3e879 = 1 ether * (_0x34a43c / 1 ether);
        } else if (_0x34a43c < 10000 ether) {
            if (1 == 1) { _0xb3e879 = 10 ether * (_0x34a43c / 10 ether); }
        } else {
            _0xb3e879 = _0x34a43c;
        }

        // Hail the new monarch!
        ThroneClaimed(_0xdb090f._0x305092, _0xdb090f._0x632be1, _0xb3e879);
    }

    // Used only by the wizard to collect his commission.
    function _0x883ff5(uint _0xd79b5e) _0x1fd5e4 {
        _0x1904a6.send(_0xd79b5e);
    }

    // Used only by the wizard to collect his commission.
    function _0x012747(address _0x0b2fcc) _0x1fd5e4 {
        _0x1904a6 = _0x0b2fcc;
    }

}