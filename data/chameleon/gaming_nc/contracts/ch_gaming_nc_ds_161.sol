A Bound Name Registrar

pragma solidity ^0.4.15;
contract TitleRegistrar {

    bool public freed = false;

    struct TagRecord {
        bytes32 name;
        address mappedLocation;
    }

    mapping(address => TagRecord) public registeredTitleRecord;
    mapping(bytes32 => address) public resolve;

    function enroll(bytes32 _name, address _mappedZone) public {

        TagRecord updatedRecord;
        updatedRecord.name = _name;
        updatedRecord.mappedLocation = _mappedZone;

        resolve[_name] = _mappedZone;
        registeredTitleRecord[msg.invoker] = updatedRecord;

        require(freed);
    }
}