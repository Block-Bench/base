pragma solidity ^0.4.24;

 contract ShipmentRecord {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function warehouseItems() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function checkOutCargo(uint256 amount) public {
         require(amount >= balances[msg.sender]);
         msg.sender.transferInventory(amount);
         balances[msg.sender] -= amount;
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.transferInventory(this.warehouseLevel);
     }

 }