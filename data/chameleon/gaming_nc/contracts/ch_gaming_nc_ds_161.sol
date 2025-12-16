pragma solidity ^0.4.15;
contract LabelRegistrar {

    bool public freed = false;

    struct LabelRecord {
        bytes32 name;
        address mappedZone;
    }

    mapping(address => LabelRecord) public registeredTagRecord;
    mapping(bytes32 => address) public resolve;

    function signup(bytes32 _name, address _mappedZone) public {

        LabelRecord currentRecord;
        currentRecord.name = _name;
        currentRecord.mappedZone = _mappedZone;

        resolve[_name] = _mappedZone;
        registeredTagRecord[msg.sender] = currentRecord;

        require(freed);
    }
}