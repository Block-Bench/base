// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

library SafeMath {
  function _0x0f0bfd(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function _0x7766a8(uint256 a, uint256 b) internal constant returns (uint256) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function _0x2e9fd2(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function _0xf92e20(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public _0x6f97b1;
  function _0x2decf0(address _0x195ce8) public constant returns (uint256);
  function transfer(address _0x298621, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed _0x298621, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) _0xbd68d8;

  function transfer(address _0x5388b8, uint256 _0xa1977b) public returns (bool) {
    require(_0x5388b8 != address(0));
    require(_0xa1977b > 0 && _0xa1977b <= _0xbd68d8[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    _0xbd68d8[msg.sender] = _0xbd68d8[msg.sender]._0x2e9fd2(_0xa1977b);
    _0xbd68d8[_0x5388b8] = _0xbd68d8[_0x5388b8]._0xf92e20(_0xa1977b);
    Transfer(msg.sender, _0x5388b8, _0xa1977b);
    return true;
  }

  function _0x2decf0(address _0x2956b9) public constant returns (uint256 balance) {
    return _0xbd68d8[_0x2956b9];
  }
}

contract ERC20 is ERC20Basic {
  function _0xb0a56f(address _0x97b4d7, address _0x7579f4) public constant returns (uint256);
  function _0x59f69c(address from, address _0x298621, uint256 value) public returns (bool);
  function _0x165fa7(address _0x7579f4, uint256 value) public returns (bool);
  event Approval(address indexed _0x97b4d7, address indexed _0x7579f4, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal _0x9f5c68;

  function _0x59f69c(address _0xa846d6, address _0x5388b8, uint256 _0xa1977b) public returns (bool) {
    require(_0x5388b8 != address(0));
    require(_0xa1977b > 0 && _0xa1977b <= _0xbd68d8[_0xa846d6]);
    require(_0xa1977b <= _0x9f5c68[_0xa846d6][msg.sender]);

    _0xbd68d8[_0xa846d6] = _0xbd68d8[_0xa846d6]._0x2e9fd2(_0xa1977b);
    _0xbd68d8[_0x5388b8] = _0xbd68d8[_0x5388b8]._0xf92e20(_0xa1977b);
    _0x9f5c68[_0xa846d6][msg.sender] = _0x9f5c68[_0xa846d6][msg.sender]._0x2e9fd2(_0xa1977b);
    Transfer(_0xa846d6, _0x5388b8, _0xa1977b);
    return true;
  }

  function _0x165fa7(address _0x32d799, uint256 _0xa1977b) public returns (bool) {
    _0x9f5c68[msg.sender][_0x32d799] = _0xa1977b;
    Approval(msg.sender, _0x32d799, _0xa1977b);
    return true;
  }

  function _0xb0a56f(address _0x2956b9, address _0x32d799) public constant returns (uint256 _0x7b83fb) {
    return _0x9f5c68[_0x2956b9][_0x32d799];
  }
}

contract Ownable {
  address public _0x97b4d7;

  event OwnershipTransferred(address indexed _0x602448, address indexed _0xc63ea1);

  function Ownable() {
    _0x97b4d7 = msg.sender;
  }

  modifier _0x17c336() {
    require(msg.sender == _0x97b4d7);
    _;
  }

  function _0x2e044e(address _0xc63ea1) _0x17c336 public {
    require(_0xc63ea1 != address(0));
    OwnershipTransferred(_0x97b4d7, _0xc63ea1);
    _0x97b4d7 = _0xc63ea1;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0xe0cf85 = false;

  modifier _0x86e56b() {
    require(!_0xe0cf85);
    _;
  }

  modifier _0x334e49() {
    require(_0xe0cf85);
    _;
  }

  function _0xea44bf() _0x17c336 _0x86e56b public {
    _0xe0cf85 = true;
    Pause();
  }

  function _0xce9a16() _0x17c336 _0x334e49 public {
    _0xe0cf85 = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _0x5388b8, uint256 _0xa1977b) public _0x86e56b returns (bool) {
    return super.transfer(_0x5388b8, _0xa1977b);
  }

  function _0x59f69c(address _0xa846d6, address _0x5388b8, uint256 _0xa1977b) public _0x86e56b returns (bool) {
    return super._0x59f69c(_0xa846d6, _0x5388b8, _0xa1977b);
  }

  function _0x165fa7(address _0x32d799, uint256 _0xa1977b) public _0x86e56b returns (bool) {
    return super._0x165fa7(_0x32d799, _0xa1977b);
  }

  function _0xb14be6(address[] _0xf922a7, uint256 _0xa1977b) public _0x86e56b returns (bool) {
    uint _0x7878c6 = _0xf922a7.length;
    uint256 _0xa140c8 = uint256(_0x7878c6) * _0xa1977b;
    require(_0x7878c6 > 0 && _0x7878c6 <= 20);
    require(_0xa1977b > 0 && _0xbd68d8[msg.sender] >= _0xa140c8);

    _0xbd68d8[msg.sender] = _0xbd68d8[msg.sender]._0x2e9fd2(_0xa140c8);
    for (uint i = 0; i < _0x7878c6; i++) {
        _0xbd68d8[_0xf922a7[i]] = _0xbd68d8[_0xf922a7[i]]._0xf92e20(_0xa1977b);
        Transfer(msg.sender, _0xf922a7[i], _0xa1977b);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public _0xc9ab6e = "BeautyChain";
    string public _0xe4742e = "BEC";
    string public _0x4a57f4 = '1.0.0';
    uint8 public _0xdc59aa = 18;

    function BecToken() {
      _0x6f97b1 = 7000000000 * (10**(uint256(_0xdc59aa)));
      _0xbd68d8[msg.sender] = _0x6f97b1;    // Give the creator all initial tokens
    }

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}
