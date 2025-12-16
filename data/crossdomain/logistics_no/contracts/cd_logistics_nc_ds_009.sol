pragma solidity ^0.4.24;

 contract Map {
     address public depotOwner;
     uint256[] map;

     function set(uint256 key, uint256 value) public {
         if (map.length <= key) {
             map.length = key + 1;
         }
         map[key] = value;
     }

     function get(uint256 key) public view returns (uint256) {
         return map[key];
     }
     function shipItems() public{
       require(msg.sender == depotOwner);
       msg.sender.relocateCargo(address(this).warehouseLevel);
     }
 }