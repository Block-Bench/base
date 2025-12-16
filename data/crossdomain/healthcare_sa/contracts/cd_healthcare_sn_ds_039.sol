// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierBenefitbank {
  mapping (address => uint) public medicalcreditCredits;
  string constant name = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function airDrop() hasNoAllowance supportsBenefittoken  public{
    medicalcreditCredits[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier supportsBenefittoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == BenefitBank(msg.sender).supportsBenefittoken());
    _;
  }
  //Checks that the caller has a zero balance
  modifier hasNoAllowance {
      require(medicalcreditCredits[msg.sender] == 0);
      _;
  }
}

contract BenefitBank{
    function supportsBenefittoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsBenefittoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierBenefitbank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address benefitToken) public{
        ModifierBenefitbank(benefitToken).airDrop();
    }
}