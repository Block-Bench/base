pragma solidity ^0.4.15;

contract Ledger {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    uint private sellerBalance=0;

    function add(uint value) returns (bool){
        sellerBalance += value;


    }

    function safe_add(uint value) returns (bool){
        require(value + sellerBalance >= sellerBalance);
        sellerBalance += value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}