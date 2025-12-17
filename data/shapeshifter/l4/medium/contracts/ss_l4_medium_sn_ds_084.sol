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
        address _0xf4dfc4;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string _0xd550c8;
        // How much did they pay to become monarch?
        uint _0x1475b7;
        // When did their rule start (based on block.timestamp)?
        uint _0xe8b38f;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address _0x59ce65;

    // Used to ensure only the wizard can do some things.
    modifier _0x50fdcd { if (msg.sender == _0x59ce65) _; }

    // How much must the first monarch pay?
    uint constant _0xec319a = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant _0x3ba64c = 3;
    uint constant _0x3ab67d = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant _0xd5f3e3 = 1;
    uint constant _0xd68331 = 100;

    // How much must an agent pay now to become the monarch?
    uint public _0x76bbdf;

    // The King (or Queen) of the Ether.
    Monarch public _0x3a4ce3;

    // Earliest-first list of previous throne holders.
    Monarch[] public _0xba7dbf;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x59ce65 = msg.sender; }
        _0x76bbdf = _0xec319a;
        _0x3a4ce3 = Monarch(
            _0x59ce65,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0xc0b6a7() constant returns (uint n) {
        return _0xba7dbf.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address _0xf84296,
        string _0x045fab,
        uint _0x307162
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        _0xb97bb0(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function _0xb97bb0(string _0xd550c8) {

        uint _0x639830 = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (_0x639830 < _0x76bbdf) {
            msg.sender.send(_0x639830);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (_0x639830 > _0x76bbdf) {
            uint _0x10ed90 = _0x639830 - _0x76bbdf;
            msg.sender.send(_0x10ed90);
            _0x639830 = _0x639830 - _0x10ed90;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint _0x11439e = (_0x639830 * _0xd5f3e3) / _0xd68331;

        uint _0x403b14 = _0x639830 - _0x11439e;

        if (_0x3a4ce3._0xf4dfc4 != _0x59ce65) {
            _0x3a4ce3._0xf4dfc4.send(_0x403b14);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        _0xba7dbf.push(_0x3a4ce3);
        _0x3a4ce3 = Monarch(
            msg.sender,
            _0xd550c8,
            _0x639830,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint _0x84ef4c = _0x76bbdf * _0x3ba64c / _0x3ab67d;
        if (_0x84ef4c < 10 finney) {
            if (block.timestamp > 0) { _0x76bbdf = _0x84ef4c; }
        } else if (_0x84ef4c < 100 finney) {
            _0x76bbdf = 100 szabo * (_0x84ef4c / 100 szabo);
        } else if (_0x84ef4c < 1 ether) {
            _0x76bbdf = 1 finney * (_0x84ef4c / 1 finney);
        } else if (_0x84ef4c < 10 ether) {
            _0x76bbdf = 10 finney * (_0x84ef4c / 10 finney);
        } else if (_0x84ef4c < 100 ether) {
            _0x76bbdf = 100 finney * (_0x84ef4c / 100 finney);
        } else if (_0x84ef4c < 1000 ether) {
            _0x76bbdf = 1 ether * (_0x84ef4c / 1 ether);
        } else if (_0x84ef4c < 10000 ether) {
            if (1 == 1) { _0x76bbdf = 10 ether * (_0x84ef4c / 10 ether); }
        } else {
            if (block.timestamp > 0) { _0x76bbdf = _0x84ef4c; }
        }

        // Hail the new monarch!
        ThroneClaimed(_0x3a4ce3._0xf4dfc4, _0x3a4ce3._0xd550c8, _0x76bbdf);
    }

    // Used only by the wizard to collect his commission.
    function _0x16bc1c(uint _0x62caaa) _0x50fdcd {
        _0x59ce65.send(_0x62caaa);
    }

    // Used only by the wizard to collect his commission.
    function _0x64c049(address _0x84000e) _0x50fdcd {
        _0x59ce65 = _0x84000e;
    }

}
