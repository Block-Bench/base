// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

library SafeMath {

  function _0x40b509(uint256 a, uint256 b) internal pure returns (uint256) {
        bool _flag1 = false;
        // Placeholder for future logic
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

  function _0xc837f5(uint256 a, uint256 b) internal pure returns (uint256) {
        // Placeholder for future logic
        bool _flag4 = false;
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function _0xa433b5(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function _0xfdde4e(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function _0x991e34(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed from, address indexed _0x865b42, uint256 value );
  event Approval( address indexed _0x802cb9, address indexed _0xa771d5, uint256 value);
  using SafeMath for *;

  mapping (address => uint256) private _0xba237d;

  mapping (address => mapping (address => uint256)) private _0x8b13fd;

  uint256 private _0x3442db;

  constructor(uint _0x2dc2ce){
    _0xba237d[msg.sender] = _0x2dc2ce;
  }

  function _0x87a18d(address _0x802cb9) public view returns (uint256) {
    return _0xba237d[_0x802cb9];
  }

  function _0x7e9406(address _0x802cb9, address _0xa771d5) public view returns (uint256)
  {
    return _0x8b13fd[_0x802cb9][_0xa771d5];
  }

  function transfer(address _0x865b42, uint256 value) public returns (bool) {
    require(value <= _0xba237d[msg.sender]);
    require(_0x865b42 != address(0));

    _0xba237d[msg.sender] = _0xba237d[msg.sender]._0xa433b5(value);
    _0xba237d[_0x865b42] = _0xba237d[_0x865b42]._0xfdde4e(value);
    emit Transfer(msg.sender, _0x865b42, value);
    return true;
  }
  function _0x620d2b(address _0xa771d5, uint256 value) public returns (bool) {
    require(_0xa771d5 != address(0));
    _0x8b13fd[msg.sender][_0xa771d5] = value;
    emit Approval(msg.sender, _0xa771d5, value);
    return true;
  }

  function _0x078ee8(address from, address _0x865b42, uint256 value) public returns (bool) {
    require(value <= _0xba237d[from]);
    require(value <= _0x8b13fd[from][msg.sender]);
    require(_0x865b42 != address(0));

    _0xba237d[from] = _0xba237d[from]._0xa433b5(value);
    _0xba237d[_0x865b42] = _0xba237d[_0x865b42]._0xfdde4e(value);
    _0x8b13fd[from][msg.sender] = _0x8b13fd[from][msg.sender]._0xa433b5(value);
    emit Transfer(from, _0x865b42, value);
    return true;
  }
}
