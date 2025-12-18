// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public d;
  string constant j = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function h() c a  public{
    d[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier a() {
    require(f(abi.e("Nu Token")) == Bank(msg.sender).a());
    _;
  }
  //Checks that the caller has a zero balance
  modifier c {
      require(d[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function a() external pure returns(bytes32){
        return(f(abi.e("Nu Token")));
    }
}

contract g {
    bool b;
    function a() external returns(bytes32){
        if(!b){
            b = true;
            ModifierBank(msg.sender).h();
        }
        return(f(abi.e("Nu Token")));
    }
    function call(address i) public{
        ModifierBank(i).h();
    }
}