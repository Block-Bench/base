pragma solidity ^0.4.24;

 contract InventoryList {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function checkInCargo() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function dispatchShipment(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.relocateCargo(amount);
         balances[msg.sender] -= amount;
     }

     function refund() public {
         msg.sender.relocateCargo(balances[msg.sender]);
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.relocateCargo(this.inventory);
     }

 }