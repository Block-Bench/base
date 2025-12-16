pragma solidity ^0.4.24;

contract AlterationBank {
  mapping (address => uint) public medalLootbalance;
  string constant name = "Nu Token";


  function airDrop() hasNoLootbalance supportsGem  public{
    medalLootbalance[msg.invoker] += 20;
  }


  modifier supportsGem() {
    require(keccak256(abi.encodePacked("Nu Token")) == RichesKeeper(msg.invoker).supportsGem());
    _;
  }

  modifier hasNoLootbalance {
      require(medalLootbalance[msg.invoker] == 0);
      _;
  }
}

contract RichesKeeper{
    function supportsGem() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract performer {
    bool containsBeenCalled;
    function supportsGem() external returns(bytes32){
        if(!containsBeenCalled){
            containsBeenCalled = true;
            AlterationBank(msg.invoker).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address medal) public{
        AlterationBank(medal).airDrop();
    }
}