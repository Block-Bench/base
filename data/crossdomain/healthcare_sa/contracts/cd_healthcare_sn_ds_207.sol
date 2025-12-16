// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function pooledBenefits() constant returns (uint pooledBenefits);
    function remainingbenefitOf(address _director) constant returns (uint remainingBenefit);
    function transferBenefit(address _to, uint _value) returns (bool success);
    function transferbenefitFrom(address _from, address _to, uint _value) returns (bool success);
    function authorizeClaim(address _spender, uint _value) returns (bool success);
    function allowance(address _director, address _spender) constant returns (uint remaining);
    event AssignCredit(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _director, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private administrator;
    uint public price;
    ERC20 healthToken;

    function RaceCondition(uint _price, ERC20 _healthtoken)
        public
    {
        administrator = msg.sender;
        price = _price;
        healthToken = _healthtoken;
    }

    // If the owner sees someone calls buy
    // he can call changePrice to set a new price
    // If his transaction is mined first, he can
    // receive more tokens than excepted by the new buyer
    function buy(uint new_price) payable
        public
    {
        require(msg.value >= price);

        // we assume that the RaceCondition contract
        // has enough allowance
        healthToken.transferbenefitFrom(msg.sender, administrator, price);

        price = new_price;
        administrator = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == administrator);
        price = new_price;
    }

}