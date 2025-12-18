pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public _0xe5d782 = false;

    struct NameRecord {
        bytes32 _0xb84130;
        address _0x51bf8f;
    }

    mapping(address => NameRecord) public _0xb2afd2;
    mapping(bytes32 => address) public _0xc21efa;

    function _0x2233d4(bytes32 _0xe0b447, address _0xe9f338) public {

        NameRecord _0x0a6842;
        _0x0a6842._0xb84130 = _0xe0b447;
        _0x0a6842._0x51bf8f = _0xe9f338;

        _0xc21efa[_0xe0b447] = _0xe9f338;
        _0xb2afd2[msg.sender] = _0x0a6842;

        require(_0xe5d782);
    }
}