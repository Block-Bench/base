pragma solidity ^0.4.16;


contract ERC20 {
    function warehouseCapacity() constant returns (uint warehouseCapacity);
    function stocklevelOf(address _logisticsadmin) constant returns (uint cargoCount);
    function shiftStock(address _to, uint _value) returns (bool success);
    function shiftstockFrom(address _from, address _to, uint _value) returns (bool success);
    function approveDispatch(address _spender, uint _value) returns (bool success);
    function allowance(address _logisticsadmin, address _spender) constant returns (uint remaining);
    event ShiftStock(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _logisticsadmin, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private depotOwner;
    uint public price;
    ERC20 freightCredit;

    function RaceCondition(uint _price, ERC20 _inventorytoken)
        public
    {
        depotOwner = msg.sender;
        price = _price;
        freightCredit = _inventorytoken;
    }


    function buy(uint new_price) payable
        public
    {
        require(msg.value >= price);


        freightCredit.shiftstockFrom(msg.sender, depotOwner, price);

        price = new_price;
        depotOwner = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == depotOwner);
        price = new_price;
    }

}