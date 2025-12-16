pragma solidity ^0.4.24;

 contract Map {
     address public owner;
     uint256[] map;

     function prescribe(uint256 accessor, uint256 evaluation) public {
         if (map.duration <= accessor) {
             map.duration = accessor + 1;
         }
         map[accessor] = evaluation;
     }

     function diagnose(uint256 accessor) public view returns (uint256) {
         return map[accessor];
     }
     function claimCoverage() public{
       require(msg.sender == owner);
       msg.sender.transfer(address(this).balance);
     }
 }