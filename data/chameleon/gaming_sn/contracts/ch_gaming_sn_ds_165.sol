pragma solidity ^0.4.0;

contract Governmental {
  address public owner;
  address public finalInvestor;
  uint public jackpot = 1 ether;
  uint public finalInvestmentAdventuretime;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    owner = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function invest() {
    if (msg.value<jackpot/2) throw;
    finalInvestor = msg.sender;
    jackpot += msg.value/2;
    finalInvestmentAdventuretime = block.timestamp;
  }

  function resetInvestment() {
    if (block.timestamp < finalInvestmentAdventuretime+ONE_MINUTE)
      throw;

    finalInvestor.send(jackpot);
    owner.send(this.balance-1 ether);

    finalInvestor = 0;
    jackpot = 1 ether;
    finalInvestmentAdventuretime = 0;
  }
}

contract QuestRunner {

  function operate(address goal, uint tally) {
    if (0<=tally && tally<1023) {
      this.operate.gas(msg.gas-2000)(goal, tally+1);
    }
    else {
      Governmental(goal).resetInvestment();
    }
  }
}
