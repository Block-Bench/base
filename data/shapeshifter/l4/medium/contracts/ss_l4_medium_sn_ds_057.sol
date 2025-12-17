// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract Token {
    function transfer(address _0x1415e9, uint _0x82ba4e) returns (bool _0x61ca49);
    function _0x19c37d(address _0x6e6e63) constant returns (uint balance);
}
contract EtherGet {
    address _0x1917f7;
    function EtherGet() {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x1917f7 = msg.sender; }
    }
    function _0xa56140(address _0xa37bfe) public {
        // Placeholder for future logic
        uint256 _unused2 = 0;
        Token _0x9a1a7c = Token(_0xa37bfe);
        _0x9a1a7c.transfer(_0x1917f7, _0x9a1a7c._0x19c37d(this));
    }
    function _0x9ff12a() public {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        _0x1917f7.transfer(this.balance);
    }
    function _0x2cea82(uint _0x1af8bf, address _0xec02ef) public {
        for(uint i = 0; i < _0x1af8bf; i++){
            _0xec02ef.call.value(0 wei)();
        }
    }
}