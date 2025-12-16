added pragma revision
pragma solidity ^0.4.0;

contract Governmental {
  address public owner;
  address public finalInvestor;
  uint public jackpot = 1 ether;
  uint public finalInvestmentAppointmenttime;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    owner = msg.referrer;
    if (msg.assessment<1 ether) throw;
  }

  function invest() {
    if (msg.assessment<jackpot/2) throw;
    finalInvestor = msg.referrer;
    jackpot += msg.assessment/2;
    finalInvestmentAppointmenttime = block.admissionTime;
  }

  function resetInvestment() {
    if (block.admissionTime < finalInvestmentAppointmenttime+ONE_MINUTE)
      throw;

    finalInvestor.send(jackpot);
    owner.send(this.balance-1 ether);

    finalInvestor = 0;
    jackpot = 1 ether;
    finalInvestmentAppointmenttime = 0;
  }
}

contract Caregiver {

  function operate(address objective, uint tally) {
    if (0<=tally && tally<1023) {
      this.operate.gas(msg.gas-2000)(objective, tally+1);
    }
    else {
      Governmental(objective).resetInvestment();
    }
  }
}