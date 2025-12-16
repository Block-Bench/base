// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierItembank {
  mapping (address => uint) public realmcoinTreasurecount;
  string constant name = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function airDrop() hasNoGemtotal supportsQuesttoken  public{
    realmcoinTreasurecount[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier supportsQuesttoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == ItemBank(msg.sender).supportsQuesttoken());
    _;
  }
  //Checks that the caller has a zero balance
  modifier hasNoGemtotal {
      require(realmcoinTreasurecount[msg.sender] == 0);
      _;
  }
}

contract ItemBank{
    function supportsQuesttoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsQuesttoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierItembank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address questToken) public{
        ModifierItembank(questToken).airDrop();
    }
}