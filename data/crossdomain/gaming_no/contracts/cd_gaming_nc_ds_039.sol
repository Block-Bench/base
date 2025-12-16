pragma solidity ^0.4.24;

contract ModifierItembank {
  mapping (address => uint) public questtokenGoldholding;
  string constant name = "Nu Token";


  function airDrop() hasNoGoldholding supportsGoldtoken  public{
    questtokenGoldholding[msg.sender] += 20;
  }


  modifier supportsGoldtoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == QuestBank(msg.sender).supportsGoldtoken());
    _;
  }

  modifier hasNoGoldholding {
      require(questtokenGoldholding[msg.sender] == 0);
      _;
  }
}

contract QuestBank{
    function supportsGoldtoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsGoldtoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierItembank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address realmCoin) public{
        ModifierItembank(realmCoin).airDrop();
    }
}