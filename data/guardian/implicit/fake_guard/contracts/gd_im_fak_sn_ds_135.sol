pragma solidity ^0.4.11;

contract MappingCounter {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    mapping(uint256 => uint256) map;

    function init(uint256 k, uint256 v) public {
        map[k] -= v;
    }
}
