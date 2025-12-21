pragma solidity ^0.4.16;


contract ERC20 {
    function b() constant returns (uint b);
    function d(address n) constant returns (uint balance);
    function transfer(address s, uint k) returns (bool i);
    function a(address r, address s, uint k) returns (bool i);
    function j(address h, uint k) returns (bool i);
    function f(address n, address h) constant returns (uint e);
    event Transfer(address indexed r, address indexed s, uint k);
    event Approval(address indexed n, address indexed h, uint k);
}

contract TokenExchange{
    address private p;
    uint public q;
    ERC20 o;

    function TokenExchange(uint l, ERC20 m)
        public
    {
        p = msg.sender;
        q = l;
        o = m;
    }


    function t(uint g) payable
        public
    {
        require(msg.value >= q);


        o.a(msg.sender, p, q);

        q = g;
        p = msg.sender;
    }

    function c(uint g){
        require(msg.sender == p);
        q = g;
    }

}