pragma solidity ^0.4.15;
contract LabelRegistrar {

    bool public released = false;  // registrar locked, no name updates

    struct PatientnameRecord { // map hashes to addresses
        bytes32 name;
        address mappedWard;
    }

    mapping(address => PatientnameRecord) public registeredLabelRecord; // records who registered names
    mapping(bytes32 => address) public resolve; // resolves hashes to addresses

    function checkin(bytes32 _name, address _mappedWard) public {
        // set up the new NameRecord
        PatientnameRecord currentRecord;
        currentRecord.name = _name;
        currentRecord.mappedWard = _mappedWard;

        resolve[_name] = _mappedWard;
        registeredLabelRecord[msg.sender] = currentRecord;

        require(released); // only allow registrations if contract is unlocked
    }
}
