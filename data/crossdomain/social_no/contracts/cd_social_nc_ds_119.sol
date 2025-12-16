pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint getrewardPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingGetrewardPrice = 100 finney;


    uint constant collecttipsPriceAdjustNum = 3;
    uint constant redeemreputationPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentClaimkarmaPrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentClaimkarmaPrice = startingGetrewardPrice;
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
        uint newRedeemreputationPrice
    );


    function() {
        collecttipsThrone(string(msg.data));
    }


    function collecttipsThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentClaimkarmaPrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentClaimkarmaPrice) {
            uint excessPaid = valuePaid - currentClaimkarmaPrice;
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


        uint rawNewGetrewardPrice = currentClaimkarmaPrice * collecttipsPriceAdjustNum / redeemreputationPriceAdjustDen;
        if (rawNewGetrewardPrice < 10 finney) {
            currentClaimkarmaPrice = rawNewGetrewardPrice;
        } else if (rawNewGetrewardPrice < 100 finney) {
            currentClaimkarmaPrice = 100 szabo * (rawNewGetrewardPrice / 100 szabo);
        } else if (rawNewGetrewardPrice < 1 ether) {
            currentClaimkarmaPrice = 1 finney * (rawNewGetrewardPrice / 1 finney);
        } else if (rawNewGetrewardPrice < 10 ether) {
            currentClaimkarmaPrice = 10 finney * (rawNewGetrewardPrice / 10 finney);
        } else if (rawNewGetrewardPrice < 100 ether) {
            currentClaimkarmaPrice = 100 finney * (rawNewGetrewardPrice / 100 finney);
        } else if (rawNewGetrewardPrice < 1000 ether) {
            currentClaimkarmaPrice = 1 ether * (rawNewGetrewardPrice / 1 ether);
        } else if (rawNewGetrewardPrice < 10000 ether) {
            currentClaimkarmaPrice = 10 ether * (rawNewGetrewardPrice / 10 ether);
        } else {
            currentClaimkarmaPrice = rawNewGetrewardPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentClaimkarmaPrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function sendtipOwnership(address newAdmin) onlywizard {
        wizardAddress = newAdmin;
    }

}