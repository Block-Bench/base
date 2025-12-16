pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerAllocation=0;

    function attach(uint assessment) returns (bool){
        sellerAllocation += assessment;


    }

    function safe_attach(uint assessment) returns (bool){
        require(assessment + sellerAllocation >= sellerAllocation);
        sellerAllocation += assessment;
    }
}