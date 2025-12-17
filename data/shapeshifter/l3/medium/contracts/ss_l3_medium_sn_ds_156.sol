// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

library SafeMath {

  function _0x962d6c(uint256 a, uint256 b) internal pure returns (uint256) {
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

  function _0xe01f95(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function _0xd44739(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function _0x580d02(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function _0xc910e0(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed from, address indexed _0x7a0f63, uint256 value );
  event Approval( address indexed _0xb88fd4, address indexed _0x238e95, uint256 value);
  using SafeMath for *;

  mapping (address => uint256) private _0x45c8db;

  mapping (address => mapping (address => uint256)) private _0xc85c2d;

  uint256 private _0x10474c;

  constructor(uint _0xe5bbeb){
    _0x45c8db[msg.sender] = _0xe5bbeb;
  }

  function _0x864887(address _0xb88fd4) public view returns (uint256) {
    return _0x45c8db[_0xb88fd4];
  }

  function _0x51b65b(address _0xb88fd4, address _0x238e95) public view returns (uint256)
  {
    return _0xc85c2d[_0xb88fd4][_0x238e95];
  }

  function transfer(address _0x7a0f63, uint256 value) public returns (bool) {
    require(value <= _0x45c8db[msg.sender]);
    require(_0x7a0f63 != address(0));

    _0x45c8db[msg.sender] = _0x45c8db[msg.sender]._0xd44739(value);
    _0x45c8db[_0x7a0f63] = _0x45c8db[_0x7a0f63]._0x580d02(value);
    emit Transfer(msg.sender, _0x7a0f63, value);
    return true;
  }
  function _0x2346d4(address _0x238e95, uint256 value) public returns (bool) {
    require(_0x238e95 != address(0));
    _0xc85c2d[msg.sender][_0x238e95] = value;
    emit Approval(msg.sender, _0x238e95, value);
    return true;
  }

  function _0xf9adc6(address from, address _0x7a0f63, uint256 value) public returns (bool) {
    require(value <= _0x45c8db[from]);
    require(value <= _0xc85c2d[from][msg.sender]);
    require(_0x7a0f63 != address(0));

    _0x45c8db[from] = _0x45c8db[from]._0xd44739(value);
    _0x45c8db[_0x7a0f63] = _0x45c8db[_0x7a0f63]._0x580d02(value);
    _0xc85c2d[from][msg.sender] = _0xc85c2d[from][msg.sender]._0xd44739(value);
    emit Transfer(from, _0x7a0f63, value);
    return true;
  }
}
