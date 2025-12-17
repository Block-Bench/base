// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract Token {
    function transfer(address _0xc8b27c, uint _0xd8e467) returns (bool _0x260c72);
    function _0x606d87(address _0x5267a4) constant returns (uint balance);
}
contract EtherGet {
    address _0xb22b6b;
    function EtherGet() {
        _0xb22b6b = msg.sender;
    }
    function _0x64957c(address _0x563967) public {
        Token _0x2f075a = Token(_0x563967);
        _0x2f075a.transfer(_0xb22b6b, _0x2f075a._0x606d87(this));
    }
    function _0xf9782e() public {
        _0xb22b6b.transfer(this.balance);
    }
    function _0x92e6c5(uint _0x5a385f, address _0x1bfb69) public {
        for(uint i = 0; i < _0x5a385f; i++){
            _0x1bfb69.call.value(0 wei)();
        }
    }
}