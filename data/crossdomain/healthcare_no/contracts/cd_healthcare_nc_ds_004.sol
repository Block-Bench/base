pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerRemainingbenefit=0;

    function add(uint value) returns (bool){
        sellerRemainingbenefit += value;


    }

    function safe_add(uint value) returns (bool){
        require(value + sellerRemainingbenefit >= sellerRemainingbenefit);
        sellerRemainingbenefit += value;
    }
}