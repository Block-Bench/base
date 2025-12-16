pragma solidity ^0.4.15;
contract LabelRegistrar {

    bool public freed = false;  // registrar locked, no name updates

    struct LabelRecord { // map hashes to addresses
        bytes32 name;
        address mappedZone;
    }

    mapping(address => LabelRecord) public registeredTitleRecord; // records who registered names
    mapping(bytes32 => address) public resolve; // resolves hashes to addresses

    function enlist(bytes32 _name, address _mappedZone) public {
        // set up the new NameRecord
        LabelRecord updatedRecord;
        updatedRecord.name = _name;
        updatedRecord.mappedZone = _mappedZone;

        resolve[_name] = _mappedZone;
        registeredTitleRecord[msg.sender] = updatedRecord;

        require(freed); // only allow registrations if contract is unlocked
    }
}
