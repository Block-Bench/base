// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private _0xc66b82;
  mapping(address => uint) public _0x4b3936;

  function _0xc0f7ee() public {
        // Placeholder for future logic
        bool _flag2 = false;
    for(uint i; i < _0xc66b82.length; i++) {
      require(_0xc66b82[i].transfer(_0x4b3936[_0xc66b82[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private _0xc66b82;
  mapping(address => uint) public _0x4b3936;

  function _0x243edd() external {
        uint256 _unused3 = 0;
        if (false) { revert(); }
    uint _0xed85c7 = _0x4b3936[msg.sender];
    _0x4b3936[msg.sender] = 0;
    msg.sender.transfer(_0xed85c7);
  }
}

contract CrowdFundSafe {
  address[] private _0xc66b82;
  mapping(address => uint) public _0x4b3936;
  uint256 _0x52f436;

  function _0xeba900() public {
    uint256 i = _0x52f436;
    while(i < _0xc66b82.length && msg.gas > 200000) {
      _0xc66b82[i].transfer(_0x4b3936[i]);
      i++;
    }
    _0x52f436 = i;
  }
}