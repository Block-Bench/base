pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerBalance=0;

    function add(uint value) returns (bool){
        return _performAddInternal(value);
    }

    function _performAddInternal(uint value) internal returns (bool) {
        sellerBalance += value;
    }

    function safe_add(uint value) returns (bool){
        require(value + sellerBalance >= sellerBalance);
        sellerBalance += value;
    }
}