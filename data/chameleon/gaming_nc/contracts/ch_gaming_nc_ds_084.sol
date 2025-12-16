pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherLocation;


        string name;

        uint receiveprizeCost;

        uint coronationQuesttime;
    }


    address wizardRealm;


    modifier onlywizard { if (msg.sender == wizardRealm) _; }


    uint constant startingObtainrewardCost = 100 finney;


    uint constant collectbountyValueAdjustNum = 3;
    uint constant receiveprizeCostAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public presentCollectbountyValue;


    Monarch public presentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardRealm = msg.sender;
        presentCollectbountyValue = startingObtainrewardCost;
        presentMonarch = Monarch(
            wizardRealm,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.extent;
    }


    event ThroneClaimed(
        address usurperEtherRealm,
        string usurperTitle,
        uint updatedObtainrewardValue
    );


    function() {
        obtainrewardThrone(string(msg.data));
    }


    function obtainrewardThrone(string name) {

        uint magnitudePaid = msg.value;


        if (magnitudePaid < presentCollectbountyValue) {
            msg.sender.send(magnitudePaid);
            return;
        }


        if (magnitudePaid > presentCollectbountyValue) {
            uint excessPaid = magnitudePaid - presentCollectbountyValue;
            msg.sender.send(excessPaid);
            magnitudePaid = magnitudePaid - excessPaid;
        }


        uint wizardCommission = (magnitudePaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = magnitudePaid - wizardCommission;

        if (presentMonarch.etherLocation != wizardRealm) {
            presentMonarch.etherLocation.send(compensation);
        } else {

        }


        pastMonarchs.push(presentMonarch);
        presentMonarch = Monarch(
            msg.sender,
            name,
            magnitudePaid,
            block.timestamp
        );


        uint rawCurrentGetpayoutValue = presentCollectbountyValue * collectbountyValueAdjustNum / receiveprizeCostAdjustDen;
        if (rawCurrentGetpayoutValue < 10 finney) {
            presentCollectbountyValue = rawCurrentGetpayoutValue;
        } else if (rawCurrentGetpayoutValue < 100 finney) {
            presentCollectbountyValue = 100 szabo * (rawCurrentGetpayoutValue / 100 szabo);
        } else if (rawCurrentGetpayoutValue < 1 ether) {
            presentCollectbountyValue = 1 finney * (rawCurrentGetpayoutValue / 1 finney);
        } else if (rawCurrentGetpayoutValue < 10 ether) {
            presentCollectbountyValue = 10 finney * (rawCurrentGetpayoutValue / 10 finney);
        } else if (rawCurrentGetpayoutValue < 100 ether) {
            presentCollectbountyValue = 100 finney * (rawCurrentGetpayoutValue / 100 finney);
        } else if (rawCurrentGetpayoutValue < 1000 ether) {
            presentCollectbountyValue = 1 ether * (rawCurrentGetpayoutValue / 1 ether);
        } else if (rawCurrentGetpayoutValue < 10000 ether) {
            presentCollectbountyValue = 10 ether * (rawCurrentGetpayoutValue / 10 ether);
        } else {
            presentCollectbountyValue = rawCurrentGetpayoutValue;
        }


        ThroneClaimed(presentMonarch.etherLocation, presentMonarch.name, presentCollectbountyValue);
    }


    function sweepCommission(uint total) onlywizard {
        wizardRealm.send(total);
    }


    function transferOwnership(address updatedLord) onlywizard {
        wizardRealm = updatedLord;
    }

}