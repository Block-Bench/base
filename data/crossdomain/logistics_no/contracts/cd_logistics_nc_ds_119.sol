pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint pickupcargoPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingPickupcargoPrice = 100 finney;


    uint constant collectshipmentPriceAdjustNum = 3;
    uint constant claimgoodsPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentReceivedeliveryPrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentReceivedeliveryPrice = startingPickupcargoPrice;
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
        uint newClaimgoodsPrice
    );


    function() {
        collectshipmentThrone(string(msg.data));
    }


    function collectshipmentThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentReceivedeliveryPrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentReceivedeliveryPrice) {
            uint excessPaid = valuePaid - currentReceivedeliveryPrice;
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


        uint rawNewPickupcargoPrice = currentReceivedeliveryPrice * collectshipmentPriceAdjustNum / claimgoodsPriceAdjustDen;
        if (rawNewPickupcargoPrice < 10 finney) {
            currentReceivedeliveryPrice = rawNewPickupcargoPrice;
        } else if (rawNewPickupcargoPrice < 100 finney) {
            currentReceivedeliveryPrice = 100 szabo * (rawNewPickupcargoPrice / 100 szabo);
        } else if (rawNewPickupcargoPrice < 1 ether) {
            currentReceivedeliveryPrice = 1 finney * (rawNewPickupcargoPrice / 1 finney);
        } else if (rawNewPickupcargoPrice < 10 ether) {
            currentReceivedeliveryPrice = 10 finney * (rawNewPickupcargoPrice / 10 finney);
        } else if (rawNewPickupcargoPrice < 100 ether) {
            currentReceivedeliveryPrice = 100 finney * (rawNewPickupcargoPrice / 100 finney);
        } else if (rawNewPickupcargoPrice < 1000 ether) {
            currentReceivedeliveryPrice = 1 ether * (rawNewPickupcargoPrice / 1 ether);
        } else if (rawNewPickupcargoPrice < 10000 ether) {
            currentReceivedeliveryPrice = 10 ether * (rawNewPickupcargoPrice / 10 ether);
        } else {
            currentReceivedeliveryPrice = rawNewPickupcargoPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentReceivedeliveryPrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function movegoodsOwnership(address newFacilityoperator) onlywizard {
        wizardAddress = newFacilityoperator;
    }

}