// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool win);
    function transferFrom(address _from, address _to, uint _value) returns (bool win);
    function approve(address _spender, uint _value) returns (bool win);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event PermissionGranted(address indexed _owner, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private owner;
    uint public value;
    ERC20 medal;

    function RaceCondition(uint _price, ERC20 _token)
        public
    {
        owner = msg.sender;
        value = _price;
        medal = _token;
    }

    // If the owner sees someone calls buy
    // he can call changePrice to set a new price
    // If his transaction is mined first, he can
    // receive more tokens than excepted by the new buyer
    function buy(uint current_value) payable
        public
    {
        require(msg.value >= value);

        // we assume that the RaceCondition contract
        // has enough allowance
        medal.transferFrom(msg.sender, owner, value);

        value = current_value;
        owner = msg.sender;
    }

    function changeValue(uint current_value){
        require(msg.sender == owner);
        value = current_value;
    }

}