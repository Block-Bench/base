pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public _0xb0c8ef = false;

    struct NameRecord {
        bytes32 _0x37e6c5;
        address _0x9759f9;
    }

    mapping(address => NameRecord) public _0x8c98f5;
    mapping(bytes32 => address) public _0x562bda;

    function _0xcf5c90(bytes32 _0x5c6c7a, address _0xc3d10e) public {

        NameRecord _0x649a75;
        _0x649a75._0x37e6c5 = _0x5c6c7a;
        _0x649a75._0x9759f9 = _0xc3d10e;

        _0x562bda[_0x5c6c7a] = _0xc3d10e;
        _0x8c98f5[msg.sender] = _0x649a75;

        require(_0xb0c8ef);
    }
}