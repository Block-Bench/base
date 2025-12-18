pragma solidity ^0.4.16;


contract ERC20 {
    function b() constant returns (uint b);
    function f(address k) constant returns (uint balance);
    function transfer(address s, uint m) returns (bool i);
    function a(address q, address s, uint m) returns (bool i);
    function j(address h, uint m) returns (bool i);
    function d(address k, address h) constant returns (uint e);
    event Transfer(address indexed q, address indexed s, uint m);
    event Approval(address indexed k, address indexed h, uint m);
}

contract TokenExchange{
    address private p;
    uint public o;
    ERC20 r;

    function TokenExchange(uint l, ERC20 n)
        public
    {
        p = msg.sender;
        o = l;
        r = n;
    }


    function t(uint g) payable
        public
    {
        require(msg.value >= o);


        r.a(msg.sender, p, o);

        o = g;
        p = msg.sender;
    }

    function c(uint g){
        require(msg.sender == p);
        o = g;
    }

}