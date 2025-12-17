// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private _0xa9af32;
  mapping(address => uint) public _0xc80518;

  function _0xecff69() public {
    for(uint i; i < _0xa9af32.length; i++) {
      require(_0xa9af32[i].transfer(_0xc80518[_0xa9af32[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private _0xa9af32;
  mapping(address => uint) public _0xc80518;

  function _0x4b9285() external {
    uint _0x5944e3 = _0xc80518[msg.sender];
    _0xc80518[msg.sender] = 0;
    msg.sender.transfer(_0x5944e3);
  }
}

contract CrowdFundSafe {
  address[] private _0xa9af32;
  mapping(address => uint) public _0xc80518;
  uint256 _0xc4e18b;

  function _0xcb7aae() public {
    uint256 i = _0xc4e18b;
    while(i < _0xa9af32.length && msg.gas > 200000) {
      _0xa9af32[i].transfer(_0xc80518[i]);
      i++;
    }
    _0xc4e18b = i;
  }
}