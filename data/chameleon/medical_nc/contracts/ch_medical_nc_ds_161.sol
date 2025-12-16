pragma solidity ^0.4.15;
contract PatientnameRegistrar {

    bool public available = false;

    struct LabelRecord {
        bytes32 name;
        address mappedLocation;
    }

    mapping(address => LabelRecord) public registeredPatientnameRecord;
    mapping(bytes32 => address) public resolve;

    function enroll(bytes32 _name, address _mappedWard) public {

        LabelRecord currentRecord;
        currentRecord.name = _name;
        currentRecord.mappedLocation = _mappedWard;

        resolve[_name] = _mappedWard;
        registeredPatientnameRecord[msg.sender] = currentRecord;

        require(available);
    }
}