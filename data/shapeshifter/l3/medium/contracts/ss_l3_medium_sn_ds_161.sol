pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public _0xb4d78a = false;  // registrar locked, no name updates

    struct NameRecord { // map hashes to addresses
        bytes32 _0xda383f;
        address _0x395a02;
    }

    mapping(address => NameRecord) public _0x3704bc; // records who registered names
    mapping(bytes32 => address) public _0x30155e; // resolves hashes to addresses

    function _0x7188d1(bytes32 _0x70a40b, address _0x9c7fca) public {
        // set up the new NameRecord
        NameRecord _0xbbf05d;
        _0xbbf05d._0xda383f = _0x70a40b;
        _0xbbf05d._0x395a02 = _0x9c7fca;

        _0x30155e[_0x70a40b] = _0x9c7fca;
        _0x3704bc[msg.sender] = _0xbbf05d;

        require(_0xb4d78a); // only allow registrations if contract is unlocked
    }
}
