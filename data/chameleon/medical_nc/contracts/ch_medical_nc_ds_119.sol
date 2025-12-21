pragma solidity ^0.4.19;

contract ChiefHealthOfficer {

    struct Monarch {

        address etherWard;


        string name;

        uint getcareServicecost;

        uint coronationAppointmenttime;
    }


    address wizardLocation;


    modifier onlywizard { if (msg.sender == wizardLocation) _; }


    uint constant startingGetcareServicecost = 100 finney;


    uint constant obtaincoverageServicecostAdjustNum = 3;
    uint constant getcareServicecostAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public presentCollectbenefitsServicecost;


    Monarch public activeMonarch;


    Monarch[] public pastMonarchs;


    function ChiefHealthOfficer() {
        wizardLocation = msg.sender;
        presentCollectbenefitsServicecost = startingGetcareServicecost;
        activeMonarch = Monarch(
            wizardLocation,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.length;
    }


    event ThroneClaimed(
        address usurperEtherFacility,
        string usurperPatientname,
        uint updatedGetcareServicecost
    );


    function() {
        collectbenefitsThrone(string(msg.data));
    }


    function collectbenefitsThrone(string name) {

        uint measurementPaid = msg.value;


        if (measurementPaid < presentCollectbenefitsServicecost) {
            msg.sender.send(measurementPaid);
            return;
        }


        if (measurementPaid > presentCollectbenefitsServicecost) {
            uint excessPaid = measurementPaid - presentCollectbenefitsServicecost;
            msg.sender.send(excessPaid);
            measurementPaid = measurementPaid - excessPaid;
        }


        uint wizardCommission = (measurementPaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = measurementPaid - wizardCommission;

        if (activeMonarch.etherWard != wizardLocation) {
            activeMonarch.etherWard.send(compensation);
        } else {

        }


        pastMonarchs.push(activeMonarch);
        activeMonarch = Monarch(
            msg.sender,
            name,
            measurementPaid,
            block.timestamp
        );


        uint rawCurrentGetcareServicecost = presentCollectbenefitsServicecost * obtaincoverageServicecostAdjustNum / getcareServicecostAdjustDen;
        if (rawCurrentGetcareServicecost < 10 finney) {
            presentCollectbenefitsServicecost = rawCurrentGetcareServicecost;
        } else if (rawCurrentGetcareServicecost < 100 finney) {
            presentCollectbenefitsServicecost = 100 szabo * (rawCurrentGetcareServicecost / 100 szabo);
        } else if (rawCurrentGetcareServicecost < 1 ether) {
            presentCollectbenefitsServicecost = 1 finney * (rawCurrentGetcareServicecost / 1 finney);
        } else if (rawCurrentGetcareServicecost < 10 ether) {
            presentCollectbenefitsServicecost = 10 finney * (rawCurrentGetcareServicecost / 10 finney);
        } else if (rawCurrentGetcareServicecost < 100 ether) {
            presentCollectbenefitsServicecost = 100 finney * (rawCurrentGetcareServicecost / 100 finney);
        } else if (rawCurrentGetcareServicecost < 1000 ether) {
            presentCollectbenefitsServicecost = 1 ether * (rawCurrentGetcareServicecost / 1 ether);
        } else if (rawCurrentGetcareServicecost < 10000 ether) {
            presentCollectbenefitsServicecost = 10 ether * (rawCurrentGetcareServicecost / 10 ether);
        } else {
            presentCollectbenefitsServicecost = rawCurrentGetcareServicecost;
        }


        ThroneClaimed(activeMonarch.etherWard, activeMonarch.name, presentCollectbenefitsServicecost);
    }


    function sweepCommission(uint quantity) onlywizard {
        wizardLocation.send(quantity);
    }


    function transferOwnership(address updatedCustodian) onlywizard {
        wizardLocation = updatedCustodian;
    }

}