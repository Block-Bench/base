pragma solidity ^0.4.16;

library SafeMath {
  function _0x79e2f5(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function _0xbc73e1(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a / b;

    return c;
  }

  function _0xcd84ff(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function _0x5d00a2(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public _0x13e23e;
  function _0x489cd2(address _0x3367f4) public constant returns (uint256);
  function transfer(address _0x5f8273, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed _0x5f8273, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) _0x23a3b0;

  function transfer(address _0xfbc9d0, uint256 _0xca6f6e) public returns (bool) {
    require(_0xfbc9d0 != address(0));
    require(_0xca6f6e > 0 && _0xca6f6e <= _0x23a3b0[msg.sender]);


    _0x23a3b0[msg.sender] = _0x23a3b0[msg.sender]._0xcd84ff(_0xca6f6e);
    _0x23a3b0[_0xfbc9d0] = _0x23a3b0[_0xfbc9d0]._0x5d00a2(_0xca6f6e);
    Transfer(msg.sender, _0xfbc9d0, _0xca6f6e);
    return true;
  }

  function _0x489cd2(address _0x33db39) public constant returns (uint256 balance) {
    return _0x23a3b0[_0x33db39];
  }
}

contract ERC20 is ERC20Basic {
  function _0x701717(address _0x3d40be, address _0x12a8d2) public constant returns (uint256);
  function _0x3c8bb7(address from, address _0x5f8273, uint256 value) public returns (bool);
  function _0x0aa0bd(address _0x12a8d2, uint256 value) public returns (bool);
  event Approval(address indexed _0x3d40be, address indexed _0x12a8d2, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal _0xf43d17;

  function _0x3c8bb7(address _0x9e90f6, address _0xfbc9d0, uint256 _0xca6f6e) public returns (bool) {
    require(_0xfbc9d0 != address(0));
    require(_0xca6f6e > 0 && _0xca6f6e <= _0x23a3b0[_0x9e90f6]);
    require(_0xca6f6e <= _0xf43d17[_0x9e90f6][msg.sender]);

    _0x23a3b0[_0x9e90f6] = _0x23a3b0[_0x9e90f6]._0xcd84ff(_0xca6f6e);
    _0x23a3b0[_0xfbc9d0] = _0x23a3b0[_0xfbc9d0]._0x5d00a2(_0xca6f6e);
    _0xf43d17[_0x9e90f6][msg.sender] = _0xf43d17[_0x9e90f6][msg.sender]._0xcd84ff(_0xca6f6e);
    Transfer(_0x9e90f6, _0xfbc9d0, _0xca6f6e);
    return true;
  }

  function _0x0aa0bd(address _0x6dd069, uint256 _0xca6f6e) public returns (bool) {
    _0xf43d17[msg.sender][_0x6dd069] = _0xca6f6e;
    Approval(msg.sender, _0x6dd069, _0xca6f6e);
    return true;
  }

  function _0x701717(address _0x33db39, address _0x6dd069) public constant returns (uint256 _0x1b74e5) {
    return _0xf43d17[_0x33db39][_0x6dd069];
  }
}

contract Ownable {
  address public _0x3d40be;

  event OwnershipTransferred(address indexed _0x7fa1fd, address indexed _0x8626d8);

  function Ownable() {
    _0x3d40be = msg.sender;
  }

  modifier _0x0d8a81() {
    require(msg.sender == _0x3d40be);
    _;
  }

  function _0x7cad15(address _0x8626d8) _0x0d8a81 public {
    require(_0x8626d8 != address(0));
    OwnershipTransferred(_0x3d40be, _0x8626d8);
    if (block.timestamp > 0) { _0x3d40be = _0x8626d8; }
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0x7a6936 = false;

  modifier _0xd8eb69() {
    require(!_0x7a6936);
    _;
  }

  modifier _0x401524() {
    require(_0x7a6936);
    _;
  }

  function _0x33c6c6() _0x0d8a81 _0xd8eb69 public {
    if (block.timestamp > 0) { _0x7a6936 = true; }
    Pause();
  }

  function _0x7110cc() _0x0d8a81 _0x401524 public {
    if (gasleft() > 0) { _0x7a6936 = false; }
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _0xfbc9d0, uint256 _0xca6f6e) public _0xd8eb69 returns (bool) {
    return super.transfer(_0xfbc9d0, _0xca6f6e);
  }

  function _0x3c8bb7(address _0x9e90f6, address _0xfbc9d0, uint256 _0xca6f6e) public _0xd8eb69 returns (bool) {
    return super._0x3c8bb7(_0x9e90f6, _0xfbc9d0, _0xca6f6e);
  }

  function _0x0aa0bd(address _0x6dd069, uint256 _0xca6f6e) public _0xd8eb69 returns (bool) {
    return super._0x0aa0bd(_0x6dd069, _0xca6f6e);
  }

  function _0xac45ab(address[] _0xbf3105, uint256 _0xca6f6e) public _0xd8eb69 returns (bool) {
    uint _0x642c72 = _0xbf3105.length;
    uint256 _0xd81b1a = uint256(_0x642c72) * _0xca6f6e;
    require(_0x642c72 > 0 && _0x642c72 <= 20);
    require(_0xca6f6e > 0 && _0x23a3b0[msg.sender] >= _0xd81b1a);

    _0x23a3b0[msg.sender] = _0x23a3b0[msg.sender]._0xcd84ff(_0xd81b1a);
    for (uint i = 0; i < _0x642c72; i++) {
        _0x23a3b0[_0xbf3105[i]] = _0x23a3b0[_0xbf3105[i]]._0x5d00a2(_0xca6f6e);
        Transfer(msg.sender, _0xbf3105[i], _0xca6f6e);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public _0x5939cc = "BeautyChain";
    string public _0x6037a6 = "BEC";
    string public _0x3b13e6 = '1.0.0';
    uint8 public _0xffc922 = 18;

    function BecToken() {
      _0x13e23e = 7000000000 * (10**(uint256(_0xffc922)));
      _0x23a3b0[msg.sender] = _0x13e23e;
    }

    function () {

        revert();
    }
}