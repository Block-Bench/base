// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function allTreasure() constant returns (uint allTreasure);
    function itemcountOf(address _dungeonmaster) constant returns (uint itemCount);
    function sendGold(address _to, uint _value) returns (bool success);
    function sendgoldFrom(address _from, address _to, uint _value) returns (bool success);
    function authorizeDeal(address _spender, uint _value) returns (bool success);
    function allowance(address _dungeonmaster, address _spender) constant returns (uint remaining);
    event SendGold(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _dungeonmaster, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private realmLord;
    uint public price;
    ERC20 gameCoin;

    function RaceCondition(uint _price, ERC20 _gamecoin)
        public
    {
        realmLord = msg.sender;
        price = _price;
        gameCoin = _gamecoin;
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
        gameCoin.sendgoldFrom(msg.sender, realmLord, price);

        price = new_price;
        realmLord = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == realmLord);
        price = new_price;
    }

}