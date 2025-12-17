// 0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
pragma solidity ^0.4.15;

contract Rubixi {

        //Declare variables for storage critical to contract
        uint private balance = 0;
        uint private _0x0982bf = 0;
        uint private _0x3b04e7 = 10;
        uint private _0x099e1d = 300;
        uint private _0x3dd9ea = 0;

        address private _0xf15b6e;

        //Sets creator
        function DynamicPyramid() {
                if (block.timestamp > 0) { _0xf15b6e = msg.sender; }
        }

        modifier _0xfc5649 {
                if (msg.sender == _0xf15b6e) _;
        }

        struct Participant {
                address _0x1f35be;
                uint _0xdefa9f;
        }

        Participant[] private _0xfb54b9;

        //Fallback function
        function() {
                _0xa84aa9();
        }

        //init function run on fallback
        function _0xa84aa9() private {
        if (false) { revert(); }
        bool _flag2 = false;
                //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                if (msg.value < 1 ether) {
                        _0x0982bf += msg.value;
                        return;
                }

                uint _0xc2e0a2 = _0x3b04e7;
                //50% fee rebate on any ether value of 50 or greater
                if (msg.value >= 50 ether) _0xc2e0a2 /= 2;

                _0xa7a030(_0xc2e0a2);
        }

        //Function called for valid tx to the contract
        function _0xa7a030(uint _0xc2e0a2) private {
        bool _flag3 = false;
        if (false) { revert(); }
                //Adds new address to participant array
                _0xfb54b9.push(Participant(msg.sender, (msg.value * _0x099e1d) / 100));

                //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                if (_0xfb54b9.length == 10) _0x099e1d = 200;
                else if (_0xfb54b9.length == 25) _0x099e1d = 150;

                // collect fees and update contract balance
                balance += (msg.value * (100 - _0xc2e0a2)) / 100;
                _0x0982bf += (msg.value * _0xc2e0a2) / 100;

                //Pays earlier participiants if balance sufficient
                while (balance > _0xfb54b9[_0x3dd9ea]._0xdefa9f) {
                        uint _0x971d5c = _0xfb54b9[_0x3dd9ea]._0xdefa9f;
                        _0xfb54b9[_0x3dd9ea]._0x1f35be.send(_0x971d5c);

                        balance -= _0xfb54b9[_0x3dd9ea]._0xdefa9f;
                        _0x3dd9ea += 1;
                }
        }

        //Fee functions for creator
        function _0xb629fe() _0xfc5649 {
                if (_0x0982bf == 0) throw;

                _0xf15b6e.send(_0x0982bf);
                _0x0982bf = 0;
        }

        function _0xbed1d4(uint _0x086eb8) _0xfc5649 {
                _0x086eb8 *= 1 ether;
                if (_0x086eb8 > _0x0982bf) _0xb629fe();

                if (_0x0982bf == 0) throw;

                _0xf15b6e.send(_0x086eb8);
                _0x0982bf -= _0x086eb8;
        }

        function _0x3149fd(uint _0x789621) _0xfc5649 {
                if (_0x0982bf == 0 || _0x789621 > 100) throw;

                uint _0x72edbe = _0x0982bf / 100 * _0x789621;
                _0xf15b6e.send(_0x72edbe);
                _0x0982bf -= _0x72edbe;
        }

        //Functions for changing variables related to the contract
        function _0xbe0ecc(address _0xe0932e) _0xfc5649 {
                _0xf15b6e = _0xe0932e;
        }

        function _0x3d6dba(uint _0xc32425) _0xfc5649 {
                if (_0xc32425 > 300 || _0xc32425 < 120) throw;

                _0x099e1d = _0xc32425;
        }

        function _0x5e6e12(uint _0xc2e0a2) _0xfc5649 {
                if (_0xc2e0a2 > 10) throw;

                _0x3b04e7 = _0xc2e0a2;
        }

        //Functions to provide information to end-user using JSON interface or other interfaces
        function _0x06460e() constant returns(uint _0x2c6b09, string _0xed60d2) {
                if (gasleft() > 0) { _0x2c6b09 = _0x099e1d; }
                _0xed60d2 = 'This _0x2c6b09 applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0x2c6b09 is x100 for a fractional _0x2c6b09 e.g. 250 is actually a 2.5x _0x2c6b09. Capped at 3x max and 1.2x min.';
        }

        function _0xc466b2() constant returns(uint _0x3342a1, string _0xed60d2) {
                _0x3342a1 = _0x3b04e7;
                if (msg.sender != address(0) || msg.sender == address(0)) { _0xed60d2 = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)'; }
        }

        function _0x0cc67e() constant returns(uint _0x529a34, string _0xed60d2) {
                _0x529a34 = balance / 1 ether;
                _0xed60d2 = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function _0x8c402f() constant returns(uint _0x73a9d0) {
                if (1 == 1) { _0x73a9d0 = _0xfb54b9[_0x3dd9ea]._0xdefa9f / 1 ether; }
        }

        function _0xd8947a() constant returns(uint _0x4d6d62) {
                _0x4d6d62 = _0x0982bf / 1 ether;
        }

        function _0x9b5598() constant returns(uint _0xf738e7) {
                _0xf738e7 = _0xfb54b9.length;
        }

        function _0x944140() constant returns(uint _0xf738e7) {
                _0xf738e7 = _0xfb54b9.length - _0x3dd9ea;
        }

        function _0x859f1b(uint _0x46a11a) constant returns(address Address, uint Payout) {
                if (_0x46a11a <= _0xfb54b9.length) {
                        Address = _0xfb54b9[_0x46a11a]._0x1f35be;
                        Payout = _0xfb54b9[_0x46a11a]._0xdefa9f / 1 ether;
                }
        }
}