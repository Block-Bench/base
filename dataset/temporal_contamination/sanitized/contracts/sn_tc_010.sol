/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.4.19;
/*LN-3*/ 
/*LN-4*/ contract BasicDAO {
/*LN-5*/     mapping(address => uint256) public credit;
/*LN-6*/     uint256 public balance;
/*LN-7*/ 
/*LN-8*/     /**
/*LN-9*/      * @notice Deposit ETH into the contract
/*LN-10*/      */
/*LN-11*/     function deposit() public payable {
/*LN-12*/         credit[msg.sender] += msg.value;
/*LN-13*/         balance += msg.value;
/*LN-14*/     }
/*LN-15*/ 
/*LN-16*/     function withdrawAll() public {
/*LN-17*/         uint256 oCredit = credit[msg.sender];
/*LN-18*/         if (oCredit > 0) {
/*LN-19*/             balance -= oCredit;
/*LN-20*/ 
/*LN-21*/             bool callResult = msg.sender.call.value(oCredit)();
/*LN-22*/             require(callResult);
/*LN-23*/             credit[msg.sender] = 0; // This happens too late!
/*LN-24*/         }
/*LN-25*/     }
/*LN-26*/ 
/*LN-27*/     /**
/*LN-28*/      * @notice Get credited amount for an address
/*LN-29*/      */
/*LN-30*/     function getCredit(address user) public view returns (uint256) {
/*LN-31*/         return credit[user];
/*LN-32*/     }
/*LN-33*/ }
/*LN-34*/ 
/*LN-35*/ 