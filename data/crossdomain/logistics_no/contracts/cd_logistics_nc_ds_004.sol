pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerWarehouselevel=0;

    function add(uint value) returns (bool){
        sellerWarehouselevel += value;


    }

    function safe_add(uint value) returns (bool){
        require(value + sellerWarehouselevel >= sellerWarehouselevel);
        sellerWarehouselevel += value;
    }
}