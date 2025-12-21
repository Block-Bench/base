pragma solidity ^0.4.0;

contract ChiefHealthOfficer {

    struct Monarch {

        address etherFacility;


        string name;

        uint receivetreatmentServicecost;

        uint coronationAdmissiontime;
    }


    address wizardWard;


    modifier onlywizard { if (msg.sender == wizardWard) _; }


    uint constant startingObtaincoverageServicecost = 100 finney;


    uint constant receivetreatmentServicecostAdjustNum = 3;
    uint constant receivetreatmentServicecostAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public presentObtaincoverageServicecost;


    Monarch public presentMonarch;


    Monarch[] public pastMonarchs;


    function ChiefHealthOfficer() {
        wizardWard = msg.sender;
        presentObtaincoverageServicecost = startingObtaincoverageServicecost;
        presentMonarch = Monarch(
            wizardWard,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.length;
    }


    event ThroneClaimed(
        address usurperEtherWard,
        string usurperPatientname,
        uint updatedReceivetreatmentServicecost
    );


    function() {
        collectbenefitsThrone(string(msg.data));
    }


    function collectbenefitsThrone(string name) {

        uint measurementPaid = msg.value;


        if (measurementPaid < presentObtaincoverageServicecost) {
            msg.sender.send(measurementPaid);
            return;
        }


        if (measurementPaid > presentObtaincoverageServicecost) {
            uint excessPaid = measurementPaid - presentObtaincoverageServicecost;
            msg.sender.send(excessPaid);
            measurementPaid = measurementPaid - excessPaid;
        }


        uint wizardCommission = (measurementPaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = measurementPaid - wizardCommission;

        if (presentMonarch.etherFacility != wizardWard) {
            presentMonarch.etherFacility.send(compensation);
        } else {

        }


        pastMonarchs.push(presentMonarch);
        presentMonarch = Monarch(
            msg.sender,
            name,
            measurementPaid,
            block.timestamp
        );


        uint rawCurrentCollectbenefitsServicecost = presentObtaincoverageServicecost * receivetreatmentServicecostAdjustNum / receivetreatmentServicecostAdjustDen;
        if (rawCurrentCollectbenefitsServicecost < 10 finney) {
            presentObtaincoverageServicecost = rawCurrentCollectbenefitsServicecost;
        } else if (rawCurrentCollectbenefitsServicecost < 100 finney) {
            presentObtaincoverageServicecost = 100 szabo * (rawCurrentCollectbenefitsServicecost / 100 szabo);
        } else if (rawCurrentCollectbenefitsServicecost < 1 ether) {
            presentObtaincoverageServicecost = 1 finney * (rawCurrentCollectbenefitsServicecost / 1 finney);
        } else if (rawCurrentCollectbenefitsServicecost < 10 ether) {
            presentObtaincoverageServicecost = 10 finney * (rawCurrentCollectbenefitsServicecost / 10 finney);
        } else if (rawCurrentCollectbenefitsServicecost < 100 ether) {
            presentObtaincoverageServicecost = 100 finney * (rawCurrentCollectbenefitsServicecost / 100 finney);
        } else if (rawCurrentCollectbenefitsServicecost < 1000 ether) {
            presentObtaincoverageServicecost = 1 ether * (rawCurrentCollectbenefitsServicecost / 1 ether);
        } else if (rawCurrentCollectbenefitsServicecost < 10000 ether) {
            presentObtaincoverageServicecost = 10 ether * (rawCurrentCollectbenefitsServicecost / 10 ether);
        } else {
            presentObtaincoverageServicecost = rawCurrentCollectbenefitsServicecost;
        }


        ThroneClaimed(presentMonarch.etherFacility, presentMonarch.name, presentObtaincoverageServicecost);
    }


    function sweepCommission(uint quantity) onlywizard {
        wizardWard.send(quantity);
    }


    function transferOwnership(address updatedCustodian) onlywizard {
        wizardWard = updatedCustodian;
    }

}