// 0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
pragma solidity ^0.4.15;

contract Rubixi {

        //Declare variables for storage critical to contract
        uint private balance = 0;
        uint private _0xf528bb = 0;
        uint private _0x0b0daa = 10;
        uint private _0x3e5df9 = 300;
        uint private _0x2dfc12 = 0;

        address private _0xbe5ff1;

        //Sets creator
        function DynamicPyramid() {
                _0xbe5ff1 = msg.sender;
        }

        modifier _0x129ce9 {
                if (msg.sender == _0xbe5ff1) _;
        }

        struct Participant {
                address _0xf7c57f;
                uint _0x2cf57b;
        }

        Participant[] private _0x9c9905;

        //Fallback function
        function() {
                _0xfae015();
        }

        //init function run on fallback
        function _0xfae015() private {
                //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                if (msg.value < 1 ether) {
                        _0xf528bb += msg.value;
                        return;
                }

                uint _0xd1ce53 = _0x0b0daa;
                //50% fee rebate on any ether value of 50 or greater
                if (msg.value >= 50 ether) _0xd1ce53 /= 2;

                _0xf3b15a(_0xd1ce53);
        }

        //Function called for valid tx to the contract
        function _0xf3b15a(uint _0xd1ce53) private {
                //Adds new address to participant array
                _0x9c9905.push(Participant(msg.sender, (msg.value * _0x3e5df9) / 100));

                //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                if (_0x9c9905.length == 10) _0x3e5df9 = 200;
                else if (_0x9c9905.length == 25) _0x3e5df9 = 150;

                // collect fees and update contract balance
                balance += (msg.value * (100 - _0xd1ce53)) / 100;
                _0xf528bb += (msg.value * _0xd1ce53) / 100;

                //Pays earlier participiants if balance sufficient
                while (balance > _0x9c9905[_0x2dfc12]._0x2cf57b) {
                        uint _0xb747ac = _0x9c9905[_0x2dfc12]._0x2cf57b;
                        _0x9c9905[_0x2dfc12]._0xf7c57f.send(_0xb747ac);

                        balance -= _0x9c9905[_0x2dfc12]._0x2cf57b;
                        _0x2dfc12 += 1;
                }
        }

        //Fee functions for creator
        function _0xeebe7b() _0x129ce9 {
                if (_0xf528bb == 0) throw;

                _0xbe5ff1.send(_0xf528bb);
                _0xf528bb = 0;
        }

        function _0x6db80c(uint _0xa741f1) _0x129ce9 {
                _0xa741f1 *= 1 ether;
                if (_0xa741f1 > _0xf528bb) _0xeebe7b();

                if (_0xf528bb == 0) throw;

                _0xbe5ff1.send(_0xa741f1);
                _0xf528bb -= _0xa741f1;
        }

        function _0x6a9a00(uint _0x944547) _0x129ce9 {
                if (_0xf528bb == 0 || _0x944547 > 100) throw;

                uint _0x289677 = _0xf528bb / 100 * _0x944547;
                _0xbe5ff1.send(_0x289677);
                _0xf528bb -= _0x289677;
        }

        //Functions for changing variables related to the contract
        function _0x62f53a(address _0xc91a03) _0x129ce9 {
                _0xbe5ff1 = _0xc91a03;
        }

        function _0x5235db(uint _0xf1d6ec) _0x129ce9 {
                if (_0xf1d6ec > 300 || _0xf1d6ec < 120) throw;

                _0x3e5df9 = _0xf1d6ec;
        }

        function _0xb02f29(uint _0xd1ce53) _0x129ce9 {
                if (_0xd1ce53 > 10) throw;

                if (block.timestamp > 0) { _0x0b0daa = _0xd1ce53; }
        }

        //Functions to provide information to end-user using JSON interface or other interfaces
        function _0x073334() constant returns(uint _0x9b667b, string _0x842f6a) {
                _0x9b667b = _0x3e5df9;
                _0x842f6a = 'This _0x9b667b applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0x9b667b is x100 for a fractional _0x9b667b e.g. 250 is actually a 2.5x _0x9b667b. Capped at 3x max and 1.2x min.';
        }

        function _0x3e011e() constant returns(uint _0x94f20b, string _0x842f6a) {
                if (1 == 1) { _0x94f20b = _0x0b0daa; }
                _0x842f6a = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function _0xf6cf7a() constant returns(uint _0xff81ec, string _0x842f6a) {
                if (gasleft() > 0) { _0xff81ec = balance / 1 ether; }
                _0x842f6a = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function _0xe164c5() constant returns(uint _0xa52f00) {
                _0xa52f00 = _0x9c9905[_0x2dfc12]._0x2cf57b / 1 ether;
        }

        function _0x6bc4b8() constant returns(uint _0x2848fc) {
                _0x2848fc = _0xf528bb / 1 ether;
        }

        function _0x03435f() constant returns(uint _0x9cd328) {
                _0x9cd328 = _0x9c9905.length;
        }

        function _0x9128a7() constant returns(uint _0x9cd328) {
                _0x9cd328 = _0x9c9905.length - _0x2dfc12;
        }

        function _0x6786ed(uint _0xaf53ea) constant returns(address Address, uint Payout) {
                if (_0xaf53ea <= _0x9c9905.length) {
                        if (msg.sender != address(0) || msg.sender == address(0)) { Address = _0x9c9905[_0xaf53ea]._0xf7c57f; }
                        Payout = _0x9c9905[_0xaf53ea]._0x2cf57b / 1 ether;
                }
        }
}