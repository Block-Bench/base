// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public _0x1405e9;
  string constant _0x363efd = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function _0xe0d4fe() _0x57bce8 _0x0f7379  public{
    _0x1405e9[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier _0x0f7379() {
    require(_0xd9cfb4(abi._0xdaf9ba("Nu Token")) == Bank(msg.sender)._0x0f7379());
    _;
  }
  //Checks that the caller has a zero balance
  modifier _0x57bce8 {
      require(_0x1405e9[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function _0x0f7379() external pure returns(bytes32){
        return(_0xd9cfb4(abi._0xdaf9ba("Nu Token")));
    }
}

contract _0x1f51cf {
    bool _0xc19854;
    function _0x0f7379() external returns(bytes32){
        if(!_0xc19854){
            _0xc19854 = true;
            ModifierBank(msg.sender)._0xe0d4fe();
        }
        return(_0xd9cfb4(abi._0xdaf9ba("Nu Token")));
    }
    function call(address _0xe4f8f3) public{
        ModifierBank(_0xe4f8f3)._0xe0d4fe();
    }
}