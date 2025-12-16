A Committed Name Registrar

pragma solidity ^0.4.15;
contract LabelRegistrar {

    bool public released = false;  // registrar locked, no name updates

    struct LabelRecord { // map hashes to addresses
        bytes32 name;
        address mappedFacility;
    }

    mapping(address => LabelRecord) public registeredLabelRecord; // records who registered names
    mapping(bytes32 => address) public resolve; // resolves hashes to addresses

    function admit(bytes32 _name, address _mappedFacility) public {
        // set up the new NameRecord
        LabelRecord currentRecord;
        currentRecord.name = _name;
        currentRecord.mappedFacility = _mappedFacility;

        resolve[_name] = _mappedFacility;
        registeredLabelRecord[msg.provider] = currentRecord;

        require(released); // only allow registrations if contract is unlocked
    }
}