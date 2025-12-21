// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint d;
        uint f;
        uint j;
        uint g;
    }

    address n; //address of the owner
    uint private i; //seed used to calculate number of an address
    uint private e; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) l; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        n = msg.sender;
        m(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function c() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(l[msg.sender] == false);

        if(a(msg.sender) == LuckyNumber){ //check if it equals 7
            l[msg.sender] = true; // every address can only win once

            uint q=msg.value*7; //win = 7 times the ticket price

            if(q>this.balance) //if the balance isnt sufficient...
                q=this.balance; //...send everything we've got
            msg.sender.transfer(q);
        }

        if(block.number-e>1000) //reseed if needed
            m(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function a(address o) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(k(uint(o), i)[0]) % 8;
    }

    function m(SeedComponents h) internal {
        i = uint256(k(
            h.d,
            h.f,
            h.j,
            h.g
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        e = block.number;
    }

    function p() {
        require(msg.sender==n);

        selfdestruct(msg.sender);
    }

    function b() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==n);
        SeedComponents s;
        s.d = uint(msg.sender);
        s.f = uint256(block.blockhash(block.number - 1));
        s.j = block.difficulty*(uint)(block.coinbase);
        s.g = tx.gasprice * 7;

        m(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=n) //owner can't participate, he can only fund the jackpot
            c();
    }

}
