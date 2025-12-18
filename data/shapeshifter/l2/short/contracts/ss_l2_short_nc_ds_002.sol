pragma solidity ^0.4.15;

contract TokenVault {
    mapping (address => uint) e;

    function f(address u) constant returns(uint){
        return e[u];
    }

    function d() payable{
        e[msg.sender] += msg.value;
    }

    function c(){


        if( ! (msg.sender.call.value(e[msg.sender])() ) ){
            throw;
        }
        e[msg.sender] = 0;
    }

    function b(){


        uint g = e[msg.sender];
        e[msg.sender] = 0;
        if( ! (msg.sender.call.value(g)() ) ){
            throw;
        }
    }

    function a(){


        msg.sender.transfer(e[msg.sender]);
        e[msg.sender] = 0;
    }

}