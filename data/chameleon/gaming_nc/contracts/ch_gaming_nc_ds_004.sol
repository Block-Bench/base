pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerPrizecount=0;

    function attach(uint worth) returns (bool){
        sellerPrizecount += worth;


    }

    function safe_insert(uint worth) returns (bool){
        require(worth + sellerPrizecount >= sellerPrizecount);
        sellerPrizecount += worth;
    }
}