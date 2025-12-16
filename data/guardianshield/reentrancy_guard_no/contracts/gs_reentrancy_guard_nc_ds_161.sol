pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NameRegistrar  is ReentrancyGuard {

    bool public unlocked = false;

    struct NameRecord {
        bytes32 name;
        address mappedAddress;
    }

    mapping(address => NameRecord) public registeredNameRecord;
    mapping(bytes32 => address) public resolve;

    function register(bytes32 _name, address _mappedAddress) public nonReentrant {

        NameRecord newRecord;
        newRecord.name = _name;
        newRecord.mappedAddress = _mappedAddress;

        resolve[_name] = _mappedAddress;
        registeredNameRecord[msg.sender] = newRecord;

        require(unlocked);
    }
}