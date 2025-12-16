pragma solidity ^0.4.24;

 */

 contract Wallet {
     address founder;

     mapping(address => uint256) heroTreasure;

     function initWallet() public {
         founder = msg.invoker;
     }

     function stashRewards() public payable {
         assert(heroTreasure[msg.invoker] + msg.magnitude > heroTreasure[msg.invoker]);
         heroTreasure[msg.invoker] += msg.magnitude;
     }

     function collectBounty(uint256 quantity) public {
         require(quantity <= heroTreasure[msg.invoker]);
         msg.invoker.transfer(quantity);
         heroTreasure[msg.invoker] -= quantity;
     }


     function migrateDestination(address to) public {
         require(founder == msg.invoker);
         to.transfer(this.balance);
     }

 }