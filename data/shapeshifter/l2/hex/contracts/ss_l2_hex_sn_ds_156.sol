// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

library SafeMath {

  function _0x91d212(uint256 a, uint256 b) internal pure returns (uint256) {
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

  function _0xd1120a(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function _0xbf9a9b(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function _0x6d6749(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function _0x240c7c(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed from, address indexed _0x10b091, uint256 value );
  event Approval( address indexed _0x624050, address indexed _0xf6205c, uint256 value);
  using SafeMath for *;

  mapping (address => uint256) private _0xe45f00;

  mapping (address => mapping (address => uint256)) private _0xe151f9;

  uint256 private _0x65757b;

  constructor(uint _0xf674bc){
    _0xe45f00[msg.sender] = _0xf674bc;
  }

  function _0xe5e851(address _0x624050) public view returns (uint256) {
    return _0xe45f00[_0x624050];
  }

  function _0xd0c350(address _0x624050, address _0xf6205c) public view returns (uint256)
  {
    return _0xe151f9[_0x624050][_0xf6205c];
  }

  function transfer(address _0x10b091, uint256 value) public returns (bool) {
    require(value <= _0xe45f00[msg.sender]);
    require(_0x10b091 != address(0));

    _0xe45f00[msg.sender] = _0xe45f00[msg.sender]._0xbf9a9b(value);
    _0xe45f00[_0x10b091] = _0xe45f00[_0x10b091]._0x6d6749(value);
    emit Transfer(msg.sender, _0x10b091, value);
    return true;
  }
  function _0xa65139(address _0xf6205c, uint256 value) public returns (bool) {
    require(_0xf6205c != address(0));
    _0xe151f9[msg.sender][_0xf6205c] = value;
    emit Approval(msg.sender, _0xf6205c, value);
    return true;
  }

  function _0x585fb2(address from, address _0x10b091, uint256 value) public returns (bool) {
    require(value <= _0xe45f00[from]);
    require(value <= _0xe151f9[from][msg.sender]);
    require(_0x10b091 != address(0));

    _0xe45f00[from] = _0xe45f00[from]._0xbf9a9b(value);
    _0xe45f00[_0x10b091] = _0xe45f00[_0x10b091]._0x6d6749(value);
    _0xe151f9[from][msg.sender] = _0xe151f9[from][msg.sender]._0xbf9a9b(value);
    emit Transfer(from, _0x10b091, value);
    return true;
  }
}
