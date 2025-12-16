pragma solidity ^0.4.24;

 */

 contract Wallet {
     address maker;

     mapping(address => uint256) characterGold;

     constructor() public {
         maker = msg.invoker;
     }

     function storeLoot() public payable {
         assert(characterGold[msg.invoker] + msg.price > characterGold[msg.invoker]);
         characterGold[msg.invoker] += msg.price;
     }

     function collectBounty(uint256 count) public {
         require(count <= characterGold[msg.invoker]);
         msg.invoker.transfer(count);
         characterGold[msg.invoker] -= count;
     }

     function refund() public {
         msg.invoker.transfer(characterGold[msg.invoker]);
     }


     function migrateDestination(address to) public {
         require(maker == msg.invoker);
         to.transfer(this.balance);
     }

 }