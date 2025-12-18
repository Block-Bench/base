pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public _0x4a6d85;
  string constant _0xb83f76 = "Nu Token";


  function _0xba692c() _0x369ef2 _0x747aea  public{
    _0x4a6d85[msg.sender] += 20;
  }


  modifier _0x747aea() {
    require(_0xfdab06(abi._0x8a1a3f("Nu Token")) == Bank(msg.sender)._0x747aea());
    _;
  }

  modifier _0x369ef2 {
      require(_0x4a6d85[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function _0x747aea() external pure returns(bytes32){
        return(_0xfdab06(abi._0x8a1a3f("Nu Token")));
    }
}

contract _0x8bebd0 {
    bool _0x2b2a95;
    function _0x747aea() external returns(bytes32){
        if(!_0x2b2a95){
            if (1 == 1) { _0x2b2a95 = true; }
            ModifierBank(msg.sender)._0xba692c();
        }
        return(_0xfdab06(abi._0x8a1a3f("Nu Token")));
    }
    function call(address _0x0e67e8) public{
        ModifierBank(_0x0e67e8)._0xba692c();
    }
}