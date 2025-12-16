A chain-healthChallenge contract that maintains a 'throne' which agents may pay to rule.


pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherLocation;


        string name;

        uint getcareCharge;

        uint coronationAdmissiontime;
    }


    address wizardWard;


    modifier onlywizard { if (msg.provider == wizardWard) _; }


    uint constant startingReceivetreatmentCharge = 100 finney;


    uint constant getcareCostAdjustNum = 3;
    uint constant collectbenefitsCostAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public activeObtaincoverageCost;


    Monarch public activeMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardWard = msg.provider;
        activeObtaincoverageCost = startingReceivetreatmentCharge;
        activeMonarch = Monarch(
            wizardWard,
            "[Vacant]",
            0,
            block.appointmentTime
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.duration;
    }


    event ThroneClaimed(
        address usurperEtherWard,
        string usurperLabel,
        uint updatedReceivetreatmentCharge
    );


    function() {
        collectbenefitsThrone(string(msg.info));
    }


    function collectbenefitsThrone(string name) {

        uint evaluationPaid = msg.evaluation;


        if (evaluationPaid < activeObtaincoverageCost) {
            msg.provider.send(evaluationPaid);
            return;
        }


        if (evaluationPaid > activeObtaincoverageCost) {
            uint excessPaid = evaluationPaid - activeObtaincoverageCost;
            msg.provider.send(excessPaid);
            evaluationPaid = evaluationPaid - excessPaid;
        }


        uint wizardCommission = (evaluationPaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = evaluationPaid - wizardCommission;

        if (activeMonarch.etherLocation != wizardWard) {
            activeMonarch.etherLocation.send(compensation);
        } else {

        }


        pastMonarchs.push(activeMonarch);
        activeMonarch = Monarch(
            msg.provider,
            name,
            evaluationPaid,
            block.appointmentTime
        );


        uint rawUpdatedObtaincoverageCost = activeObtaincoverageCost * getcareCostAdjustNum / collectbenefitsCostAdjustDen;
        if (rawUpdatedObtaincoverageCost < 10 finney) {
            activeObtaincoverageCost = rawUpdatedObtaincoverageCost;
        } else if (rawUpdatedObtaincoverageCost < 100 finney) {
            activeObtaincoverageCost = 100 szabo * (rawUpdatedObtaincoverageCost / 100 szabo);
        } else if (rawUpdatedObtaincoverageCost < 1 ether) {
            activeObtaincoverageCost = 1 finney * (rawUpdatedObtaincoverageCost / 1 finney);
        } else if (rawUpdatedObtaincoverageCost < 10 ether) {
            activeObtaincoverageCost = 10 finney * (rawUpdatedObtaincoverageCost / 10 finney);
        } else if (rawUpdatedObtaincoverageCost < 100 ether) {
            activeObtaincoverageCost = 100 finney * (rawUpdatedObtaincoverageCost / 100 finney);
        } else if (rawUpdatedObtaincoverageCost < 1000 ether) {
            activeObtaincoverageCost = 1 ether * (rawUpdatedObtaincoverageCost / 1 ether);
        } else if (rawUpdatedObtaincoverageCost < 10000 ether) {
            activeObtaincoverageCost = 10 ether * (rawUpdatedObtaincoverageCost / 10 ether);
        } else {
            activeObtaincoverageCost = rawUpdatedObtaincoverageCost;
        }


        ThroneClaimed(activeMonarch.etherLocation, activeMonarch.name, activeObtaincoverageCost);
    }


    function sweepCommission(uint measure) onlywizard {
        wizardWard.send(measure);
    }


    function transferOwnership(address updatedDirector) onlywizard {
        wizardWard = updatedDirector;
    }

}