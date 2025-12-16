pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint requestpayoutPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingRequestbenefitPrice = 100 finney;


    uint constant requestpayoutPriceAdjustNum = 3;
    uint constant requestpayoutPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentSubmitclaimPrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentSubmitclaimPrice = startingRequestbenefitPrice;
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
        uint newRequestbenefitPrice
    );


    function() {
        fileclaimThrone(string(msg.data));
    }


    function fileclaimThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentSubmitclaimPrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentSubmitclaimPrice) {
            uint excessPaid = valuePaid - currentSubmitclaimPrice;
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


        uint rawNewRequestpayoutPrice = currentSubmitclaimPrice * requestpayoutPriceAdjustNum / requestpayoutPriceAdjustDen;
        if (rawNewRequestpayoutPrice < 10 finney) {
            currentSubmitclaimPrice = rawNewRequestpayoutPrice;
        } else if (rawNewRequestpayoutPrice < 100 finney) {
            currentSubmitclaimPrice = 100 szabo * (rawNewRequestpayoutPrice / 100 szabo);
        } else if (rawNewRequestpayoutPrice < 1 ether) {
            currentSubmitclaimPrice = 1 finney * (rawNewRequestpayoutPrice / 1 finney);
        } else if (rawNewRequestpayoutPrice < 10 ether) {
            currentSubmitclaimPrice = 10 finney * (rawNewRequestpayoutPrice / 10 finney);
        } else if (rawNewRequestpayoutPrice < 100 ether) {
            currentSubmitclaimPrice = 100 finney * (rawNewRequestpayoutPrice / 100 finney);
        } else if (rawNewRequestpayoutPrice < 1000 ether) {
            currentSubmitclaimPrice = 1 ether * (rawNewRequestpayoutPrice / 1 ether);
        } else if (rawNewRequestpayoutPrice < 10000 ether) {
            currentSubmitclaimPrice = 10 ether * (rawNewRequestpayoutPrice / 10 ether);
        } else {
            currentSubmitclaimPrice = rawNewRequestpayoutPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentSubmitclaimPrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function movecoverageOwnership(address newAdministrator) onlywizard {
        wizardAddress = newAdministrator;
    }

}