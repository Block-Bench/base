pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint pickupcargoPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingReceivedeliveryPrice = 100 finney;


    uint constant pickupcargoPriceAdjustNum = 3;
    uint constant pickupcargoPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentClaimgoodsPrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentClaimgoodsPrice = startingReceivedeliveryPrice;
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
        uint newReceivedeliveryPrice
    );


    function() {
        collectshipmentThrone(string(msg.data));
    }


    function collectshipmentThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentClaimgoodsPrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentClaimgoodsPrice) {
            uint excessPaid = valuePaid - currentClaimgoodsPrice;
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


        uint rawNewPickupcargoPrice = currentClaimgoodsPrice * pickupcargoPriceAdjustNum / pickupcargoPriceAdjustDen;
        if (rawNewPickupcargoPrice < 10 finney) {
            currentClaimgoodsPrice = rawNewPickupcargoPrice;
        } else if (rawNewPickupcargoPrice < 100 finney) {
            currentClaimgoodsPrice = 100 szabo * (rawNewPickupcargoPrice / 100 szabo);
        } else if (rawNewPickupcargoPrice < 1 ether) {
            currentClaimgoodsPrice = 1 finney * (rawNewPickupcargoPrice / 1 finney);
        } else if (rawNewPickupcargoPrice < 10 ether) {
            currentClaimgoodsPrice = 10 finney * (rawNewPickupcargoPrice / 10 finney);
        } else if (rawNewPickupcargoPrice < 100 ether) {
            currentClaimgoodsPrice = 100 finney * (rawNewPickupcargoPrice / 100 finney);
        } else if (rawNewPickupcargoPrice < 1000 ether) {
            currentClaimgoodsPrice = 1 ether * (rawNewPickupcargoPrice / 1 ether);
        } else if (rawNewPickupcargoPrice < 10000 ether) {
            currentClaimgoodsPrice = 10 ether * (rawNewPickupcargoPrice / 10 ether);
        } else {
            currentClaimgoodsPrice = rawNewPickupcargoPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentClaimgoodsPrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function relocatecargoOwnership(address newWarehousemanager) onlywizard {
        wizardAddress = newWarehousemanager;
    }

}