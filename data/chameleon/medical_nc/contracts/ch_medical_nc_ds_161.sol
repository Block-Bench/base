A Reserved Name Registrar

pragma solidity ^0.4.15;
contract LabelRegistrar {

    bool public released = false;

    struct PatientnameRecord {
        bytes32 name;
        address mappedLocation;
    }

    mapping(address => PatientnameRecord) public registeredLabelRecord;
    mapping(bytes32 => address) public resolve;

    function enroll(bytes32 _name, address _mappedWard) public {

        PatientnameRecord currentRecord;
        currentRecord.name = _name;
        currentRecord.mappedLocation = _mappedWard;

        resolve[_name] = _mappedWard;
        registeredLabelRecord[msg.provider] = currentRecord;

        require(released);
    }
}