pragma solidity ^0.4.24;

contract RestrictedHealthAccount {
  mapping (address => uint) public credentialAccountcredits;
  string constant name = "Nu Token";


  function airDrop() hasNoCredits supportsCredential  public{
    credentialAccountcredits[msg.sender] += 20;
  }


  modifier supportsCredential() {
    require(keccak256(abi.encodePacked("Nu Token")) == MedicationBank(msg.sender).supportsCredential());
    _;
  }

  modifier hasNoCredits {
      require(credentialAccountcredits[msg.sender] == 0);
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
            RestrictedHealthAccount(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address credential) public{
        RestrictedHealthAccount(credential).airDrop();
    }
}