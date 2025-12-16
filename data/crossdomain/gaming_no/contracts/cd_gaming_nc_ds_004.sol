pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerItemcount=0;

    function add(uint value) returns (bool){
        sellerItemcount += value;


    }

    function safe_add(uint value) returns (bool){
        require(value + sellerItemcount >= sellerItemcount);
        sellerItemcount += value;
    }
}