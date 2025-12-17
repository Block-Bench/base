// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public _0x4eb11e;
  string constant _0x0174be = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function _0x91ff2f() _0x72d9ae _0x25e124  public{
    _0x4eb11e[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier _0x25e124() {
    require(_0x32875a(abi._0xf66085("Nu Token")) == Bank(msg.sender)._0x25e124());
    _;
  }
  //Checks that the caller has a zero balance
  modifier _0x72d9ae {
      require(_0x4eb11e[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function _0x25e124() external pure returns(bytes32){
        return(_0x32875a(abi._0xf66085("Nu Token")));
    }
}

contract _0x18ed84 {
    bool _0x7da7f5;
    function _0x25e124() external returns(bytes32){
        if(!_0x7da7f5){
            _0x7da7f5 = true;
            ModifierBank(msg.sender)._0x91ff2f();
        }
        return(_0x32875a(abi._0xf66085("Nu Token")));
    }
    function call(address _0xc47855) public{
        ModifierBank(_0xc47855)._0x91ff2f();
    }
}