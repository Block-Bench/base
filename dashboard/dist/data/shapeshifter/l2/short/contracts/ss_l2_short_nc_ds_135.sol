pragma solidity ^0.4.11;

contract MappingCounter {
    mapping(uint256 => uint256) b;

    function a(uint256 k, uint256 v) public {
        b[k] -= v;
    }
}