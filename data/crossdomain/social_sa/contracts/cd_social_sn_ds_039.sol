// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierKarmabank {
  mapping (address => uint) public influencetokenInfluence;
  string constant name = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function airDrop() hasNoStanding supportsSocialtoken  public{
    influencetokenInfluence[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier supportsSocialtoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == KarmaBank(msg.sender).supportsSocialtoken());
    _;
  }
  //Checks that the caller has a zero balance
  modifier hasNoStanding {
      require(influencetokenInfluence[msg.sender] == 0);
      _;
  }
}

contract KarmaBank{
    function supportsSocialtoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsSocialtoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierKarmabank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address socialToken) public{
        ModifierKarmabank(socialToken).airDrop();
    }
}