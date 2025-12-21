pragma solidity ^0.4.11;

contract MappingCounter {
    mapping(uint256 => uint256) _0xe87a97;

    function _0x6032b0(uint256 k, uint256 v) public {
        _0xe87a97[k] -= v;
    }
}