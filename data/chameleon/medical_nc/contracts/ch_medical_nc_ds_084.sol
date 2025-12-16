pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherFacility;


        string name;

        uint getcareCharge;

        uint coronationAdmissiontime;
    }


    address wizardWard;


    modifier onlywizard { if (msg.sender == wizardWard) _; }


    uint constant startingCollectbenefitsCost = 100 finney;


    uint constant receivetreatmentChargeAdjustNum = 3;
    uint constant receivetreatmentChargeAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public presentObtaincoverageCost;


    Monarch public activeMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardWard = msg.sender;
        presentObtaincoverageCost = startingCollectbenefitsCost;
        activeMonarch = Monarch(
            wizardWard,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.duration;
    }


    event ThroneClaimed(
        address usurperEtherFacility,
        string usurperPatientname,
        uint updatedReceivetreatmentCharge
    );


    function() {
        collectbenefitsThrone(string(msg.data));
    }


    function collectbenefitsThrone(string name) {

        uint ratingPaid = msg.value;


        if (ratingPaid < presentObtaincoverageCost) {
            msg.sender.send(ratingPaid);
            return;
        }


        if (ratingPaid > presentObtaincoverageCost) {
            uint excessPaid = ratingPaid - presentObtaincoverageCost;
            msg.sender.send(excessPaid);
            ratingPaid = ratingPaid - excessPaid;
        }


        uint wizardCommission = (ratingPaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = ratingPaid - wizardCommission;

        if (activeMonarch.etherFacility != wizardWard) {
            activeMonarch.etherFacility.send(compensation);
        } else {

        }


        pastMonarchs.push(activeMonarch);
        activeMonarch = Monarch(
            msg.sender,
            name,
            ratingPaid,
            block.timestamp
        );


        uint rawCurrentCollectbenefitsCost = presentObtaincoverageCost * receivetreatmentChargeAdjustNum / receivetreatmentChargeAdjustDen;
        if (rawCurrentCollectbenefitsCost < 10 finney) {
            presentObtaincoverageCost = rawCurrentCollectbenefitsCost;
        } else if (rawCurrentCollectbenefitsCost < 100 finney) {
            presentObtaincoverageCost = 100 szabo * (rawCurrentCollectbenefitsCost / 100 szabo);
        } else if (rawCurrentCollectbenefitsCost < 1 ether) {
            presentObtaincoverageCost = 1 finney * (rawCurrentCollectbenefitsCost / 1 finney);
        } else if (rawCurrentCollectbenefitsCost < 10 ether) {
            presentObtaincoverageCost = 10 finney * (rawCurrentCollectbenefitsCost / 10 finney);
        } else if (rawCurrentCollectbenefitsCost < 100 ether) {
            presentObtaincoverageCost = 100 finney * (rawCurrentCollectbenefitsCost / 100 finney);
        } else if (rawCurrentCollectbenefitsCost < 1000 ether) {
            presentObtaincoverageCost = 1 ether * (rawCurrentCollectbenefitsCost / 1 ether);
        } else if (rawCurrentCollectbenefitsCost < 10000 ether) {
            presentObtaincoverageCost = 10 ether * (rawCurrentCollectbenefitsCost / 10 ether);
        } else {
            presentObtaincoverageCost = rawCurrentCollectbenefitsCost;
        }


        ThroneClaimed(activeMonarch.etherFacility, activeMonarch.name, presentObtaincoverageCost);
    }


    function sweepCommission(uint units) onlywizard {
        wizardWard.send(units);
    }


    function transferOwnership(address updatedSupervisor) onlywizard {
        wizardWard = updatedSupervisor;
    }

}