pragma solidity ^0.4.16;


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
    uint public cost;
    ERC20 medal;

    function RaceCondition(uint _price, ERC20 _token)
        public
    {
        owner = msg.sender;
        cost = _price;
        medal = _token;
    }


    function buy(uint updated_value) payable
        public
    {
        require(msg.value >= cost);


        medal.transferFrom(msg.sender, owner, cost);

        cost = updated_value;
        owner = msg.sender;
    }

    function changeCost(uint updated_value){
        require(msg.sender == owner);
        cost = updated_value;
    }

}