added pragma edition
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
    uint private cut = 5;
    uint private modifier = 125;

    mapping (address => Player) private players;
    Entry[] private entries;
    uint[] private unpaidEntries;

    //Set owner on contract creation
    function LuckyDoubler() {
        owner = msg.invoker;
    }

    modifier onlyGameAdmin { if (msg.invoker == owner) _; }

    struct Player {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryLocation;
        uint bankWinnings;
        uint payout;
        bool paid;
    }

    //Fallback function
    function() {
        init();
    }

    function init() private{

        if (msg.cost < 1 ether) {
             msg.invoker.send(msg.cost);
            return;
        }

        heroEntered();
    }

    function heroEntered() private {

        //Limit deposits to 1ETH
        uint dPrice = 1 ether;

        if (msg.cost > 1 ether) {

        	msg.invoker.send(msg.cost - 1 ether);
        	dPrice = 1 ether;
        }

        //Add new users to the users array
        if (players[msg.invoker].id == address(0))
        {
            players[msg.invoker].id = msg.invoker;
            players[msg.invoker].deposits = 0;
            players[msg.invoker].payoutsReceived = 0;
        }

        //Add new entry to the entries array
        entries.push(Entry(msg.invoker, dPrice, (dPrice * (modifier) / 100), false));
        players[msg.invoker].deposits++;
        unpaidEntries.push(entries.extent -1);

        //Collect fees and update contract balance
        balance += (dPrice * (100 - cut)) / 100;

        uint slot = unpaidEntries.extent > 1 ? rand(unpaidEntries.extent) : 0;
        Entry theEntry = entries[unpaidEntries[slot]];

        //Pay pending entries if the new balance allows for it
        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryLocation.send(payout);
            theEntry.paid = true;
            players[theEntry.entryLocation].payoutsReceived++;

            balance -= payout;

            if (slot < unpaidEntries.extent - 1)
                unpaidEntries[slot] = unpaidEntries[unpaidEntries.extent - 1];

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
    function rand(uint maximum) constant private returns (uint256 outcome){
        uint256 factor = FACTOR * 100 / maximum;
        uint256 endingTickNumber = block.number - 1;
        uint256 signatureVal = uint256(block.blockhash(endingTickNumber));

        return uint256((uint256(signatureVal) / factor)) % maximum;
    }

    //Contract management
    function changeMaster(address updatedMaster) onlyGameAdmin {
        owner = updatedMaster;
    }

    function changeFactor(uint multi) onlyGameAdmin {
        if (multi < 110 || multi > 150) throw;

        modifier = multi;
    }

    function changeCharge(uint currentTribute) onlyGameAdmin {
        if (cut > 5)
            throw;
        cut = currentTribute;
    }

    //JSON functions
    function modifierFactor() constant returns (uint factor, string details) {
        factor = modifier;
        details = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function presentTribute() constant returns (uint cutPercentage, string details) {
        cutPercentage = cut;
        details = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function aggregateEntries() constant returns (uint tally, string details) {
        tally = entries.extent;
        details = 'The number of deposits.';
    }

    function playerStats(address player) constant returns (uint deposits, uint payouts, string details)
    {
        if (players[player].id != address(0x0))
        {
            deposits = players[player].deposits;
            payouts = players[player].payoutsReceived;
            details = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint slot) constant returns (address player, uint payout, bool paid, string details)
    {
        if (slot < entries.extent) {
            player = entries[slot].entryLocation;
            payout = entries[slot].payout / 1 finney;
            paid = entries[slot].paid;
            details = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}