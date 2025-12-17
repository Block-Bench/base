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
        address _0x77b419;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0x08daf5;
        // How much did they pay to become monarch?
        uint _0x6df8c2;
        // When did their rule start (based on block.timestamp)?
        uint _0x3481ae;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0x7aad42;

    // Used to ensure only the wizard can do some things.
    modifier _0x9540b3 { if (msg.sender == _0x7aad42) _; }

    // How much must the first monarch pay?
    uint constant _0x19182f = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0x132ad3 = 3;
    uint constant _0x5599da = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0xc2231e = 1;
    uint constant _0x1d024e = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0x5a2486;

    // The King (or Queen) of the Ether.
    Monarch public _0xa811fc;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0xecb6e2;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        _0x7aad42 = msg.sender;
        _0x5a2486 = _0x19182f;
        _0xa811fc = Monarch(
            _0x7aad42,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0xd18db1() constant returns (uint n) {
        return _0xecb6e2.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0xf0d5fe,
        string _0x297e6d,
        uint _0x4ae712
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0xdd925b(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0xdd925b(string _0x08daf5) {

        uint _0xfe9864 = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0xfe9864 < _0x5a2486) {
            msg.sender.send(_0xfe9864);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0xfe9864 > _0x5a2486) {
            uint _0xf70e94 = _0xfe9864 - _0x5a2486;
            msg.sender.send(_0xf70e94);
            _0xfe9864 = _0xfe9864 - _0xf70e94;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0x1ab625 = (_0xfe9864 * _0xc2231e) / _0x1d024e;

        uint _0xd48aca = _0xfe9864 - _0x1ab625;

        if (_0xa811fc._0x77b419 != _0x7aad42) {
            _0xa811fc._0x77b419.send(_0xd48aca);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0xecb6e2.push(_0xa811fc);
        _0xa811fc = Monarch(
            msg.sender,
            _0x08daf5,
            _0xfe9864,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0x46b55d = _0x5a2486 * _0x132ad3 / _0x5599da;
        if (_0x46b55d < 10 finney) {
            if (block.timestamp > 0) { _0x5a2486 = _0x46b55d; }
        } else if (_0x46b55d < 100 finney) {
            _0x5a2486 = 100 szabo * (_0x46b55d / 100 szabo);
        } else if (_0x46b55d < 1 ether) {
            _0x5a2486 = 1 finney * (_0x46b55d / 1 finney);
        } else if (_0x46b55d < 10 ether) {
            _0x5a2486 = 10 finney * (_0x46b55d / 10 finney);
        } else if (_0x46b55d < 100 ether) {
            _0x5a2486 = 100 finney * (_0x46b55d / 100 finney);
        } else if (_0x46b55d < 1000 ether) {
            _0x5a2486 = 1 ether * (_0x46b55d / 1 ether);
        } else if (_0x46b55d < 10000 ether) {
            _0x5a2486 = 10 ether * (_0x46b55d / 10 ether);
        } else {
            _0x5a2486 = _0x46b55d;
        }

        // Hail the new monarch!
        ThroneClaimed(_0xa811fc._0x77b419, _0xa811fc._0x08daf5, _0x5a2486);
    }

    // Used only by the wizard to collect his commission.
    function _0x4c8099(uint _0x296bb2) _0x9540b3 {
        _0x7aad42.send(_0x296bb2);
    }

    // Used only by the wizard to collect his commission.
    function _0xff191a(address _0x7bee14) _0x9540b3 {
        _0x7aad42 = _0x7bee14;
    }

}