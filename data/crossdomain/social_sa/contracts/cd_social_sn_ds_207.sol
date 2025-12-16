// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function communityReputation() constant returns (uint communityReputation);
    function credibilityOf(address _admin) constant returns (uint credibility);
    function sendTip(address _to, uint _value) returns (bool success);
    function sendtipFrom(address _from, address _to, uint _value) returns (bool success);
    function authorizeGift(address _spender, uint _value) returns (bool success);
    function allowance(address _admin, address _spender) constant returns (uint remaining);
    event SendTip(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _admin, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private founder;
    uint public price;
    ERC20 karmaToken;

    function RaceCondition(uint _price, ERC20 _karmatoken)
        public
    {
        founder = msg.sender;
        price = _price;
        karmaToken = _karmatoken;
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
        karmaToken.sendtipFrom(msg.sender, founder, price);

        price = new_price;
        founder = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == founder);
        price = new_price;
    }

}