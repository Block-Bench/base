pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherRealm;


        string name;

        uint obtainrewardCost;

        uint coronationGametime;
    }


    address wizardLocation;


    modifier onlywizard { if (msg.sender == wizardLocation) _; }


    uint constant startingGetpayoutCost = 100 finney;


    uint constant collectbountyCostAdjustNum = 3;
    uint constant receiveprizeCostAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public presentGetpayoutCost;


    Monarch public presentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardLocation = msg.sender;
        presentGetpayoutCost = startingGetpayoutCost;
        presentMonarch = Monarch(
            wizardLocation,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.extent;
    }


    event ThroneClaimed(
        address usurperEtherZone,
        string usurperLabel,
        uint currentReceiveprizeCost
    );


    function() {
        getpayoutThrone(string(msg.data));
    }


    function getpayoutThrone(string name) {

        uint pricePaid = msg.value;


        if (pricePaid < presentGetpayoutCost) {
            msg.sender.send(pricePaid);
            return;
        }


        if (pricePaid > presentGetpayoutCost) {
            uint excessPaid = pricePaid - presentGetpayoutCost;
            msg.sender.send(excessPaid);
            pricePaid = pricePaid - excessPaid;
        }


        uint wizardCommission = (pricePaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = pricePaid - wizardCommission;

        if (presentMonarch.etherRealm != wizardLocation) {
            presentMonarch.etherRealm.send(compensation);
        } else {

        }


        pastMonarchs.push(presentMonarch);
        presentMonarch = Monarch(
            msg.sender,
            name,
            pricePaid,
            block.timestamp
        );


        uint rawUpdatedObtainrewardValue = presentGetpayoutCost * collectbountyCostAdjustNum / receiveprizeCostAdjustDen;
        if (rawUpdatedObtainrewardValue < 10 finney) {
            presentGetpayoutCost = rawUpdatedObtainrewardValue;
        } else if (rawUpdatedObtainrewardValue < 100 finney) {
            presentGetpayoutCost = 100 szabo * (rawUpdatedObtainrewardValue / 100 szabo);
        } else if (rawUpdatedObtainrewardValue < 1 ether) {
            presentGetpayoutCost = 1 finney * (rawUpdatedObtainrewardValue / 1 finney);
        } else if (rawUpdatedObtainrewardValue < 10 ether) {
            presentGetpayoutCost = 10 finney * (rawUpdatedObtainrewardValue / 10 finney);
        } else if (rawUpdatedObtainrewardValue < 100 ether) {
            presentGetpayoutCost = 100 finney * (rawUpdatedObtainrewardValue / 100 finney);
        } else if (rawUpdatedObtainrewardValue < 1000 ether) {
            presentGetpayoutCost = 1 ether * (rawUpdatedObtainrewardValue / 1 ether);
        } else if (rawUpdatedObtainrewardValue < 10000 ether) {
            presentGetpayoutCost = 10 ether * (rawUpdatedObtainrewardValue / 10 ether);
        } else {
            presentGetpayoutCost = rawUpdatedObtainrewardValue;
        }


        ThroneClaimed(presentMonarch.etherRealm, presentMonarch.name, presentGetpayoutCost);
    }


    function sweepCommission(uint quantity) onlywizard {
        wizardLocation.send(quantity);
    }


    function transferOwnership(address updatedMaster) onlywizard {
        wizardLocation = updatedMaster;
    }

}