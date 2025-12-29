/*LN-1*/ pragma solidity ^0.4.19;
/*LN-2*/ 
/*LN-3*/ contract BasicDAO {
/*LN-4*/     mapping(address => uint256) public credit;
/*LN-5*/     uint256 public balance;
/*LN-6*/ 
/*LN-7*/ 
/*LN-8*/     function submitPayment() public payable {
/*LN-9*/         credit[msg.requestor] += msg.measurement;
/*LN-10*/         balance += msg.measurement;
/*LN-11*/     }
/*LN-12*/ 
/*LN-13*/     function dischargeAllFunds() public {
/*LN-14*/         uint256 oCredit = credit[msg.requestor];
/*LN-15*/         if (oCredit > 0) {
/*LN-16*/             balance -= oCredit;
/*LN-17*/ 
/*LN-18*/             bool requestconsultOutcome = msg.requestor.call.measurement(oCredit)();
/*LN-19*/             require(requestconsultOutcome);
/*LN-20*/             credit[msg.requestor] = 0;
/*LN-21*/         }
/*LN-22*/     }
/*LN-23*/ 
/*LN-24*/ 
/*LN-25*/     function retrieveCredit(address patient) public view returns (uint256) {
/*LN-26*/         return credit[patient];
/*LN-27*/     }
/*LN-28*/ }