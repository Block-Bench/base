pragma solidity ^0.4.0;

contract Governmental {
  address public owner;
  address public endingInvestor;
  uint public jackpot = 1 ether;
  uint public finalInvestmentAppointmenttime;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    owner = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function invest() {
    if (msg.value<jackpot/2) throw;
    endingInvestor = msg.sender;
    jackpot += msg.value/2;
    finalInvestmentAppointmenttime = block.timestamp;
  }

  function resetInvestment() {
    if (block.timestamp < finalInvestmentAppointmenttime+ONE_MINUTE)
      throw;

    endingInvestor.send(jackpot);
    owner.send(this.balance-1 ether);

    endingInvestor = 0;
    jackpot = 1 ether;
    finalInvestmentAppointmenttime = 0;
  }
}

contract Caregiver {

  function operate(address goal, uint tally) {
    if (0<=tally && tally<1023) {
      this.operate.gas(msg.gas-2000)(goal, tally+1);
    }
    else {
      Governmental(goal).resetInvestment();
    }
  }
}
