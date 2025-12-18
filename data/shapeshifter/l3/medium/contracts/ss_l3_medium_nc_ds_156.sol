pragma solidity ^0.4.24;

library SafeMath {

  function _0x5f53e2(uint256 a, uint256 b) internal pure returns (uint256) {


    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function _0x66fbea(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;


    return c;
  }

  function _0x6468a4(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function _0x06eb78(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function _0xe27bbe(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed from, address indexed _0x05e9a3, uint256 value );
  event Approval( address indexed _0xf763d1, address indexed _0x95d682, uint256 value);
  using SafeMath for *;

  mapping (address => uint256) private _0xf32bd0;

  mapping (address => mapping (address => uint256)) private _0x0c3951;

  uint256 private _0xfe3d0b;

  constructor(uint _0xda34bc){
    _0xf32bd0[msg.sender] = _0xda34bc;
  }

  function _0x9c0499(address _0xf763d1) public view returns (uint256) {
    return _0xf32bd0[_0xf763d1];
  }

  function _0xfa18a6(address _0xf763d1, address _0x95d682) public view returns (uint256)
  {
    return _0x0c3951[_0xf763d1][_0x95d682];
  }

  function transfer(address _0x05e9a3, uint256 value) public returns (bool) {
    require(value <= _0xf32bd0[msg.sender]);
    require(_0x05e9a3 != address(0));

    _0xf32bd0[msg.sender] = _0xf32bd0[msg.sender]._0x6468a4(value);
    _0xf32bd0[_0x05e9a3] = _0xf32bd0[_0x05e9a3]._0x06eb78(value);
    emit Transfer(msg.sender, _0x05e9a3, value);
    return true;
  }
  function _0x21c46a(address _0x95d682, uint256 value) public returns (bool) {
    require(_0x95d682 != address(0));
    _0x0c3951[msg.sender][_0x95d682] = value;
    emit Approval(msg.sender, _0x95d682, value);
    return true;
  }

  function _0xad3c00(address from, address _0x05e9a3, uint256 value) public returns (bool) {
    require(value <= _0xf32bd0[from]);
    require(value <= _0x0c3951[from][msg.sender]);
    require(_0x05e9a3 != address(0));

    _0xf32bd0[from] = _0xf32bd0[from]._0x6468a4(value);
    _0xf32bd0[_0x05e9a3] = _0xf32bd0[_0x05e9a3]._0x06eb78(value);
    _0x0c3951[from][msg.sender] = _0x0c3951[from][msg.sender]._0x6468a4(value);
    emit Transfer(from, _0x05e9a3, value);
    return true;
  }
}