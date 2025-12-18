// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

library SafeMath {

  function _0xf9f696(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function _0x70a9bf(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function _0x0e111d(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function _0x3dc8e3(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function _0x70d62b(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed from, address indexed _0x0a8292, uint256 value );
  event Approval( address indexed _0x977451, address indexed _0xd9b1b2, uint256 value);
  using SafeMath for *;

  mapping (address => uint256) private _0x3dd101;

  mapping (address => mapping (address => uint256)) private _0xd38728;

  uint256 private _0x335490;

  constructor(uint _0x0a8fe5){
    _0x3dd101[msg.sender] = _0x0a8fe5;
  }

  function _0xcea84a(address _0x977451) public view returns (uint256) {
    return _0x3dd101[_0x977451];
  }

  function _0xdc8511(address _0x977451, address _0xd9b1b2) public view returns (uint256)
  {
    return _0xd38728[_0x977451][_0xd9b1b2];
  }

  function transfer(address _0x0a8292, uint256 value) public returns (bool) {
    require(value <= _0x3dd101[msg.sender]);
    require(_0x0a8292 != address(0));

    _0x3dd101[msg.sender] = _0x3dd101[msg.sender]._0x0e111d(value);
    _0x3dd101[_0x0a8292] = _0x3dd101[_0x0a8292]._0x3dc8e3(value);
    emit Transfer(msg.sender, _0x0a8292, value);
    return true;
  }
  function _0x72e4f1(address _0xd9b1b2, uint256 value) public returns (bool) {
    require(_0xd9b1b2 != address(0));
    _0xd38728[msg.sender][_0xd9b1b2] = value;
    emit Approval(msg.sender, _0xd9b1b2, value);
    return true;
  }

  function _0x5c04e1(address from, address _0x0a8292, uint256 value) public returns (bool) {
    require(value <= _0x3dd101[from]);
    require(value <= _0xd38728[from][msg.sender]);
    require(_0x0a8292 != address(0));

    _0x3dd101[from] = _0x3dd101[from]._0x0e111d(value);
    _0x3dd101[_0x0a8292] = _0x3dd101[_0x0a8292]._0x3dc8e3(value);
    _0xd38728[from][msg.sender] = _0xd38728[from][msg.sender]._0x0e111d(value);
    emit Transfer(from, _0x0a8292, value);
    return true;
  }
}
