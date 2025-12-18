pragma solidity ^0.4.15;

contract Ledger {
    uint private _0x9fc5d6=0;

    function _0x7c75fb(uint value) returns (bool){
        _0x9fc5d6 += value;


    }

    function _0x3bd75e(uint value) returns (bool){
        require(value + _0x9fc5d6 >= _0x9fc5d6);
        _0x9fc5d6 += value;
    }
}