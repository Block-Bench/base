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
        address _0x5c609a;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0x7e42b3;
        // How much did they pay to become monarch?
        uint _0x670361;
        // When did their rule start (based on block.timestamp)?
        uint _0x7d6905;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0xcac17e;

    // Used to ensure only the wizard can do some things.
    modifier _0x2ffdfd { if (msg.sender == _0xcac17e) _; }

    // How much must the first monarch pay?
    uint constant _0xb803f3 = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0xcf1765 = 3;
    uint constant _0x4f2aef = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0x7e5526 = 1;
    uint constant _0x5fa500 = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0xf92a5b;

    // The King (or Queen) of the Ether.
    Monarch public _0xa5577d;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0x95c458;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        _0xcac17e = msg.sender;
        _0xf92a5b = _0xb803f3;
        _0xa5577d = Monarch(
            _0xcac17e,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0x47c5c0() constant returns (uint n) {
        return _0x95c458.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0x57de12,
        string _0x8b7765,
        uint _0xb3e4a3
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0xd6d4f6(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0xd6d4f6(string _0x7e42b3) {

        uint _0xad463f = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0xad463f < _0xf92a5b) {
            msg.sender.send(_0xad463f);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0xad463f > _0xf92a5b) {
            uint _0x3a2e4d = _0xad463f - _0xf92a5b;
            msg.sender.send(_0x3a2e4d);
            _0xad463f = _0xad463f - _0x3a2e4d;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0xb7bddd = (_0xad463f * _0x7e5526) / _0x5fa500;

        uint _0x538c73 = _0xad463f - _0xb7bddd;

        if (_0xa5577d._0x5c609a != _0xcac17e) {
            _0xa5577d._0x5c609a.send(_0x538c73);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0x95c458.push(_0xa5577d);
        _0xa5577d = Monarch(
            msg.sender,
            _0x7e42b3,
            _0xad463f,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0x9b99dd = _0xf92a5b * _0xcf1765 / _0x4f2aef;
        if (_0x9b99dd < 10 finney) {
            _0xf92a5b = _0x9b99dd;
        } else if (_0x9b99dd < 100 finney) {
            _0xf92a5b = 100 szabo * (_0x9b99dd / 100 szabo);
        } else if (_0x9b99dd < 1 ether) {
            _0xf92a5b = 1 finney * (_0x9b99dd / 1 finney);
        } else if (_0x9b99dd < 10 ether) {
            _0xf92a5b = 10 finney * (_0x9b99dd / 10 finney);
        } else if (_0x9b99dd < 100 ether) {
            _0xf92a5b = 100 finney * (_0x9b99dd / 100 finney);
        } else if (_0x9b99dd < 1000 ether) {
            _0xf92a5b = 1 ether * (_0x9b99dd / 1 ether);
        } else if (_0x9b99dd < 10000 ether) {
            _0xf92a5b = 10 ether * (_0x9b99dd / 10 ether);
        } else {
            _0xf92a5b = _0x9b99dd;
        }

        // Hail the new monarch!
        ThroneClaimed(_0xa5577d._0x5c609a, _0xa5577d._0x7e42b3, _0xf92a5b);
    }

    // Used only by the wizard to collect his commission.
    function _0xce93e9(uint _0x70df61) _0x2ffdfd {
        _0xcac17e.send(_0x70df61);
    }

    // Used only by the wizard to collect his commission.
    function _0x624d28(address _0xcd9429) _0x2ffdfd {
        _0xcac17e = _0xcd9429;
    }

}
