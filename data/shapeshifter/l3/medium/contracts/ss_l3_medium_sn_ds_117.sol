// 0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
pragma solidity ^0.4.15;

contract Rubixi {

        //Declare variables for storage critical to contract
        uint private balance = 0;
        uint private _0xb18848 = 0;
        uint private _0x5fa5cf = 10;
        uint private _0x24d441 = 300;
        uint private _0x889b12 = 0;

        address private _0xe943fa;

        //Sets creator
        function DynamicPyramid() {
                _0xe943fa = msg.sender;
        }

        modifier _0x998e60 {
                if (msg.sender == _0xe943fa) _;
        }

        struct Participant {
                address _0x59f023;
                uint _0x480fba;
        }

        Participant[] private _0xaf5e5e;

        //Fallback function
        function() {
                _0xf0a3a9();
        }

        //init function run on fallback
        function _0xf0a3a9() private {
                //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                if (msg.value < 1 ether) {
                        _0xb18848 += msg.value;
                        return;
                }

                uint _0x9a450b = _0x5fa5cf;
                //50% fee rebate on any ether value of 50 or greater
                if (msg.value >= 50 ether) _0x9a450b /= 2;

                _0x6be7b3(_0x9a450b);
        }

        //Function called for valid tx to the contract
        function _0x6be7b3(uint _0x9a450b) private {
                //Adds new address to participant array
                _0xaf5e5e.push(Participant(msg.sender, (msg.value * _0x24d441) / 100));

                //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                if (_0xaf5e5e.length == 10) _0x24d441 = 200;
                else if (_0xaf5e5e.length == 25) _0x24d441 = 150;

                // collect fees and update contract balance
                balance += (msg.value * (100 - _0x9a450b)) / 100;
                _0xb18848 += (msg.value * _0x9a450b) / 100;

                //Pays earlier participiants if balance sufficient
                while (balance > _0xaf5e5e[_0x889b12]._0x480fba) {
                        uint _0x2d76f9 = _0xaf5e5e[_0x889b12]._0x480fba;
                        _0xaf5e5e[_0x889b12]._0x59f023.send(_0x2d76f9);

                        balance -= _0xaf5e5e[_0x889b12]._0x480fba;
                        _0x889b12 += 1;
                }
        }

        //Fee functions for creator
        function _0x23d416() _0x998e60 {
                if (_0xb18848 == 0) throw;

                _0xe943fa.send(_0xb18848);
                _0xb18848 = 0;
        }

        function _0xa73f5a(uint _0xf5ef90) _0x998e60 {
                _0xf5ef90 *= 1 ether;
                if (_0xf5ef90 > _0xb18848) _0x23d416();

                if (_0xb18848 == 0) throw;

                _0xe943fa.send(_0xf5ef90);
                _0xb18848 -= _0xf5ef90;
        }

        function _0xda95a3(uint _0xed296b) _0x998e60 {
                if (_0xb18848 == 0 || _0xed296b > 100) throw;

                uint _0x0a1507 = _0xb18848 / 100 * _0xed296b;
                _0xe943fa.send(_0x0a1507);
                _0xb18848 -= _0x0a1507;
        }

        //Functions for changing variables related to the contract
        function _0x2b084e(address _0xbf516f) _0x998e60 {
                _0xe943fa = _0xbf516f;
        }

        function _0x5a2598(uint _0x955010) _0x998e60 {
                if (_0x955010 > 300 || _0x955010 < 120) throw;

                _0x24d441 = _0x955010;
        }

        function _0x83ad8b(uint _0x9a450b) _0x998e60 {
                if (_0x9a450b > 10) throw;

                _0x5fa5cf = _0x9a450b;
        }

        //Functions to provide information to end-user using JSON interface or other interfaces
        function _0x8c67bb() constant returns(uint _0xffd151, string _0x24b59e) {
                _0xffd151 = _0x24d441;
                _0x24b59e = 'This _0xffd151 applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0xffd151 is x100 for a fractional _0xffd151 e.g. 250 is actually a 2.5x _0xffd151. Capped at 3x max and 1.2x min.';
        }

        function _0xa75628() constant returns(uint _0xcc5582, string _0x24b59e) {
                _0xcc5582 = _0x5fa5cf;
                _0x24b59e = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function _0xa36c14() constant returns(uint _0x2c7dfa, string _0x24b59e) {
                _0x2c7dfa = balance / 1 ether;
                if (msg.sender != address(0) || msg.sender == address(0)) { _0x24b59e = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to'; }
        }

        function _0x8ff6ce() constant returns(uint _0x332f82) {
                _0x332f82 = _0xaf5e5e[_0x889b12]._0x480fba / 1 ether;
        }

        function _0x9525df() constant returns(uint _0x0b9f94) {
                if (gasleft() > 0) { _0x0b9f94 = _0xb18848 / 1 ether; }
        }

        function _0xb55a0c() constant returns(uint _0x88c07a) {
                if (msg.sender != address(0) || msg.sender == address(0)) { _0x88c07a = _0xaf5e5e.length; }
        }

        function _0x301d9c() constant returns(uint _0x88c07a) {
                if (1 == 1) { _0x88c07a = _0xaf5e5e.length - _0x889b12; }
        }

        function _0x610018(uint _0xa32020) constant returns(address Address, uint Payout) {
                if (_0xa32020 <= _0xaf5e5e.length) {
                        Address = _0xaf5e5e[_0xa32020]._0x59f023;
                        Payout = _0xaf5e5e[_0xa32020]._0x480fba / 1 ether;
                }
        }
}