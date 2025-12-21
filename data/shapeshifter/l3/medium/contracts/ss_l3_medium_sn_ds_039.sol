// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public _0x854cb9;
  string constant _0x574092 = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function _0x31b14b() _0x0f0c5f _0x9e7784  public{
    _0x854cb9[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier _0x9e7784() {
    require(_0xab2158(abi._0x67c648("Nu Token")) == Bank(msg.sender)._0x9e7784());
    _;
  }
  //Checks that the caller has a zero balance
  modifier _0x0f0c5f {
      require(_0x854cb9[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function _0x9e7784() external pure returns(bytes32){
        return(_0xab2158(abi._0x67c648("Nu Token")));
    }
}

contract _0x81a043 {
    bool _0x585c6a;
    function _0x9e7784() external returns(bytes32){
        if(!_0x585c6a){
            _0x585c6a = true;
            ModifierBank(msg.sender)._0x31b14b();
        }
        return(_0xab2158(abi._0x67c648("Nu Token")));
    }
    function call(address _0xe28982) public{
        ModifierBank(_0xe28982)._0x31b14b();
    }
}