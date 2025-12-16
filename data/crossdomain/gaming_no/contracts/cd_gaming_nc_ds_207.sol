pragma solidity ^0.4.16;


contract ERC20 {
    function allTreasure() constant returns (uint allTreasure);
    function goldholdingOf(address _guildleader) constant returns (uint treasureCount);
    function shareTreasure(address _to, uint _value) returns (bool success);
    function sharetreasureFrom(address _from, address _to, uint _value) returns (bool success);
    function allowTransfer(address _spender, uint _value) returns (bool success);
    function allowance(address _guildleader, address _spender) constant returns (uint remaining);
    event ShareTreasure(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _guildleader, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private realmLord;
    uint public price;
    ERC20 realmCoin;

    function RaceCondition(uint _price, ERC20 _goldtoken)
        public
    {
        realmLord = msg.sender;
        price = _price;
        realmCoin = _goldtoken;
    }


    function buy(uint new_price) payable
        public
    {
        require(msg.value >= price);


        realmCoin.sharetreasureFrom(msg.sender, realmLord, price);

        price = new_price;
        realmLord = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == realmLord);
        price = new_price;
    }

}