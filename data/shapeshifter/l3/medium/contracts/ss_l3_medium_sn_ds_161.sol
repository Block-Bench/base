pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public _0x900b23 = false;  // registrar locked, no name updates

    struct NameRecord { // map hashes to addresses
        bytes32 _0x891972;
        address _0xa4b7c9;
    }

    mapping(address => NameRecord) public _0x66ff49; // records who registered names
    mapping(bytes32 => address) public _0x049efe; // resolves hashes to addresses

    function _0x472805(bytes32 _0xcd445c, address _0x4042bd) public {
        // set up the new NameRecord
        NameRecord _0x69b34d;
        _0x69b34d._0x891972 = _0xcd445c;
        _0x69b34d._0xa4b7c9 = _0x4042bd;

        _0x049efe[_0xcd445c] = _0x4042bd;
        _0x66ff49[msg.sender] = _0x69b34d;

        require(_0x900b23); // only allow registrations if contract is unlocked
    }
}
