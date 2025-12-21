pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public tokenBalance;
  string constant name = "Nu Token";


  function airDrop() hasNoBalance supportsToken  public{
    tokenBalance[msg.sender] += 20;
  }


  modifier supportsToken() {
    require(keccak256(abi.encodePacked("Nu Token")) == Bank(msg.sender).supportsToken());
    _;
  }

  modifier hasNoBalance {
      require(tokenBalance[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function supportsToken() external pure returns(bytes32){
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract executor {
    bool hasBeenCalled;
    function supportsToken() external returns(bytes32){
        if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierBank(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address token) public{
        ModifierBank(token).airDrop();
    }

    // Unified dispatcher - merged from: airDrop, supportsToken, call
    // Selectors: airDrop=0, supportsToken=1, call=2
    function execute(uint8 _selector, address token) public {
        // Original: airDrop()
        if (_selector == 0) {
            tokenBalance[msg.sender] += 20;
        }
        // Original: supportsToken()
        else if (_selector == 1) {
            if(!hasBeenCalled){
            hasBeenCalled = true;
            ModifierBank(msg.sender).airDrop();
            }
            return(keccak256(abi.encodePacked("Nu Token")));
        }
        // Original: call()
        else if (_selector == 2) {
            ModifierBank(token).airDrop();
        }
    }
}