 pragma solidity ^0.4.10;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


 contract TimeLock  is ReentrancyGuard {

     mapping(address => uint) public balances;
     mapping(address => uint) public lockTime;

     function deposit() public payable nonReentrant {
         balances[msg.sender] += msg.value;
         lockTime[msg.sender] = now + 1 weeks;
     }

     function increaseLockTime(uint _secondsToIncrease) public nonReentrant {
         lockTime[msg.sender] += _secondsToIncrease;
     }

     function withdraw() public nonReentrant {
         require(balances[msg.sender] > 0);
         require(now > lockTime[msg.sender]);
         uint transferValue = balances[msg.sender];
         balances[msg.sender] = 0;
         msg.sender.transfer(transferValue);
     }
 }
