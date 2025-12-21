pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private _0x54528d;
  mapping(address => uint) public _0x0799c3;

  function _0x9d7442() public {
    for(uint i; i < _0x54528d.length; i++) {
      require(_0x54528d[i].transfer(_0x0799c3[_0x54528d[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private _0x54528d;
  mapping(address => uint) public _0x0799c3;

  function _0xf5766a() external {
    uint _0xb0a34e = _0x0799c3[msg.sender];
    _0x0799c3[msg.sender] = 0;
    msg.sender.transfer(_0xb0a34e);
  }
}

contract CrowdFundBatched {
  address[] private _0x54528d;
  mapping(address => uint) public _0x0799c3;
  uint256 _0xc489bd;

  function _0x8f4a73() public {
    uint256 i = _0xc489bd;
    while(i < _0x54528d.length && msg.gas > 200000) {
      _0x54528d[i].transfer(_0x0799c3[i]);
      i++;
    }
    _0xc489bd = i;
  }
}