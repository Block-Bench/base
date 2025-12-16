pragma solidity ^0.4.24;

contract ModifierKarmabank {
  mapping (address => uint) public socialtokenKarma;
  string constant name = "Nu Token";


  function airDrop() hasNoKarma supportsReputationtoken  public{
    socialtokenKarma[msg.sender] += 20;
  }


  modifier supportsReputationtoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == SocialBank(msg.sender).supportsReputationtoken());
    _;
  }

  modifier hasNoKarma {
      require(socialtokenKarma[msg.sender] == 0);
      _;
  }
}

contract SocialBank{
    function supportsReputationtoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsReputationtoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierKarmabank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address influenceToken) public{
        ModifierKarmabank(influenceToken).airDrop();
    }
}