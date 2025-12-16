pragma solidity ^0.4.11;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MappingCounter  is ReentrancyGuard {
    mapping(uint256 => uint256) map;

    function init(uint256 k, uint256 v) public {
        map[k] -= v;
    }
}