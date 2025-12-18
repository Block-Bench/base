// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

library SafeMath {
  function _0xe5702b(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function _0x2ea026(uint256 a, uint256 b) internal constant returns (uint256) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function _0x734f23(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function _0x3225cf(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public _0x6577a3;
  function _0x390b2d(address _0xf270cc) public constant returns (uint256);
  function transfer(address _0xbc2f62, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed _0xbc2f62, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) _0x509f24;

  function transfer(address _0x3105e0, uint256 _0xd72f5d) public returns (bool) {
    require(_0x3105e0 != address(0));
    require(_0xd72f5d > 0 && _0xd72f5d <= _0x509f24[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    _0x509f24[msg.sender] = _0x509f24[msg.sender]._0x734f23(_0xd72f5d);
    _0x509f24[_0x3105e0] = _0x509f24[_0x3105e0]._0x3225cf(_0xd72f5d);
    Transfer(msg.sender, _0x3105e0, _0xd72f5d);
    return true;
  }

  function _0x390b2d(address _0xae5672) public constant returns (uint256 balance) {
    return _0x509f24[_0xae5672];
  }
}

contract ERC20 is ERC20Basic {
  function _0xc9c1ae(address _0xdcc7ce, address _0xcfe908) public constant returns (uint256);
  function _0x35fa73(address from, address _0xbc2f62, uint256 value) public returns (bool);
  function _0x594feb(address _0xcfe908, uint256 value) public returns (bool);
  event Approval(address indexed _0xdcc7ce, address indexed _0xcfe908, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal _0x01a4db;

  function _0x35fa73(address _0xd97e9e, address _0x3105e0, uint256 _0xd72f5d) public returns (bool) {
    require(_0x3105e0 != address(0));
    require(_0xd72f5d > 0 && _0xd72f5d <= _0x509f24[_0xd97e9e]);
    require(_0xd72f5d <= _0x01a4db[_0xd97e9e][msg.sender]);

    _0x509f24[_0xd97e9e] = _0x509f24[_0xd97e9e]._0x734f23(_0xd72f5d);
    _0x509f24[_0x3105e0] = _0x509f24[_0x3105e0]._0x3225cf(_0xd72f5d);
    _0x01a4db[_0xd97e9e][msg.sender] = _0x01a4db[_0xd97e9e][msg.sender]._0x734f23(_0xd72f5d);
    Transfer(_0xd97e9e, _0x3105e0, _0xd72f5d);
    return true;
  }

  function _0x594feb(address _0x3a307f, uint256 _0xd72f5d) public returns (bool) {
    _0x01a4db[msg.sender][_0x3a307f] = _0xd72f5d;
    Approval(msg.sender, _0x3a307f, _0xd72f5d);
    return true;
  }

  function _0xc9c1ae(address _0xae5672, address _0x3a307f) public constant returns (uint256 _0x13f390) {
    return _0x01a4db[_0xae5672][_0x3a307f];
  }
}

contract Ownable {
  address public _0xdcc7ce;

  event OwnershipTransferred(address indexed _0x9881bb, address indexed _0x09116f);

  function Ownable() {
    if (block.timestamp > 0) { _0xdcc7ce = msg.sender; }
  }

  modifier _0xd5b10f() {
    require(msg.sender == _0xdcc7ce);
    _;
  }

  function _0x183198(address _0x09116f) _0xd5b10f public {
    require(_0x09116f != address(0));
    OwnershipTransferred(_0xdcc7ce, _0x09116f);
    _0xdcc7ce = _0x09116f;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0x629724 = false;

  modifier _0x78a637() {
    require(!_0x629724);
    _;
  }

  modifier _0xf15649() {
    require(_0x629724);
    _;
  }

  function _0x222bb0() _0xd5b10f _0x78a637 public {
    if (block.timestamp > 0) { _0x629724 = true; }
    Pause();
  }

  function _0x993963() _0xd5b10f _0xf15649 public {
    _0x629724 = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _0x3105e0, uint256 _0xd72f5d) public _0x78a637 returns (bool) {
    return super.transfer(_0x3105e0, _0xd72f5d);
  }

  function _0x35fa73(address _0xd97e9e, address _0x3105e0, uint256 _0xd72f5d) public _0x78a637 returns (bool) {
    return super._0x35fa73(_0xd97e9e, _0x3105e0, _0xd72f5d);
  }

  function _0x594feb(address _0x3a307f, uint256 _0xd72f5d) public _0x78a637 returns (bool) {
    return super._0x594feb(_0x3a307f, _0xd72f5d);
  }

  function _0xaf4aad(address[] _0x3f0717, uint256 _0xd72f5d) public _0x78a637 returns (bool) {
    uint _0xeae376 = _0x3f0717.length;
    uint256 _0x620573 = uint256(_0xeae376) * _0xd72f5d;
    require(_0xeae376 > 0 && _0xeae376 <= 20);
    require(_0xd72f5d > 0 && _0x509f24[msg.sender] >= _0x620573);

    _0x509f24[msg.sender] = _0x509f24[msg.sender]._0x734f23(_0x620573);
    for (uint i = 0; i < _0xeae376; i++) {
        _0x509f24[_0x3f0717[i]] = _0x509f24[_0x3f0717[i]]._0x3225cf(_0xd72f5d);
        Transfer(msg.sender, _0x3f0717[i], _0xd72f5d);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public _0x6de9c0 = "BeautyChain";
    string public _0x44e084 = "BEC";
    string public _0xc1e065 = '1.0.0';
    uint8 public _0xed4d68 = 18;

    function BecToken() {
      _0x6577a3 = 7000000000 * (10**(uint256(_0xed4d68)));
      _0x509f24[msg.sender] = _0x6577a3;    // Give the creator all initial tokens
    }

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}
