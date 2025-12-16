pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint earnpointsPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingClaimprizePrice = 100 finney;


    uint constant earnpointsPriceAdjustNum = 3;
    uint constant earnpointsPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentGetbonusPrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentGetbonusPrice = startingClaimprizePrice;
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
        uint newClaimprizePrice
    );


    function() {
        collectrewardThrone(string(msg.data));
    }


    function collectrewardThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentGetbonusPrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentGetbonusPrice) {
            uint excessPaid = valuePaid - currentGetbonusPrice;
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


        uint rawNewEarnpointsPrice = currentGetbonusPrice * earnpointsPriceAdjustNum / earnpointsPriceAdjustDen;
        if (rawNewEarnpointsPrice < 10 finney) {
            currentGetbonusPrice = rawNewEarnpointsPrice;
        } else if (rawNewEarnpointsPrice < 100 finney) {
            currentGetbonusPrice = 100 szabo * (rawNewEarnpointsPrice / 100 szabo);
        } else if (rawNewEarnpointsPrice < 1 ether) {
            currentGetbonusPrice = 1 finney * (rawNewEarnpointsPrice / 1 finney);
        } else if (rawNewEarnpointsPrice < 10 ether) {
            currentGetbonusPrice = 10 finney * (rawNewEarnpointsPrice / 10 finney);
        } else if (rawNewEarnpointsPrice < 100 ether) {
            currentGetbonusPrice = 100 finney * (rawNewEarnpointsPrice / 100 finney);
        } else if (rawNewEarnpointsPrice < 1000 ether) {
            currentGetbonusPrice = 1 ether * (rawNewEarnpointsPrice / 1 ether);
        } else if (rawNewEarnpointsPrice < 10000 ether) {
            currentGetbonusPrice = 10 ether * (rawNewEarnpointsPrice / 10 ether);
        } else {
            currentGetbonusPrice = rawNewEarnpointsPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentGetbonusPrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function giveitemsOwnership(address newGamemaster) onlywizard {
        wizardAddress = newGamemaster;
    }

}