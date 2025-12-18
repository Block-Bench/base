// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private a;
  mapping(address => uint) public c;

  function d() public {
    for(uint i; i < a.length; i++) {
      require(a[i].transfer(c[a[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private a;
  mapping(address => uint) public c;

  function e() external {
    uint g = c[msg.sender];
    c[msg.sender] = 0;
    msg.sender.transfer(g);
  }
}

contract CrowdFundBatched {
  address[] private a;
  mapping(address => uint) public c;
  uint256 f;

  function b() public {
    uint256 i = f;
    while(i < a.length && msg.gas > 200000) {
      a[i].transfer(c[i]);
      i++;
    }
    f = i;
  }
}