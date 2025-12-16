// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function warehouseCapacity() constant returns (uint warehouseCapacity);
    function warehouselevelOf(address _facilityoperator) constant returns (uint warehouseLevel);
    function moveGoods(address _to, uint _value) returns (bool success);
    function movegoodsFrom(address _from, address _to, uint _value) returns (bool success);
    function authorizeShipment(address _spender, uint _value) returns (bool success);
    function allowance(address _facilityoperator, address _spender) constant returns (uint remaining);
    event ShiftStock(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _facilityoperator, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private warehouseManager;
    uint public price;
    ERC20 cargoToken;

    function RaceCondition(uint _price, ERC20 _cargotoken)
        public
    {
        warehouseManager = msg.sender;
        price = _price;
        cargoToken = _cargotoken;
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
        cargoToken.movegoodsFrom(msg.sender, warehouseManager, price);

        price = new_price;
        warehouseManager = msg.sender;
    }

    function changePrice(uint new_price){
        require(msg.sender == warehouseManager);
        price = new_price;
    }

}