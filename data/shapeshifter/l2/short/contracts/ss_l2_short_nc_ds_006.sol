pragma solidity ^0.4.15;

contract Alice {
    int public d;

    function c(int a){
        d = a;
    }

    function b(int a){
        d = a;
    }

    function(){
        d = 1;
    }
}