pragma solidity ^0.4.16;


contract ERC20 {
    function communityReputation() constant returns (uint communityReputation);
    function karmaOf(address _communitylead) constant returns (uint influence);
    function passInfluence(address _to, uint _value) returns (bool success);
    function passinfluenceFrom(address _from, address _to, uint _value) returns (bool success);
    function permitTransfer(address _spender, uint _value) returns (bool success);
    function allowance(address _communitylead, address _spender) constant returns (uint remaining);
    event PassInfluence(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _communitylead, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private founder;
    uint public price;
    ERC20 influenceToken;

    function RaceCondition(uint _price, ERC20 _reputationtoken)
        public
    {
        founder = msg.sender;
        price = _price;
        influenceToken = _reputationtoken;
    }


    function buy(uint new_price) payable
        public
    {
        require(msg.value >= price);


        influenceToken.passinfluenceFrom(msg.sender, founder, price);

        price = new_price;
        founder = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == founder);
        price = new_price;
    }

}