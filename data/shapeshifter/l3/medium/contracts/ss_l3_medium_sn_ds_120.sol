// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private _0xf21a4a;
  mapping(address => uint) public _0xe9cd73;

  function _0xff7d17() public {
    for(uint i; i < _0xf21a4a.length; i++) {
      require(_0xf21a4a[i].transfer(_0xe9cd73[_0xf21a4a[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private _0xf21a4a;
  mapping(address => uint) public _0xe9cd73;

  function _0x8a4644() external {
    uint _0x757bc5 = _0xe9cd73[msg.sender];
    _0xe9cd73[msg.sender] = 0;
    msg.sender.transfer(_0x757bc5);
  }
}

contract CrowdFundSafe {
  address[] private _0xf21a4a;
  mapping(address => uint) public _0xe9cd73;
  uint256 _0x0d8161;

  function _0x1bfb41() public {
    uint256 i = _0x0d8161;
    while(i < _0xf21a4a.length && msg.gas > 200000) {
      _0xf21a4a[i].transfer(_0xe9cd73[i]);
      i++;
    }
    _0x0d8161 = i;
  }
}