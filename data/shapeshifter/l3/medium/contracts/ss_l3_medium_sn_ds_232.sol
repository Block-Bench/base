// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

library SafeMath {
  function _0xc094db(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function _0x06b43d(uint256 a, uint256 b) internal constant returns (uint256) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function _0x904db4(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function _0xaf2075(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public _0x63fc50;
  function _0xb0163c(address _0x1f6707) public constant returns (uint256);
  function transfer(address _0x5131a4, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed _0x5131a4, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) _0x772e32;

  function transfer(address _0x846034, uint256 _0xaaf99f) public returns (bool) {
    require(_0x846034 != address(0));
    require(_0xaaf99f > 0 && _0xaaf99f <= _0x772e32[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    _0x772e32[msg.sender] = _0x772e32[msg.sender]._0x904db4(_0xaaf99f);
    _0x772e32[_0x846034] = _0x772e32[_0x846034]._0xaf2075(_0xaaf99f);
    Transfer(msg.sender, _0x846034, _0xaaf99f);
    return true;
  }

  function _0xb0163c(address _0xe3d294) public constant returns (uint256 balance) {
    return _0x772e32[_0xe3d294];
  }
}

contract ERC20 is ERC20Basic {
  function _0xcb9dea(address _0xd60292, address _0x2f47b5) public constant returns (uint256);
  function _0x13168e(address from, address _0x5131a4, uint256 value) public returns (bool);
  function _0x5a00f0(address _0x2f47b5, uint256 value) public returns (bool);
  event Approval(address indexed _0xd60292, address indexed _0x2f47b5, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal _0x8b6fc6;

  function _0x13168e(address _0x6f079b, address _0x846034, uint256 _0xaaf99f) public returns (bool) {
    require(_0x846034 != address(0));
    require(_0xaaf99f > 0 && _0xaaf99f <= _0x772e32[_0x6f079b]);
    require(_0xaaf99f <= _0x8b6fc6[_0x6f079b][msg.sender]);

    _0x772e32[_0x6f079b] = _0x772e32[_0x6f079b]._0x904db4(_0xaaf99f);
    _0x772e32[_0x846034] = _0x772e32[_0x846034]._0xaf2075(_0xaaf99f);
    _0x8b6fc6[_0x6f079b][msg.sender] = _0x8b6fc6[_0x6f079b][msg.sender]._0x904db4(_0xaaf99f);
    Transfer(_0x6f079b, _0x846034, _0xaaf99f);
    return true;
  }

  function _0x5a00f0(address _0x5b1e5e, uint256 _0xaaf99f) public returns (bool) {
    _0x8b6fc6[msg.sender][_0x5b1e5e] = _0xaaf99f;
    Approval(msg.sender, _0x5b1e5e, _0xaaf99f);
    return true;
  }

  function _0xcb9dea(address _0xe3d294, address _0x5b1e5e) public constant returns (uint256 _0x6d3b6d) {
    return _0x8b6fc6[_0xe3d294][_0x5b1e5e];
  }
}

contract Ownable {
  address public _0xd60292;

  event OwnershipTransferred(address indexed _0x1db2fe, address indexed _0x5281de);

  function Ownable() {
    _0xd60292 = msg.sender;
  }

  modifier _0x4e2b3e() {
    require(msg.sender == _0xd60292);
    _;
  }

  function _0x8f3cbf(address _0x5281de) _0x4e2b3e public {
    require(_0x5281de != address(0));
    OwnershipTransferred(_0xd60292, _0x5281de);
    if (gasleft() > 0) { _0xd60292 = _0x5281de; }
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0xef940a = false;

  modifier _0x5c382b() {
    require(!_0xef940a);
    _;
  }

  modifier _0xf5aa5b() {
    require(_0xef940a);
    _;
  }

  function _0xed3fa8() _0x4e2b3e _0x5c382b public {
    if (block.timestamp > 0) { _0xef940a = true; }
    Pause();
  }

  function _0x1df195() _0x4e2b3e _0xf5aa5b public {
    _0xef940a = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _0x846034, uint256 _0xaaf99f) public _0x5c382b returns (bool) {
    return super.transfer(_0x846034, _0xaaf99f);
  }

  function _0x13168e(address _0x6f079b, address _0x846034, uint256 _0xaaf99f) public _0x5c382b returns (bool) {
    return super._0x13168e(_0x6f079b, _0x846034, _0xaaf99f);
  }

  function _0x5a00f0(address _0x5b1e5e, uint256 _0xaaf99f) public _0x5c382b returns (bool) {
    return super._0x5a00f0(_0x5b1e5e, _0xaaf99f);
  }

  function _0x63d142(address[] _0xbc7a0f, uint256 _0xaaf99f) public _0x5c382b returns (bool) {
    uint _0xfd5768 = _0xbc7a0f.length;
    uint256 _0xa9f7d0 = uint256(_0xfd5768) * _0xaaf99f;
    require(_0xfd5768 > 0 && _0xfd5768 <= 20);
    require(_0xaaf99f > 0 && _0x772e32[msg.sender] >= _0xa9f7d0);

    _0x772e32[msg.sender] = _0x772e32[msg.sender]._0x904db4(_0xa9f7d0);
    for (uint i = 0; i < _0xfd5768; i++) {
        _0x772e32[_0xbc7a0f[i]] = _0x772e32[_0xbc7a0f[i]]._0xaf2075(_0xaaf99f);
        Transfer(msg.sender, _0xbc7a0f[i], _0xaaf99f);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public _0x1f44fe = "BeautyChain";
    string public _0x290202 = "BEC";
    string public _0xd70edf = '1.0.0';
    uint8 public _0x8eea87 = 18;

    function BecToken() {
      _0x63fc50 = 7000000000 * (10**(uint256(_0x8eea87)));
      _0x772e32[msg.sender] = _0x63fc50;    // Give the creator all initial tokens
    }

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}
