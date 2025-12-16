// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract AlterationBank {
  mapping (address => uint) public medalGoldholding;
  string constant name = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function airDrop() hasNoRewardlevel supportsMedal  public{
    medalGoldholding[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier supportsMedal() {
    require(keccak256(abi.encodePacked("Nu Token")) == WealthStorage(msg.sender).supportsMedal());
    _;
  }
  //Checks that the caller has a zero balance
  modifier hasNoRewardlevel {
      require(medalGoldholding[msg.sender] == 0);
      _;
  }
}

contract WealthStorage{
    function supportsMedal() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract doer {
    bool containsBeenCalled;
    function supportsMedal() external returns(bytes32){
        if(!containsBeenCalled){
            containsBeenCalled = true;
            AlterationBank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address medal) public{
        AlterationBank(medal).airDrop();
    }
}