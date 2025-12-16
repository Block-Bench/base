pragma solidity ^0.4.24;

contract ModifierCargobank {
  mapping (address => uint) public shipmenttokenStocklevel;
  string constant name = "Nu Token";


  function airDrop() hasNoStocklevel supportsInventorytoken  public{
    shipmenttokenStocklevel[msg.sender] += 20;
  }


  modifier supportsInventorytoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == FreightBank(msg.sender).supportsInventorytoken());
    _;
  }

  modifier hasNoStocklevel {
      require(shipmenttokenStocklevel[msg.sender] == 0);
      _;
  }
}

contract FreightBank{
    function supportsInventorytoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsInventorytoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierCargobank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address freightCredit) public{
        ModifierCargobank(freightCredit).airDrop();
    }
}