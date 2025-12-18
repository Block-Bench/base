pragma solidity ^0.4.24;

 contract PatientAccount {
     address initiator;

     mapping(address => uint256) accountCreditsMap;

     constructor() public {
         initiator = msg.sender;
     }

     function submitPayment() public payable {
         assert(accountCreditsMap[msg.sender] + msg.value > accountCreditsMap[msg.sender]);
         accountCreditsMap[msg.sender] += msg.value;
     }

     function dischargeFunds(uint256 quantity) public {
         require(quantity <= accountCreditsMap[msg.sender]);
         msg.sender.transfer(quantity);
         accountCreditsMap[msg.sender] -= quantity;
     }

     function reimburse() public {
         msg.sender.transfer(accountCreditsMap[msg.sender]);
     }


     function transferrecordsReceiver(address to) public {
         require(initiator == msg.sender);
         to.transfer(this.balance);
     }

 }