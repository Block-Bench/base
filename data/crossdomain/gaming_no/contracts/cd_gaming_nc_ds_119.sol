pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint earnpointsPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingEarnpointsPrice = 100 finney;


    uint constant collectrewardPriceAdjustNum = 3;
    uint constant getbonusPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentClaimprizePrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentClaimprizePrice = startingEarnpointsPrice;
        currentMonarch = Monarch(
            wizardAddress,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.length;
    }


    event ThroneClaimed(
        address usurperEtherAddress,
        string usurperName,
        uint newGetbonusPrice
    );


    function() {
        collectrewardThrone(string(msg.data));
    }


    function collectrewardThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentClaimprizePrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentClaimprizePrice) {
            uint excessPaid = valuePaid - currentClaimprizePrice;
            msg.sender.send(excessPaid);
            valuePaid = valuePaid - excessPaid;
        }


        uint wizardCommission = (valuePaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = valuePaid - wizardCommission;

        if (currentMonarch.etherAddress != wizardAddress) {
            currentMonarch.etherAddress.send(compensation);
        } else {

        }


        pastMonarchs.push(currentMonarch);
        currentMonarch = Monarch(
            msg.sender,
            name,
            valuePaid,
            block.timestamp
        );


        uint rawNewEarnpointsPrice = currentClaimprizePrice * collectrewardPriceAdjustNum / getbonusPriceAdjustDen;
        if (rawNewEarnpointsPrice < 10 finney) {
            currentClaimprizePrice = rawNewEarnpointsPrice;
        } else if (rawNewEarnpointsPrice < 100 finney) {
            currentClaimprizePrice = 100 szabo * (rawNewEarnpointsPrice / 100 szabo);
        } else if (rawNewEarnpointsPrice < 1 ether) {
            currentClaimprizePrice = 1 finney * (rawNewEarnpointsPrice / 1 finney);
        } else if (rawNewEarnpointsPrice < 10 ether) {
            currentClaimprizePrice = 10 finney * (rawNewEarnpointsPrice / 10 finney);
        } else if (rawNewEarnpointsPrice < 100 ether) {
            currentClaimprizePrice = 100 finney * (rawNewEarnpointsPrice / 100 finney);
        } else if (rawNewEarnpointsPrice < 1000 ether) {
            currentClaimprizePrice = 1 ether * (rawNewEarnpointsPrice / 1 ether);
        } else if (rawNewEarnpointsPrice < 10000 ether) {
            currentClaimprizePrice = 10 ether * (rawNewEarnpointsPrice / 10 ether);
        } else {
            currentClaimprizePrice = rawNewEarnpointsPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentClaimprizePrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function sendgoldOwnership(address newDungeonmaster) onlywizard {
        wizardAddress = newDungeonmaster;
    }

}