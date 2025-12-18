pragma solidity ^0.4.24;

contract ModifierBank {
  mapping (address => uint) public _0x011f19;
  string constant _0xe2eb3f = "Nu Token";


  function _0xa579cc() _0x5e24cb _0x397d4a  public{
    _0x011f19[msg.sender] += 20;
  }


  modifier _0x397d4a() {
    require(_0x74d823(abi._0x30399b("Nu Token")) == Bank(msg.sender)._0x397d4a());
    _;
  }

  modifier _0x5e24cb {
      require(_0x011f19[msg.sender] == 0);
      _;
  }
}

contract Bank{
    function _0x397d4a() external pure returns(bytes32){
        return(_0x74d823(abi._0x30399b("Nu Token")));
    }
}

contract _0x91ec48 {
    bool _0x38b58d;
    function _0x397d4a() external returns(bytes32){
        if(!_0x38b58d){
            _0x38b58d = true;
            ModifierBank(msg.sender)._0xa579cc();
        }
        return(_0x74d823(abi._0x30399b("Nu Token")));
    }
    function call(address _0xfcc1c8) public{
        ModifierBank(_0xfcc1c8)._0xa579cc();
    }
}