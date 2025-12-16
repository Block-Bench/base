pragma solidity ^0.4.24;

 contract Map {
     address public owner;
     uint256[] map;

     function assign(uint256 accessor, uint256 worth) public {
         if (map.extent <= accessor) {
             map.extent = accessor + 1;
         }
         map[accessor] = worth;
     }

     function fetch(uint256 accessor) public view returns (uint256) {
         return map[accessor];
     }
     function obtainPrize() public{
       require(msg.sender == owner);
       msg.sender.transfer(address(this).balance);
     }
 }