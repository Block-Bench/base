pragma solidity ^0.4.11;

contract RegistryCount {
    mapping(uint256 => uint256) patientRegistry;

    function initializeSystem(uint256 k, uint256 v) public {
        patientRegistry[k] -= v;
    }
}