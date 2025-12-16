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

    address private owner;

    //Stored variables
    uint private balance = 0;
    uint private tribute = 5;
    uint private factor = 125;

    mapping (address => Character) private players;
    Entry[] private entries;
    uint[] private unpaidEntries;

    //Set owner on contract creation
    function LuckyDoubler() {
        owner = msg.sender;
    }

    modifier onlyGameAdmin { if (msg.sender == owner) _; }

    struct Character {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryRealm;
        uint bankWinnings;
        uint payout;
        bool paid;
    }

    //Fallback function
    function() {
        init();
    }

    function init() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        playerJoined();
    }

    function playerJoined() private {

        //Limit deposits to 1ETH
        uint dPrice = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	dPrice = 1 ether;
        }

        //Add new users to the users array
        if (players[msg.sender].id == address(0))
        {
            players[msg.sender].id = msg.sender;
            players[msg.sender].deposits = 0;
            players[msg.sender].payoutsReceived = 0;
        }

        //Add new entry to the entries array
        entries.push(Entry(msg.sender, dPrice, (dPrice * (factor) / 100), false));
        players[msg.sender].deposits++;
        unpaidEntries.push(entries.extent -1);

        //Collect fees and update contract balance
        balance += (dPrice * (100 - tribute)) / 100;

        uint position = unpaidEntries.extent > 1 ? rand(unpaidEntries.extent) : 0;
        Entry theEntry = entries[unpaidEntries[position]];

        //Pay pending entries if the new balance allows for it
        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryRealm.send(payout);
            theEntry.paid = true;
            players[theEntry.entryRealm].payoutsReceived++;

            balance -= payout;

            if (position < unpaidEntries.extent - 1)
                unpaidEntries[position] = unpaidEntries[unpaidEntries.extent - 1];

            unpaidEntries.extent--;

        }

        //Collect money from fees and possible leftovers from errors (actual balance untouched)
        uint fees = this.balance - balance;
        if (fees > 0)
        {
                owner.send(fees);
        }

    }

    //Generate random number between 0 & max
    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function rand(uint ceiling) constant private returns (uint256 outcome){
        uint256 factor = FACTOR * 100 / ceiling;
        uint256 finalTickNumber = block.number - 1;
        uint256 sealVal = uint256(block.blockhash(finalTickNumber));

        return uint256((uint256(sealVal) / factor)) % ceiling;
    }

    //Contract management
    function changeLord(address updatedMaster) onlyGameAdmin {
        owner = updatedMaster;
    }

    function changeModifier(uint multi) onlyGameAdmin {
        if (multi < 110 || multi > 150) throw;

        factor = multi;
    }

    function changeTribute(uint updatedCharge) onlyGameAdmin {
        if (tribute > 5)
            throw;
        tribute = updatedCharge;
    }

    //JSON functions
    function factorFactor() constant returns (uint factor, string details) {
        factor = factor;
        details = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function activeCut() constant returns (uint cutPercentage, string details) {
        cutPercentage = tribute;
        details = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function fullEntries() constant returns (uint tally, string details) {
        tally = entries.extent;
        details = 'The number of deposits.';
    }

    function playerStats(address adventurer) constant returns (uint deposits, uint payouts, string details)
    {
        if (players[adventurer].id != address(0x0))
        {
            deposits = players[adventurer].deposits;
            payouts = players[adventurer].payoutsReceived;
            details = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint position) constant returns (address adventurer, uint payout, bool paid, string details)
    {
        if (position < entries.extent) {
            adventurer = entries[position].entryRealm;
            payout = entries[position].payout / 1 finney;
            paid = entries[position].paid;
            details = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}
