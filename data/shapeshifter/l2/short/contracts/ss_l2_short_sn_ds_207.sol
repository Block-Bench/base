// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function b() constant returns (uint b);
    function f(address m) constant returns (uint balance);
    function transfer(address s, uint k) returns (bool j);
    function a(address p, address s, uint k) returns (bool j);
    function i(address h, uint k) returns (bool j);
    function d(address m, address h) constant returns (uint e);
    event Transfer(address indexed p, address indexed s, uint k);
    event Approval(address indexed m, address indexed h, uint k);
}

contract TokenExchange{
    address private q;
    uint public r;
    ERC20 o;

    function TokenExchange(uint n, ERC20 l)
        public
    {
        q = msg.sender;
        r = n;
        o = l;
    }

    // If the owner sees someone calls buy
    // he can call changePrice to set a new price
    // If his transaction is mined first, he can
    // receive more tokens than excepted by the new buyer
    function t(uint g) payable
        public
    {
        require(msg.value >= r);

        // we assume that the TokenExchange contract
        // has enough allowance
        o.a(msg.sender, q, r);

        r = g;
        q = msg.sender;
    }

    function c(uint g){
        require(msg.sender == q);
        r = g;
    }

}