pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address etherAddress;


        string name;

        uint getrewardPrice;

        uint coronationTimestamp;
    }


    address wizardAddress;


    modifier onlywizard { if (msg.sender == wizardAddress) _; }


    uint constant startingClaimkarmaPrice = 100 finney;


    uint constant getrewardPriceAdjustNum = 3;
    uint constant getrewardPriceAdjustDen = 2;


    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;


    uint public currentRedeemreputationPrice;


    Monarch public currentMonarch;


    Monarch[] public pastMonarchs;


    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentRedeemreputationPrice = startingClaimkarmaPrice;
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
        uint newClaimkarmaPrice
    );


    function() {
        collecttipsThrone(string(msg.data));
    }


    function collecttipsThrone(string name) {

        uint valuePaid = msg.value;


        if (valuePaid < currentRedeemreputationPrice) {
            msg.sender.send(valuePaid);
            return;
        }


        if (valuePaid > currentRedeemreputationPrice) {
            uint excessPaid = valuePaid - currentRedeemreputationPrice;
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


        uint rawNewGetrewardPrice = currentRedeemreputationPrice * getrewardPriceAdjustNum / getrewardPriceAdjustDen;
        if (rawNewGetrewardPrice < 10 finney) {
            currentRedeemreputationPrice = rawNewGetrewardPrice;
        } else if (rawNewGetrewardPrice < 100 finney) {
            currentRedeemreputationPrice = 100 szabo * (rawNewGetrewardPrice / 100 szabo);
        } else if (rawNewGetrewardPrice < 1 ether) {
            currentRedeemreputationPrice = 1 finney * (rawNewGetrewardPrice / 1 finney);
        } else if (rawNewGetrewardPrice < 10 ether) {
            currentRedeemreputationPrice = 10 finney * (rawNewGetrewardPrice / 10 finney);
        } else if (rawNewGetrewardPrice < 100 ether) {
            currentRedeemreputationPrice = 100 finney * (rawNewGetrewardPrice / 100 finney);
        } else if (rawNewGetrewardPrice < 1000 ether) {
            currentRedeemreputationPrice = 1 ether * (rawNewGetrewardPrice / 1 ether);
        } else if (rawNewGetrewardPrice < 10000 ether) {
            currentRedeemreputationPrice = 10 ether * (rawNewGetrewardPrice / 10 ether);
        } else {
            currentRedeemreputationPrice = rawNewGetrewardPrice;
        }


        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentRedeemreputationPrice);
    }


    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }


    function sharekarmaOwnership(address newModerator) onlywizard {
        wizardAddress = newModerator;
    }

}