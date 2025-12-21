pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) userBalance;

     function getBalance(address u) constant returns(uint){
         return userBalance[u];
     }

     function addToBalance() payable{
         userBalance[msg.sender] += msg.value;
     }

     function withdrawBalance(){
        _doWithdrawBalanceLogic(msg.sender);
    }

    function _doWithdrawBalanceLogic(address _sender) internal {
        if( ! (_sender.call.value(userBalance[_sender])() ) ){
        throw;
        }
        userBalance[_sender] = 0;
    }
 }