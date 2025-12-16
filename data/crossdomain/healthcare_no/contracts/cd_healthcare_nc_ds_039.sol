pragma solidity ^0.4.24;

contract ModifierBenefitbank {
  mapping (address => uint) public benefittokenBenefits;
  string constant name = "Nu Token";


  function airDrop() hasNoBenefits supportsCoveragetoken  public{
    benefittokenBenefits[msg.sender] += 20;
  }


  modifier supportsCoveragetoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == MedicalBank(msg.sender).supportsCoveragetoken());
    _;
  }

  modifier hasNoBenefits {
      require(benefittokenBenefits[msg.sender] == 0);
      _;
  }
}

contract MedicalBank{
    function supportsCoveragetoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsCoveragetoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierBenefitbank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address medicalCredit) public{
        ModifierBenefitbank(medicalCredit).airDrop();
    }
}