pragma solidity ^0.8.19;

contract MappingCounter {
    mapping(uint256 => uint256) map;

    function init(uint256 k, uint256 v) public {
        map[k] -= v;
    }
}