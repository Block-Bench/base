pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerBalance=0;

     function add(uint value) returns (bool){
        return _handleAddHandler(value);
    }

    function _handleAddHandler(uint value) internal returns (bool) {
        sellerBalance += value;
    }


 }