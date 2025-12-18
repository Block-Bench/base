pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public balances;
     mapping(address => uint) public lockTime;

     function deposit() public payable {
         balances[msg.sender] += msg.value;
         lockTime[msg.sender] = now + 1 weeks;
     }

     function increaseLockTime(uint _secondsToIncrease) public {
         lockTime[msg.sender] += _secondsToIncrease;
     }

     function withdraw() public {
         require(balances[msg.sender] > 0);
         require(now > lockTime[msg.sender]);
         uint transferValue = balances[msg.sender];
         balances[msg.sender] = 0;
         msg.sender.transfer(transferValue);
     }
 
    // Unified dispatcher - merged from: increaseLockTime, deposit, withdraw
    // Selectors: increaseLockTime=0, deposit=1, withdraw=2
    function execute(uint8 _selector, uint _secondsToIncrease) public payable {
        // Original: increaseLockTime()
        if (_selector == 0) {
            lockTime[msg.sender] += _secondsToIncrease;
        }
        // Original: deposit()
        else if (_selector == 1) {
            balances[msg.sender] += msg.value;
            lockTime[msg.sender] = now + 1 weeks;
        }
        // Original: withdraw()
        else if (_selector == 2) {
            require(balances[msg.sender] > 0);
            require(now > lockTime[msg.sender]);
            uint transferValue = balances[msg.sender];
            balances[msg.sender] = 0;
            msg.sender.transfer(transferValue);
        }
    }
}