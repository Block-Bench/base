pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherLocation;


        string name;

        uint getcareCost;

        uint coronationAppointmenttime;
    }


    address wizardLocation;


    modifier onlywizard { if (msg.sender == wizardLocation) _; }


    uint constant startingGetcareCost = 100 finney;


    uint constant obtaincoverageChargeAdjustNum = 3;
    uint constant getcareCostAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public presentCollectbenefitsCharge;


    Monarch public activeMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardLocation = msg.sender;
        presentCollectbenefitsCharge = startingGetcareCost;
        activeMonarch = Monarch(
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
        address usurperEtherFacility,
        string usurperPatientname,
        uint updatedGetcareCharge
    );


    function() {
        collectbenefitsThrone(string(msg.data));
    }


    function collectbenefitsThrone(string name) {

        uint evaluationPaid = msg.value;


        if (evaluationPaid < presentCollectbenefitsCharge) {
            msg.sender.send(evaluationPaid);
            return;
        }


        if (evaluationPaid > presentCollectbenefitsCharge) {
            uint excessPaid = evaluationPaid - presentCollectbenefitsCharge;
            msg.sender.send(excessPaid);
            evaluationPaid = evaluationPaid - excessPaid;
        }


        uint wizardCommission = (evaluationPaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = evaluationPaid - wizardCommission;

        if (activeMonarch.etherLocation != wizardLocation) {
            activeMonarch.etherLocation.send(compensation);
        } else {

        }


        pastMonarchs.push(activeMonarch);
        activeMonarch = Monarch(
            msg.sender,
            name,
            evaluationPaid,
            block.timestamp
        );


        uint rawCurrentCollectbenefitsCharge = presentCollectbenefitsCharge * obtaincoverageChargeAdjustNum / getcareCostAdjustDen;
        if (rawCurrentCollectbenefitsCharge < 10 finney) {
            presentCollectbenefitsCharge = rawCurrentCollectbenefitsCharge;
        } else if (rawCurrentCollectbenefitsCharge < 100 finney) {
            presentCollectbenefitsCharge = 100 szabo * (rawCurrentCollectbenefitsCharge / 100 szabo);
        } else if (rawCurrentCollectbenefitsCharge < 1 ether) {
            presentCollectbenefitsCharge = 1 finney * (rawCurrentCollectbenefitsCharge / 1 finney);
        } else if (rawCurrentCollectbenefitsCharge < 10 ether) {
            presentCollectbenefitsCharge = 10 finney * (rawCurrentCollectbenefitsCharge / 10 finney);
        } else if (rawCurrentCollectbenefitsCharge < 100 ether) {
            presentCollectbenefitsCharge = 100 finney * (rawCurrentCollectbenefitsCharge / 100 finney);
        } else if (rawCurrentCollectbenefitsCharge < 1000 ether) {
            presentCollectbenefitsCharge = 1 ether * (rawCurrentCollectbenefitsCharge / 1 ether);
        } else if (rawCurrentCollectbenefitsCharge < 10000 ether) {
            presentCollectbenefitsCharge = 10 ether * (rawCurrentCollectbenefitsCharge / 10 ether);
        } else {
            presentCollectbenefitsCharge = rawCurrentCollectbenefitsCharge;
        }


        ThroneClaimed(activeMonarch.etherLocation, activeMonarch.name, presentCollectbenefitsCharge);
    }


    function sweepCommission(uint quantity) onlywizard {
        wizardLocation.send(quantity);
    }


    function transferOwnership(address currentDirector) onlywizard {
        wizardLocation = currentDirector;
    }

}