pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public _0xb34509 = false;  // registrar locked, no name updates

    struct NameRecord { // map hashes to addresses
        bytes32 _0xdd4699;
        address _0xd3b442;
    }

    mapping(address => NameRecord) public _0x16b7cd; // records who registered names
    mapping(bytes32 => address) public _0x819ec4; // resolves hashes to addresses

    function _0x67431e(bytes32 _0x832a8b, address _0x1caf36) public {
        // set up the new NameRecord
        NameRecord _0x8795f7;
        _0x8795f7._0xdd4699 = _0x832a8b;
        _0x8795f7._0xd3b442 = _0x1caf36;

        _0x819ec4[_0x832a8b] = _0x1caf36;
        _0x16b7cd[msg.sender] = _0x8795f7;

        require(_0xb34509); // only allow registrations if contract is unlocked
    }
}
