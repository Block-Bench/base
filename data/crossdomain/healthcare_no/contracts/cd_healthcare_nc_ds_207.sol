pragma solidity ^0.4.16;


contract ERC20 {
    function pooledBenefits() constant returns (uint pooledBenefits);
    function benefitsOf(address _supervisor) constant returns (uint credits);
    function assignCredit(address _to, uint _value) returns (bool success);
    function assigncreditFrom(address _from, address _to, uint _value) returns (bool success);
    function validateClaim(address _spender, uint _value) returns (bool success);
    function allowance(address _supervisor, address _spender) constant returns (uint remaining);
    event AssignCredit(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _supervisor, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private coordinator;
    uint public price;
    ERC20 medicalCredit;

    function RaceCondition(uint _price, ERC20 _coveragetoken)
        public
    {
        coordinator = msg.sender;
        price = _price;
        medicalCredit = _coveragetoken;
    }


    function buy(uint new_price) payable
        public
    {
        require(msg.value >= price);


        medicalCredit.assigncreditFrom(msg.sender, coordinator, price);

        price = new_price;
        coordinator = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == coordinator);
        price = new_price;
    }

}