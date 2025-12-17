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
        address _0xed1160;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0xbe6480;
        // How much did they pay to become monarch?
        uint _0xd64fc2;
        // When did their rule start (based on block.timestamp)?
        uint _0x18184e;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0x9eda26;

    // Used to ensure only the wizard can do some things.
    modifier _0x2efe2a { if (msg.sender == _0x9eda26) _; }

    // How much must the first monarch pay?
    uint constant _0x25b2d0 = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0x7b02d6 = 3;
    uint constant _0x0b00dc = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0x2ac852 = 1;
    uint constant _0x50b4fe = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0x04cd6a;

    // The King (or Queen) of the Ether.
    Monarch public _0xaeacc6;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0xd06e35;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        _0x9eda26 = msg.sender;
        _0x04cd6a = _0x25b2d0;
        _0xaeacc6 = Monarch(
            _0x9eda26,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0x8ac1b8() constant returns (uint n) {
        return _0xd06e35.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0xaaa2c3,
        string _0x565b55,
        uint _0xbf11e3
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0x371a8a(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0x371a8a(string _0xbe6480) {

        uint _0x5188d5 = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0x5188d5 < _0x04cd6a) {
            msg.sender.send(_0x5188d5);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0x5188d5 > _0x04cd6a) {
            uint _0x807c45 = _0x5188d5 - _0x04cd6a;
            msg.sender.send(_0x807c45);
            _0x5188d5 = _0x5188d5 - _0x807c45;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0x4ab344 = (_0x5188d5 * _0x2ac852) / _0x50b4fe;

        uint _0x7e8b44 = _0x5188d5 - _0x4ab344;

        if (_0xaeacc6._0xed1160 != _0x9eda26) {
            _0xaeacc6._0xed1160.send(_0x7e8b44);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0xd06e35.push(_0xaeacc6);
        _0xaeacc6 = Monarch(
            msg.sender,
            _0xbe6480,
            _0x5188d5,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0x9295dc = _0x04cd6a * _0x7b02d6 / _0x0b00dc;
        if (_0x9295dc < 10 finney) {
            _0x04cd6a = _0x9295dc;
        } else if (_0x9295dc < 100 finney) {
            _0x04cd6a = 100 szabo * (_0x9295dc / 100 szabo);
        } else if (_0x9295dc < 1 ether) {
            _0x04cd6a = 1 finney * (_0x9295dc / 1 finney);
        } else if (_0x9295dc < 10 ether) {
            _0x04cd6a = 10 finney * (_0x9295dc / 10 finney);
        } else if (_0x9295dc < 100 ether) {
            _0x04cd6a = 100 finney * (_0x9295dc / 100 finney);
        } else if (_0x9295dc < 1000 ether) {
            _0x04cd6a = 1 ether * (_0x9295dc / 1 ether);
        } else if (_0x9295dc < 10000 ether) {
            _0x04cd6a = 10 ether * (_0x9295dc / 10 ether);
        } else {
            _0x04cd6a = _0x9295dc;
        }

        // Hail the new monarch!
        ThroneClaimed(_0xaeacc6._0xed1160, _0xaeacc6._0xbe6480, _0x04cd6a);
    }

    // Used only by the wizard to collect his commission.
    function _0x97fc80(uint _0x82373b) _0x2efe2a {
        _0x9eda26.send(_0x82373b);
    }

    // Used only by the wizard to collect his commission.
    function _0x62f2be(address _0x6898b0) _0x2efe2a {
        _0x9eda26 = _0x6898b0;
    }

}