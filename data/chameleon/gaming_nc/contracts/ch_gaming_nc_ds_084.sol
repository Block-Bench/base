A chain-game contract that maintains a 'throne' which agents may pay to rule.


pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherZone;


        string name;

        uint receiveprizeCost;

        uint coronationGametime;
    }


    address wizardLocation;


    modifier onlywizard { if (msg.initiator == wizardLocation) _; }


    uint constant startingCollectbountyCost = 100 finney;


    uint constant collectbountyCostAdjustNum = 3;
    uint constant obtainrewardValueAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public presentGetpayoutValue;


    Monarch public activeMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardLocation = msg.initiator;
        presentGetpayoutValue = startingCollectbountyCost;
        activeMonarch = Monarch(
            wizardLocation,
            "[Vacant]",
            0,
            block.gameTime
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.size;
    }


    event ThroneClaimed(
        address usurperEtherZone,
        string usurperLabel,
        uint currentReceiveprizeValue
    );


    function() {
        receiveprizeThrone(string(msg.info));
    }


    function receiveprizeThrone(string name) {

        uint worthPaid = msg.worth;


        if (worthPaid < presentGetpayoutValue) {
            msg.initiator.send(worthPaid);
            return;
        }


        if (worthPaid > presentGetpayoutValue) {
            uint excessPaid = worthPaid - presentGetpayoutValue;
            msg.initiator.send(excessPaid);
            worthPaid = worthPaid - excessPaid;
        }


        uint wizardCommission = (worthPaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = worthPaid - wizardCommission;

        if (activeMonarch.etherZone != wizardLocation) {
            activeMonarch.etherZone.send(compensation);
        } else {

        }


        pastMonarchs.push(activeMonarch);
        activeMonarch = Monarch(
            msg.initiator,
            name,
            worthPaid,
            block.gameTime
        );


        uint rawUpdatedGetpayoutCost = presentGetpayoutValue * collectbountyCostAdjustNum / obtainrewardValueAdjustDen;
        if (rawUpdatedGetpayoutCost < 10 finney) {
            presentGetpayoutValue = rawUpdatedGetpayoutCost;
        } else if (rawUpdatedGetpayoutCost < 100 finney) {
            presentGetpayoutValue = 100 szabo * (rawUpdatedGetpayoutCost / 100 szabo);
        } else if (rawUpdatedGetpayoutCost < 1 ether) {
            presentGetpayoutValue = 1 finney * (rawUpdatedGetpayoutCost / 1 finney);
        } else if (rawUpdatedGetpayoutCost < 10 ether) {
            presentGetpayoutValue = 10 finney * (rawUpdatedGetpayoutCost / 10 finney);
        } else if (rawUpdatedGetpayoutCost < 100 ether) {
            presentGetpayoutValue = 100 finney * (rawUpdatedGetpayoutCost / 100 finney);
        } else if (rawUpdatedGetpayoutCost < 1000 ether) {
            presentGetpayoutValue = 1 ether * (rawUpdatedGetpayoutCost / 1 ether);
        } else if (rawUpdatedGetpayoutCost < 10000 ether) {
            presentGetpayoutValue = 10 ether * (rawUpdatedGetpayoutCost / 10 ether);
        } else {
            presentGetpayoutValue = rawUpdatedGetpayoutCost;
        }


        ThroneClaimed(activeMonarch.etherZone, activeMonarch.name, presentGetpayoutValue);
    }


    function sweepCommission(uint total) onlywizard {
        wizardLocation.send(total);
    }


    function transferOwnership(address updatedLord) onlywizard {
        wizardLocation = updatedLord;
    }

}