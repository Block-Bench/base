pragma solidity ^0.4.24;

library SafeMath {

  function _0x2dce2e(uint256 a, uint256 b) internal pure returns (uint256) {


    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function _0x310d8b(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;


    return c;
  }

  function _0xb504a8(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function _0x76eff0(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function _0x5884d0(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed from, address indexed _0x897e5d, uint256 value );
  event Approval( address indexed _0x4c71fc, address indexed _0x98081a, uint256 value);
  using SafeMath for *;

  mapping (address => uint256) private _0x862992;

  mapping (address => mapping (address => uint256)) private _0xdbd55b;

  uint256 private _0xcaf75d;

  constructor(uint _0xedf69e){
    _0x862992[msg.sender] = _0xedf69e;
  }

  function _0x22e5cf(address _0x4c71fc) public view returns (uint256) {
    return _0x862992[_0x4c71fc];
  }

  function _0xe7dd42(address _0x4c71fc, address _0x98081a) public view returns (uint256)
  {
    return _0xdbd55b[_0x4c71fc][_0x98081a];
  }

  function transfer(address _0x897e5d, uint256 value) public returns (bool) {
    require(value <= _0x862992[msg.sender]);
    require(_0x897e5d != address(0));

    _0x862992[msg.sender] = _0x862992[msg.sender]._0xb504a8(value);
    _0x862992[_0x897e5d] = _0x862992[_0x897e5d]._0x76eff0(value);
    emit Transfer(msg.sender, _0x897e5d, value);
    return true;
  }
  function _0x841948(address _0x98081a, uint256 value) public returns (bool) {
    require(_0x98081a != address(0));
    _0xdbd55b[msg.sender][_0x98081a] = value;
    emit Approval(msg.sender, _0x98081a, value);
    return true;
  }

  function _0x2451dd(address from, address _0x897e5d, uint256 value) public returns (bool) {
    require(value <= _0x862992[from]);
    require(value <= _0xdbd55b[from][msg.sender]);
    require(_0x897e5d != address(0));

    _0x862992[from] = _0x862992[from]._0xb504a8(value);
    _0x862992[_0x897e5d] = _0x862992[_0x897e5d]._0x76eff0(value);
    _0xdbd55b[from][msg.sender] = _0xdbd55b[from][msg.sender]._0xb504a8(value);
    emit Transfer(from, _0x897e5d, value);
    return true;
  }
}