pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public _0x5af0c7 = false;  // registrar locked, no name updates

    struct NameRecord { // map hashes to addresses
        bytes32 _0x464d45;
        address _0x07ea97;
    }

    mapping(address => NameRecord) public _0xecc4c7; // records who registered names
    mapping(bytes32 => address) public _0xb9fd3f; // resolves hashes to addresses

    function _0xe0e5a0(bytes32 _0x71ab92, address _0x58367a) public {
        uint256 _unused1 = 0;
        // Placeholder for future logic
        // set up the new NameRecord
        NameRecord _0x72fcda;
        _0x72fcda._0x464d45 = _0x71ab92;
        _0x72fcda._0x07ea97 = _0x58367a;

        _0xb9fd3f[_0x71ab92] = _0x58367a;
        _0xecc4c7[msg.sender] = _0x72fcda;

        require(_0x5af0c7); // only allow registrations if contract is unlocked
    }
}
