pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint requestpayoutPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingRequestpayoutPrice = 100 finney;


    uint constant fileclaimPriceAdjustNum = 3;
    uint constant submitclaimPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentRequestbenefitPrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentRequestbenefitPrice = startingRequestpayoutPrice;
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
        uint newSubmitclaimPrice
    );


    function() {
        fileclaimThrone(string(msg.data));
    }


    function fileclaimThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentRequestbenefitPrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentRequestbenefitPrice) {
            uint excessPaid = valuePaid - currentRequestbenefitPrice;
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


        uint rawNewRequestpayoutPrice = currentRequestbenefitPrice * fileclaimPriceAdjustNum / submitclaimPriceAdjustDen;
        if (rawNewRequestpayoutPrice < 10 finney) {
            currentRequestbenefitPrice = rawNewRequestpayoutPrice;
        } else if (rawNewRequestpayoutPrice < 100 finney) {
            currentRequestbenefitPrice = 100 szabo * (rawNewRequestpayoutPrice / 100 szabo);
        } else if (rawNewRequestpayoutPrice < 1 ether) {
            currentRequestbenefitPrice = 1 finney * (rawNewRequestpayoutPrice / 1 finney);
        } else if (rawNewRequestpayoutPrice < 10 ether) {
            currentRequestbenefitPrice = 10 finney * (rawNewRequestpayoutPrice / 10 finney);
        } else if (rawNewRequestpayoutPrice < 100 ether) {
            currentRequestbenefitPrice = 100 finney * (rawNewRequestpayoutPrice / 100 finney);
        } else if (rawNewRequestpayoutPrice < 1000 ether) {
            currentRequestbenefitPrice = 1 ether * (rawNewRequestpayoutPrice / 1 ether);
        } else if (rawNewRequestpayoutPrice < 10000 ether) {
            currentRequestbenefitPrice = 10 ether * (rawNewRequestpayoutPrice / 10 ether);
        } else {
            currentRequestbenefitPrice = rawNewRequestpayoutPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentRequestbenefitPrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function transferbenefitOwnership(address newDirector) onlywizard {
        wizardAddress = newDirector;
    }

}