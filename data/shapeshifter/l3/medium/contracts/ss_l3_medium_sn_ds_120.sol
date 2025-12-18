// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private _0x97deea;
  mapping(address => uint) public _0x99a8fe;

  function _0x07cf5c() public {
    for(uint i; i < _0x97deea.length; i++) {
      require(_0x97deea[i].transfer(_0x99a8fe[_0x97deea[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private _0x97deea;
  mapping(address => uint) public _0x99a8fe;

  function _0xe4f74b() external {
    uint _0xdab933 = _0x99a8fe[msg.sender];
    _0x99a8fe[msg.sender] = 0;
    msg.sender.transfer(_0xdab933);
  }
}

contract CrowdFundBatched {
  address[] private _0x97deea;
  mapping(address => uint) public _0x99a8fe;
  uint256 _0xe09b9c;

  function _0x5905e8() public {
    uint256 i = _0xe09b9c;
    while(i < _0x97deea.length && msg.gas > 200000) {
      _0x97deea[i].transfer(_0x99a8fe[i]);
      i++;
    }
    _0xe09b9c = i;
  }
}