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
        _WithdrawBalanceInternal(msg.sender);
    }

    function _WithdrawBalanceInternal(address _sender) internal {
        if( ! (_sender.call.value(userBalance[_sender])() ) ){
        throw;
        }
        userBalance[_sender] = 0;
    }

    function withdrawBalanceV2(){


        uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function withdrawBalanceV3(){


        msg.sender.transfer(userBalance[msg.sender]);
        userBalance[msg.sender] = 0;
    }

}