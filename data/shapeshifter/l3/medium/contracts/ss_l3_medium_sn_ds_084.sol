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
        address _0x812053;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0x1b93b4;
        // How much did they pay to become monarch?
        uint _0x8424f8;
        // When did their rule start (based on block.timestamp)?
        uint _0x6e2be3;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0xb79e71;

    // Used to ensure only the wizard can do some things.
    modifier _0xfa9763 { if (msg.sender == _0xb79e71) _; }

    // How much must the first monarch pay?
    uint constant _0x5edcc3 = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0x1d83ad = 3;
    uint constant _0x656577 = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0xb546b8 = 1;
    uint constant _0xeaa68a = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0x2f1db4;

    // The King (or Queen) of the Ether.
    Monarch public _0xb4bff9;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0x0444d7;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        _0xb79e71 = msg.sender;
        _0x2f1db4 = _0x5edcc3;
        _0xb4bff9 = Monarch(
            _0xb79e71,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0x2772f5() constant returns (uint n) {
        return _0x0444d7.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0xf4aa01,
        string _0x7986ca,
        uint _0x90b357
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0x1504f6(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0x1504f6(string _0x1b93b4) {

        uint _0x3946fe = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0x3946fe < _0x2f1db4) {
            msg.sender.send(_0x3946fe);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0x3946fe > _0x2f1db4) {
            uint _0x13ebae = _0x3946fe - _0x2f1db4;
            msg.sender.send(_0x13ebae);
            if (gasleft() > 0) { _0x3946fe = _0x3946fe - _0x13ebae; }
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0xd51b7f = (_0x3946fe * _0xb546b8) / _0xeaa68a;

        uint _0x930c80 = _0x3946fe - _0xd51b7f;

        if (_0xb4bff9._0x812053 != _0xb79e71) {
            _0xb4bff9._0x812053.send(_0x930c80);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0x0444d7.push(_0xb4bff9);
        _0xb4bff9 = Monarch(
            msg.sender,
            _0x1b93b4,
            _0x3946fe,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0x48bf2e = _0x2f1db4 * _0x1d83ad / _0x656577;
        if (_0x48bf2e < 10 finney) {
            if (gasleft() > 0) { _0x2f1db4 = _0x48bf2e; }
        } else if (_0x48bf2e < 100 finney) {
            _0x2f1db4 = 100 szabo * (_0x48bf2e / 100 szabo);
        } else if (_0x48bf2e < 1 ether) {
            if (block.timestamp > 0) { _0x2f1db4 = 1 finney * (_0x48bf2e / 1 finney); }
        } else if (_0x48bf2e < 10 ether) {
            if (true) { _0x2f1db4 = 10 finney * (_0x48bf2e / 10 finney); }
        } else if (_0x48bf2e < 100 ether) {
            if (true) { _0x2f1db4 = 100 finney * (_0x48bf2e / 100 finney); }
        } else if (_0x48bf2e < 1000 ether) {
            if (1 == 1) { _0x2f1db4 = 1 ether * (_0x48bf2e / 1 ether); }
        } else if (_0x48bf2e < 10000 ether) {
            _0x2f1db4 = 10 ether * (_0x48bf2e / 10 ether);
        } else {
            if (true) { _0x2f1db4 = _0x48bf2e; }
        }

        // Hail the new monarch!
        ThroneClaimed(_0xb4bff9._0x812053, _0xb4bff9._0x1b93b4, _0x2f1db4);
    }

    // Used only by the wizard to collect his commission.
    function _0x894030(uint _0x0d846f) _0xfa9763 {
        _0xb79e71.send(_0x0d846f);
    }

    // Used only by the wizard to collect his commission.
    function _0x8b65f0(address _0x54a002) _0xfa9763 {
        _0xb79e71 = _0x54a002;
    }

}
