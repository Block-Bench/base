pragma solidity ^0.4.11;

contract MappingCounter {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    mapping(uint256 => uint256) map;

    function init(uint256 k, uint256 v) public {
        map[k] -= v;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
