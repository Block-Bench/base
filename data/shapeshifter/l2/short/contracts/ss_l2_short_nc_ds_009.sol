pragma solidity ^0.4.24;

 contract Map {
     address public b;
     uint256[] c;

     function e(uint256 f, uint256 value) public {
         if (c.length <= f) {
             c.length = f + 1;
         }
         c[f] = value;
     }

     function d(uint256 f) public view returns (uint256) {
         return c[f];
     }
     function a() public{
       require(msg.sender == b);
       msg.sender.transfer(address(this).balance);
     }
 }