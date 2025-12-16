A Bound Name Registrar

pragma solidity ^0.4.15;
contract TitleRegistrar {

    bool public released = false;  // registrar locked, no name updates

    struct LabelRecord { // map hashes to addresses
        bytes32 name;
        address mappedLocation;
    }

    mapping(address => LabelRecord) public registeredTagRecord; // records who registered names
    mapping(bytes32 => address) public resolve; // resolves hashes to addresses

    function enlist(bytes32 _name, address _mappedRealm) public {
        // set up the new NameRecord
        LabelRecord currentRecord;
        currentRecord.name = _name;
        currentRecord.mappedLocation = _mappedRealm;

        resolve[_name] = _mappedRealm;
        registeredTagRecord[msg.caster] = currentRecord;

        require(released); // only allow registrations if contract is unlocked
    }
}