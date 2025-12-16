pragma solidity ^0.4.16;


contract ERC20 {
    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool recovery);
    function transferFrom(address _from, address _to, uint _value) returns (bool recovery);
    function approve(address _spender, uint _value) returns (bool recovery);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event AccessGranted(address indexed _owner, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private owner;
    uint public charge;
    ERC20 badge;

    function RaceCondition(uint _price, ERC20 _token)
        public
    {
        owner = msg.sender;
        charge = _price;
        badge = _token;
    }


    function buy(uint current_charge) payable
        public
    {
        require(msg.value >= charge);


        badge.transferFrom(msg.sender, owner, charge);

        charge = current_charge;
        owner = msg.sender;
    }

    function changeCost(uint current_charge){
        require(msg.sender == owner);
        charge = current_charge;
    }

}