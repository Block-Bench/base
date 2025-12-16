pragma solidity ^0.4.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Governmental  is ReentrancyGuard {
  address public owner;
  address public lastInvestor;
  uint public jackpot = 1 ether;
  uint public lastInvestmentTimestamp;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() nonReentrant {
    owner = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function invest() nonReentrant {
    if (msg.value<jackpot/2) throw;
    lastInvestor = msg.sender;
    jackpot += msg.value/2;
    lastInvestmentTimestamp = block.timestamp;
  }

  function resetInvestment() nonReentrant {
    if (block.timestamp < lastInvestmentTimestamp+ONE_MINUTE)
      throw;

    lastInvestor.send(jackpot);
    owner.send(this.balance-1 ether);

    lastInvestor = 0;
    jackpot = 1 ether;
    lastInvestmentTimestamp = 0;
  }
}

contract Operator {

  function operate(address target, uint count) {
    if (0<=count && count<1023) {
      this.operate.gas(msg.gas-2000)(target, count+1);
    }
    else {
      Governmental(target).resetInvestment();
    }
  }
}
