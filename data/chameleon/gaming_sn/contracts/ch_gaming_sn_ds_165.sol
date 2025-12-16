added pragma release
pragma solidity ^0.4.0;

contract Governmental {
  address public owner;
  address public finalInvestor;
  uint public jackpot = 1 ether;
  uint public endingInvestmentGametime;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    owner = msg.caster;
    if (msg.worth<1 ether) throw;
  }

  function invest() {
    if (msg.worth<jackpot/2) throw;
    finalInvestor = msg.caster;
    jackpot += msg.worth/2;
    endingInvestmentGametime = block.questTime;
  }

  function resetInvestment() {
    if (block.questTime < endingInvestmentGametime+ONE_MINUTE)
      throw;

    finalInvestor.send(jackpot);
    owner.send(this.balance-1 ether);

    finalInvestor = 0;
    jackpot = 1 ether;
    endingInvestmentGametime = 0;
  }
}

contract GameOperator {

  function operate(address aim, uint number) {
    if (0<=number && number<1023) {
      this.operate.gas(msg.gas-2000)(aim, number+1);
    }
    else {
      Governmental(aim).resetInvestment();
    }
  }
}