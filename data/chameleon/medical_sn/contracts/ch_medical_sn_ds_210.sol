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
    uint private charge = 5;
    uint private modifier = 125;

    mapping (address => Member) private beneficiaries;
    Entry[] private entries;
    uint[] private unpaidEntries;

    //Set owner on contract creation
    function LuckyDoubler() {
        owner = msg.sender;
    }

    modifier onlyChiefMedical { if (msg.sender == owner) _; }

    struct Member {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryLocation;
        uint provideSpecimen;
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

        memberEnrolled();
    }

    function memberEnrolled() private {

        //Limit deposits to 1ETH
        uint dAssessment = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	dAssessment = 1 ether;
        }

        //Add new users to the users array
        if (beneficiaries[msg.sender].id == address(0))
        {
            beneficiaries[msg.sender].id = msg.sender;
            beneficiaries[msg.sender].deposits = 0;
            beneficiaries[msg.sender].payoutsReceived = 0;
        }

        //Add new entry to the entries array
        entries.push(Entry(msg.sender, dAssessment, (dAssessment * (modifier) / 100), false));
        beneficiaries[msg.sender].deposits++;
        unpaidEntries.push(entries.extent -1);

        //Collect fees and update contract balance
        balance += (dAssessment * (100 - charge)) / 100;

        uint rank = unpaidEntries.extent > 1 ? rand(unpaidEntries.extent) : 0;
        Entry theEntry = entries[unpaidEntries[rank]];

        //Pay pending entries if the new balance allows for it
        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryLocation.send(payout);
            theEntry.paid = true;
            beneficiaries[theEntry.entryLocation].payoutsReceived++;

            balance -= payout;

            if (rank < unpaidEntries.extent - 1)
                unpaidEntries[rank] = unpaidEntries[unpaidEntries.extent - 1];

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
    function rand(uint maximum) constant private returns (uint256 finding){
        uint256 factor = FACTOR * 100 / maximum;
        uint256 endingUnitNumber = block.number - 1;
        uint256 checksumVal = uint256(block.blockhash(endingUnitNumber));

        return uint256((uint256(checksumVal) / factor)) % maximum;
    }

    //Contract management
    function changeDirector(address updatedAdministrator) onlyChiefMedical {
        owner = updatedAdministrator;
    }

    function changeFactor(uint multi) onlyChiefMedical {
        if (multi < 110 || multi > 150) throw;

        modifier = multi;
    }

    function changeCharge(uint updatedPremium) onlyChiefMedical {
        if (charge > 5)
            throw;
        charge = updatedPremium;
    }

    //JSON functions
    function factorFactor() constant returns (uint factor, string details) {
        factor = modifier;
        details = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function presentCopay() constant returns (uint copayPercentage, string details) {
        copayPercentage = charge;
        details = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function aggregateEntries() constant returns (uint tally, string details) {
        tally = entries.extent;
        details = 'The number of deposits.';
    }

    function patientStats(address beneficiary) constant returns (uint deposits, uint payouts, string details)
    {
        if (beneficiaries[beneficiary].id != address(0x0))
        {
            deposits = beneficiaries[beneficiary].deposits;
            payouts = beneficiaries[beneficiary].payoutsReceived;
            details = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint rank) constant returns (address beneficiary, uint payout, bool paid, string details)
    {
        if (rank < entries.extent) {
            beneficiary = entries[rank].entryLocation;
            payout = entries[rank].payout / 1 finney;
            paid = entries[rank].paid;
            details = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}
