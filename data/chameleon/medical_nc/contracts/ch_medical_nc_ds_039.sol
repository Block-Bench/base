pragma solidity ^0.4.24;

contract AlterationBank {
  mapping (address => uint) public credentialAllocation;
  string constant name = "Nu Token";


  function airDrop() hasNoBenefits supportsCredential  public{
    credentialAllocation[msg.sender] += 20;
  }


  modifier supportsCredential() {
    require(keccak256(abi.encodePacked("Nu Token")) == MedicationBank(msg.sender).supportsCredential());
    _;
  }

  modifier hasNoBenefits {
      require(credentialAllocation[msg.sender] == 0);
      _;
  }
}

contract MedicationBank{
    function supportsCredential() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract administrator {
    bool holdsBeenCalled;
    function supportsCredential() external returns(bytes32){
        if(!holdsBeenCalled){
            holdsBeenCalled = true;
            AlterationBank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address badge) public{
        AlterationBank(badge).airDrop();
    }
}