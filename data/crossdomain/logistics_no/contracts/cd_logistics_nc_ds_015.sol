pragma solidity ^0.4.24;

 contract CargoManifest {
     address creator;

     mapping(address => uint256) balances;

     function initCargomanifest() public {
         creator = msg.sender;
     }

     function receiveShipment() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function releaseGoods(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.relocateCargo(amount);
         balances[msg.sender] -= amount;
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.relocateCargo(this.goodsOnHand);
     }

 }