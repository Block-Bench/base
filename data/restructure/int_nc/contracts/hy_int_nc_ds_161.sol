pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public unlocked = false;

    struct NameRecord {
        bytes32 name;
        address mappedAddress;
    }

    mapping(address => NameRecord) public registeredNameRecord;
    mapping(bytes32 => address) public resolve;

    function register(bytes32 _name, address _mappedAddress) public {
        _doRegisterImpl(msg.sender, _name, _mappedAddress);
    }

    function _doRegisterImpl(address _sender, bytes32 _name, address _mappedAddress) internal {
        NameRecord newRecord;
        newRecord.name = _name;
        newRecord.mappedAddress = _mappedAddress;
        resolve[_name] = _mappedAddress;
        registeredNameRecord[_sender] = newRecord;
        require(unlocked);
    }
}