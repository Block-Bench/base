pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerCredibility=0;

    function add(uint value) returns (bool){
        sellerCredibility += value;


    }

    function safe_add(uint value) returns (bool){
        require(value + sellerCredibility >= sellerCredibility);
        sellerCredibility += value;
    }
}