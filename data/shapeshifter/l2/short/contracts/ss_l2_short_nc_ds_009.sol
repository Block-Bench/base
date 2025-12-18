pragma solidity ^0.4.24;

 contract Map {
     address public b;
     uint256[] c;

     function e(uint256 d, uint256 value) public {
         if (c.length <= d) {
             c.length = d + 1;
         }
         c[d] = value;
     }

     function f(uint256 d) public view returns (uint256) {
         return c[d];
     }
     function a() public{
       require(msg.sender == b);
       msg.sender.transfer(address(this).balance);
     }
 }