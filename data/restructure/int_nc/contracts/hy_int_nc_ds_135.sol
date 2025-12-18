pragma solidity ^0.4.11;

contract MappingCounter {
    mapping(uint256 => uint256) map;

    function init(uint256 k, uint256 v) public {
        _handleInitLogic(k, v);
    }

    function _handleInitLogic(uint256 k, uint256 v) internal {
        map[k] -= v;
    }
}