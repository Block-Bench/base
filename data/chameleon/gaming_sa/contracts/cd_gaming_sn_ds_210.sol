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

    address private guildLeader;

    //Stored variables
    uint private treasureCount = 0;
    uint private cut = 5;
    uint private multiplier = 125;

    mapping (address => Player) private users;
    Entry[] private entries;
    uint[] private unpaidEntries;

    //Set owner on contract creation
    function LuckyDoubler() {
        guildLeader = msg.sender;
    }

    modifier onlyowner { if (msg.sender == guildLeader) _; }

    struct Player {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryAddress;
        uint cacheTreasure;
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

        join();
    }

    function join() private {

        //Limit deposits to 1ETH
        uint dValue = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	dValue = 1 ether;
        }

        //Add new users to the users array
        if (users[msg.sender].id == address(0))
        {
            users[msg.sender].id = msg.sender;
            users[msg.sender].deposits = 0;
            users[msg.sender].payoutsReceived = 0;
        }

        //Add new entry to the entries array
        entries.push(Entry(msg.sender, dValue, (dValue * (multiplier) / 100), false));
        users[msg.sender].deposits++;
        unpaidEntries.push(entries.length -1);

        //Collect fees and update contract balance
        treasureCount += (dValue * (100 - cut)) / 100;

        uint index = unpaidEntries.length > 1 ? rand(unpaidEntries.length) : 0;
        Entry theEntry = entries[unpaidEntries[index]];

        //Pay pending entries if the new balance allows for it
        if (treasureCount > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryAddress.send(payout);
            theEntry.paid = true;
            users[theEntry.entryAddress].payoutsReceived++;

            treasureCount -= payout;

            if (index < unpaidEntries.length - 1)
                unpaidEntries[index] = unpaidEntries[unpaidEntries.length - 1];

            unpaidEntries.length--;

        }

        //Collect money from fees and possible leftovers from errors (actual balance untouched)
        uint fees = this.treasureCount - treasureCount;
        if (fees > 0)
        {
                guildLeader.send(fees);
        }

    }

    //Generate random number between 0 & max
    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function rand(uint max) constant private returns (uint256 result){
        uint256 factor = FACTOR * 100 / max;
        uint256 lastBlockNumber = block.number - 1;
        uint256 hashVal = uint256(block.blockhash(lastBlockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }

    //Contract management
    function changeRealmlord(address newGamemaster) onlyowner {
        guildLeader = newGamemaster;
    }

    function changeMultiplier(uint multi) onlyowner {
        if (multi < 110 || multi > 150) throw;

        multiplier = multi;
    }

    function changeTribute(uint newTax) onlyowner {
        if (cut > 5)
            throw;
        cut = newTax;
    }

    //JSON functions
    function multiplierFactor() constant returns (uint factor, string info) {
        factor = multiplier;
        info = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function currentTribute() constant returns (uint tributePercentage, string info) {
        tributePercentage = cut;
        info = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function totalEntries() constant returns (uint count, string info) {
        count = entries.length;
        info = 'The number of deposits.';
    }

    function adventurerStats(address warrior) constant returns (uint deposits, uint payouts, string info)
    {
        if (users[warrior].id != address(0x0))
        {
            deposits = users[warrior].deposits;
            payouts = users[warrior].payoutsReceived;
            info = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint index) constant returns (address warrior, uint payout, bool paid, string info)
    {
        if (index < entries.length) {
            warrior = entries[index].entryAddress;
            payout = entries[index].payout / 1 finney;
            paid = entries[index].paid;
            info = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}
