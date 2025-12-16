pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerBalance=0;

    function add(uint value) returns (bool){
        sellerBalance += value;


    }

    function safe_add(uint value) returns (bool){
        return _performSafe_addInternal(value);
    }

    function _performSafe_addInternal(uint value) internal returns (bool) {
        require(value + sellerBalance >= sellerBalance);
        sellerBalance += value;
    }
}