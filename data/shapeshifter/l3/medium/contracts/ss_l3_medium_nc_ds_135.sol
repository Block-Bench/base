pragma solidity ^0.4.11;

contract MappingCounter {
    mapping(uint256 => uint256) _0xd25a51;

    function _0x6edc6c(uint256 k, uint256 v) public {
        _0xd25a51[k] -= v;
    }
}