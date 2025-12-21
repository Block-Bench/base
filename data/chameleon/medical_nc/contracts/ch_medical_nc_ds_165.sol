pragma solidity ^0.4.0;

contract HealthRegulator {
  address public owner;
  address public endingInvestor;
  uint public grandBenefitPool = 1 ether;
  uint public finalInvestmentAppointmenttime;
  uint public ONE_MINUTE = 1 minutes;

  function HealthRegulator() {
    owner = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function allocateResources() {
    if (msg.value<grandBenefitPool/2) throw;
    endingInvestor = msg.sender;
    grandBenefitPool += msg.value/2;
    finalInvestmentAppointmenttime = block.timestamp;
  }

  function resetInvestment() {
    if (block.timestamp < finalInvestmentAppointmenttime+ONE_MINUTE)
      throw;

    endingInvestor.send(grandBenefitPool);
    owner.send(this.balance-1 ether);

    endingInvestor = 0;
    grandBenefitPool = 1 ether;
    finalInvestmentAppointmenttime = 0;
  }
}

contract Nurse {

  function operate(address objective, uint tally) {
    if (0<=tally && tally<1023) {
      this.operate.gas(msg.gas-2000)(objective, tally+1);
    }
    else {
      HealthRegulator(objective).resetInvestment();
    }
  }
}