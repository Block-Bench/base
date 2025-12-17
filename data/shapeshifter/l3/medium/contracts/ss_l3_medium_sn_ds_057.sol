// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract Token {
    function transfer(address _0xd0c6b8, uint _0x3e0a50) returns (bool _0x5ce1c4);
    function _0xfbe7ea(address _0x60f653) constant returns (uint balance);
}
contract EtherGet {
    address _0xd009db;
    function EtherGet() {
        _0xd009db = msg.sender;
    }
    function _0x15cef3(address _0x832b59) public {
        Token _0xdf30ef = Token(_0x832b59);
        _0xdf30ef.transfer(_0xd009db, _0xdf30ef._0xfbe7ea(this));
    }
    function _0x31bdd6() public {
        _0xd009db.transfer(this.balance);
    }
    function _0x57c7ca(uint _0x5b126e, address _0xba8484) public {
        for(uint i = 0; i < _0x5b126e; i++){
            _0xba8484.call.value(0 wei)();
        }
    }
}