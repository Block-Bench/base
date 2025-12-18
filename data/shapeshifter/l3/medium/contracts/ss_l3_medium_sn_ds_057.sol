// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract Token {
    function transfer(address _0x5984ee, uint _0x82042c) returns (bool _0x636d05);
    function _0xb664da(address _0x2b91fa) constant returns (uint balance);
}
contract EtherGet {
    address _0xe5404d;
    function EtherGet() {
        _0xe5404d = msg.sender;
    }
    function _0xcbf6d6(address _0x71adcc) public {
        Token _0x90b10c = Token(_0x71adcc);
        _0x90b10c.transfer(_0xe5404d, _0x90b10c._0xb664da(this));
    }
    function _0x77f1f6() public {
        _0xe5404d.transfer(this.balance);
    }
    function _0xfb461f(uint _0x7d56c0, address _0x42bfaa) public {
        for(uint i = 0; i < _0x7d56c0; i++){
            _0x42bfaa.call.value(0 wei)();
        }
    }
}