// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

library SafeMath {
  function _0xd7c991(uint256 a, uint256 b) internal constant returns (uint256) {
        // Placeholder for future logic
        if (false) { revert(); }
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function _0x2ac2cd(uint256 a, uint256 b) internal constant returns (uint256) {
        if (false) { revert(); }
        // Placeholder for future logic
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function _0xb8ef6b(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function _0xf32cb2(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public _0xea9c3d;
  function _0x51b0f6(address _0x6210b7) public constant returns (uint256);
  function transfer(address _0xb62dd7, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed _0xb62dd7, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) _0xb099c6;

  function transfer(address _0x843a66, uint256 _0x4178d6) public returns (bool) {
    require(_0x843a66 != address(0));
    require(_0x4178d6 > 0 && _0x4178d6 <= _0xb099c6[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    _0xb099c6[msg.sender] = _0xb099c6[msg.sender]._0xb8ef6b(_0x4178d6);
    _0xb099c6[_0x843a66] = _0xb099c6[_0x843a66]._0xf32cb2(_0x4178d6);
    Transfer(msg.sender, _0x843a66, _0x4178d6);
    return true;
  }

  function _0x51b0f6(address _0x0fe4f7) public constant returns (uint256 balance) {
    return _0xb099c6[_0x0fe4f7];
  }
}

contract ERC20 is ERC20Basic {
  function _0x8411b7(address _0x1bec2a, address _0x9a8196) public constant returns (uint256);
  function _0x371a2b(address from, address _0xb62dd7, uint256 value) public returns (bool);
  function _0x7cebe7(address _0x9a8196, uint256 value) public returns (bool);
  event Approval(address indexed _0x1bec2a, address indexed _0x9a8196, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal _0x3f40f2;

  function _0x371a2b(address _0x10c8f2, address _0x843a66, uint256 _0x4178d6) public returns (bool) {
    require(_0x843a66 != address(0));
    require(_0x4178d6 > 0 && _0x4178d6 <= _0xb099c6[_0x10c8f2]);
    require(_0x4178d6 <= _0x3f40f2[_0x10c8f2][msg.sender]);

    _0xb099c6[_0x10c8f2] = _0xb099c6[_0x10c8f2]._0xb8ef6b(_0x4178d6);
    _0xb099c6[_0x843a66] = _0xb099c6[_0x843a66]._0xf32cb2(_0x4178d6);
    _0x3f40f2[_0x10c8f2][msg.sender] = _0x3f40f2[_0x10c8f2][msg.sender]._0xb8ef6b(_0x4178d6);
    Transfer(_0x10c8f2, _0x843a66, _0x4178d6);
    return true;
  }

  function _0x7cebe7(address _0x0d2480, uint256 _0x4178d6) public returns (bool) {
    _0x3f40f2[msg.sender][_0x0d2480] = _0x4178d6;
    Approval(msg.sender, _0x0d2480, _0x4178d6);
    return true;
  }

  function _0x8411b7(address _0x0fe4f7, address _0x0d2480) public constant returns (uint256 _0x026264) {
    return _0x3f40f2[_0x0fe4f7][_0x0d2480];
  }
}

contract Ownable {
  address public _0x1bec2a;

  event OwnershipTransferred(address indexed _0xd3c4ca, address indexed _0xebb352);

  function Ownable() {
    _0x1bec2a = msg.sender;
  }

  modifier _0xf3d98d() {
    require(msg.sender == _0x1bec2a);
    _;
  }

  function _0xbf5aab(address _0xebb352) _0xf3d98d public {
    require(_0xebb352 != address(0));
    OwnershipTransferred(_0x1bec2a, _0xebb352);
    _0x1bec2a = _0xebb352;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0x7abc8a = false;

  modifier _0xb8ab53() {
    require(!_0x7abc8a);
    _;
  }

  modifier _0x50bea2() {
    require(_0x7abc8a);
    _;
  }

  function _0x943998() _0xf3d98d _0xb8ab53 public {
    _0x7abc8a = true;
    Pause();
  }

  function _0xf41608() _0xf3d98d _0x50bea2 public {
    _0x7abc8a = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _0x843a66, uint256 _0x4178d6) public _0xb8ab53 returns (bool) {
    return super.transfer(_0x843a66, _0x4178d6);
  }

  function _0x371a2b(address _0x10c8f2, address _0x843a66, uint256 _0x4178d6) public _0xb8ab53 returns (bool) {
    return super._0x371a2b(_0x10c8f2, _0x843a66, _0x4178d6);
  }

  function _0x7cebe7(address _0x0d2480, uint256 _0x4178d6) public _0xb8ab53 returns (bool) {
    return super._0x7cebe7(_0x0d2480, _0x4178d6);
  }

  function _0x554642(address[] _0x44fa23, uint256 _0x4178d6) public _0xb8ab53 returns (bool) {
    uint _0x307a4b = _0x44fa23.length;
    uint256 _0x8a340c = uint256(_0x307a4b) * _0x4178d6;
    require(_0x307a4b > 0 && _0x307a4b <= 20);
    require(_0x4178d6 > 0 && _0xb099c6[msg.sender] >= _0x8a340c);

    _0xb099c6[msg.sender] = _0xb099c6[msg.sender]._0xb8ef6b(_0x8a340c);
    for (uint i = 0; i < _0x307a4b; i++) {
        _0xb099c6[_0x44fa23[i]] = _0xb099c6[_0x44fa23[i]]._0xf32cb2(_0x4178d6);
        Transfer(msg.sender, _0x44fa23[i], _0x4178d6);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public _0x3e6c47 = "BeautyChain";
    string public _0x0debcb = "BEC";
    string public _0x0b0678 = '1.0.0';
    uint8 public _0x42ab48 = 18;

    function BecToken() {
      _0xea9c3d = 7000000000 * (10**(uint256(_0x42ab48)));
      _0xb099c6[msg.sender] = _0xea9c3d;    // Give the creator all initial tokens
    }

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}
