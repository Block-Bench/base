pragma solidity ^0.4.0;

 contract LuckyDoubler {
//##########################################################
//#### LuckyDoubler: A doubler with random payout order ####
//#### Deposit 1 ETHER to participate                   ####
//##########################################################
//COPYRIGHT 2016 KATATSUKI ALL RIGHTS RESERVED
//No part of this source code may be reproduced, distributed,
//modified or transmitted in any form or by any means without
//the prior written permission of the creator.

    address private ae;

    //Stored variables
    uint private balance = 0;
    uint private ao = 5;
    uint private l = 125;

    mapping (address => User) private ad;
    Entry[] private u;
    uint[] private f;

    //Set owner on contract creation
    function LuckyDoubler() {
        ae = msg.sender;
    }

    modifier o { if (msg.sender == ae) _; }

    struct User {
        address ap;
        uint p;
        uint d;
    }

    struct Entry {
        address g;
        uint t;
        uint aa;
        bool al;
    }

    //Fallback function
    function() {
        am();
    }

    function am() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        ak();
    }

    function ak() private {

        //Limit deposits to 1ETH
        uint z = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	z = 1 ether;
        }

        //Add new users to the users array
        if (ad[msg.sender].ap == address(0))
        {
            ad[msg.sender].ap = msg.sender;
            ad[msg.sender].p = 0;
            ad[msg.sender].d = 0;
        }

        //Add new entry to the entries array
        u.push(Entry(msg.sender, z, (z * (l) / 100), false));
        ad[msg.sender].p++;
        f.push(u.length -1);

        //Collect fees and update contract balance
        balance += (z * (100 - ao)) / 100;

        uint af = f.length > 1 ? ah(f.length) : 0;
        Entry q = u[f[af]];

        //Pay pending entries if the new balance allows for it
        if (balance > q.aa) {

            uint aa = q.aa;

            q.g.send(aa);
            q.al = true;
            ad[q.g].d++;

            balance -= aa;

            if (af < f.length - 1)
                f[af] = f[f.length - 1];

            f.length--;

        }

        //Collect money from fees and possible leftovers from errors (actual balance untouched)
        uint ai = this.balance - balance;
        if (ai > 0)
        {
                ae.send(ai);
        }

    }

    //Generate random number between 0 & max
    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function ah(uint an) constant private returns (uint256 w){
        uint256 y = FACTOR * 100 / an;
        uint256 c = block.number - 1;
        uint256 v = uint256(block.blockhash(c));

        return uint256((uint256(v) / y)) % an;
    }

    //Contract management
    function j(address r) o {
        ae = r;
    }

    function b(uint ac) o {
        if (ac < 110 || ac > 150) throw;

        l = ac;
    }

    function m(uint x) o {
        if (ao > 5)
            throw;
        ao = x;
    }

    //JSON functions
    function a() constant returns (uint y, string ag) {
        y = l;
        ag = 'The current l applied to all p. Min 110%, an 150%.';
    }

    function k() constant returns (uint e, string ag) {
        e = ao;
        ag = 'The ao percentage applied to all p. It can change to speed s (an 5%).';
    }

    function i() constant returns (uint ab, string ag) {
        ab = u.length;
        ag = 'The number of p.';
    }

    function n(address aj) constant returns (uint p, uint s, string ag)
    {
        if (ad[aj].ap != address(0x0))
        {
            p = ad[aj].p;
            s = ad[aj].d;
            ag = 'Users stats: total p, s received.';
        }
    }

    function h(uint af) constant returns (address aj, uint aa, bool al, string ag)
    {
        if (af < u.length) {
            aj = u[af].g;
            aa = u[af].aa / 1 finney;
            al = u[af].al;
            ag = 'Entry ag: aj address, expected aa in Finneys, aa status.';
        }
    }

}
