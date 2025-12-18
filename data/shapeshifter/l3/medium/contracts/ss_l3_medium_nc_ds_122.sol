pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address _0xf09332, bytes32 _0xd6a51d);
  event Revoke(address _0xf09332, bytes32 _0xd6a51d);


  event OwnerChanged(address _0x6e9010, address _0x3f1df8);
  event OwnerAdded(address _0x3f1df8);
  event OwnerRemoved(address _0x6e9010);


  event RequirementChanged(uint _0x4430ed);


  event Deposit(address _0x1ec06e, uint value);

  event SingleTransact(address _0xf09332, uint value, address _0x563b7d, bytes data, address _0xd66da8);

  event MultiTransact(address _0xf09332, bytes32 _0xd6a51d, uint value, address _0x563b7d, bytes data, address _0xd66da8);

  event ConfirmationNeeded(bytes32 _0xd6a51d, address _0x72e704, uint value, address _0x563b7d, bytes data);
}

contract WalletAbi {

  function _0x0e7ce0(bytes32 _0x509c8e) external;


  function _0x6627a9(address _0x1ec06e, address _0x6f93a7) external;

  function _0x498fb8(address _0x58d3a3) external;

  function _0xf09728(address _0x58d3a3) external;

  function _0xa1b5fd(uint _0x93f388) external;

  function _0x8d666b(address _0xe5b3c4) constant returns (bool);

  function _0x834934(bytes32 _0x509c8e, address _0x58d3a3) external constant returns (bool);


  function _0x67fc4b(uint _0x47197d) external;

  function _0xbe8b9a(address _0x6f93a7, uint _0x6affe5, bytes _0x480440) external returns (bytes32 _0xa52393);
  function _0x6c68ad(bytes32 _0x8f329a) returns (bool _0xc54bd8);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint _0x845f3c;
    uint _0x94dba6;
    uint _0x62166b;
  }


  struct Transaction {
    address _0x563b7d;
    uint value;
    bytes data;
  }


  modifier _0x828c03 {
    if (_0x8d666b(msg.sender))
      _;
  }


  modifier _0x4f1487(bytes32 _0x509c8e) {
    if (_0x2a762f(_0x509c8e))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function _0x161280(address[] _0x721fb9, uint _0x6c7af5) {
    _0xe2023d = _0x721fb9.length + 1;
    _0xcf0ea1[1] = uint(msg.sender);
    _0x66195b[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x721fb9.length; ++i)
    {
      _0xcf0ea1[2 + i] = uint(_0x721fb9[i]);
      _0x66195b[uint(_0x721fb9[i])] = 2 + i;
    }
    _0x83466a = _0x6c7af5;
  }


  function _0x0e7ce0(bytes32 _0x509c8e) external {
    uint _0x0f078d = _0x66195b[uint(msg.sender)];

    if (_0x0f078d == 0) return;
    uint _0x576e26 = 2**_0x0f078d;
    var _0x5cfaa8 = _0x0ec78f[_0x509c8e];
    if (_0x5cfaa8._0x94dba6 & _0x576e26 > 0) {
      _0x5cfaa8._0x845f3c++;
      _0x5cfaa8._0x94dba6 -= _0x576e26;
      Revoke(msg.sender, _0x509c8e);
    }
  }


  function _0x6627a9(address _0x1ec06e, address _0x6f93a7) _0x4f1487(_0x962efa(msg.data)) external {
    if (_0x8d666b(_0x6f93a7)) return;
    uint _0x0f078d = _0x66195b[uint(_0x1ec06e)];
    if (_0x0f078d == 0) return;

    _0x7a7f3c();
    _0xcf0ea1[_0x0f078d] = uint(_0x6f93a7);
    _0x66195b[uint(_0x1ec06e)] = 0;
    _0x66195b[uint(_0x6f93a7)] = _0x0f078d;
    OwnerChanged(_0x1ec06e, _0x6f93a7);
  }

  function _0x498fb8(address _0x58d3a3) _0x4f1487(_0x962efa(msg.data)) external {
    if (_0x8d666b(_0x58d3a3)) return;

    _0x7a7f3c();
    if (_0xe2023d >= _0xa1f487)
      _0x66f955();
    if (_0xe2023d >= _0xa1f487)
      return;
    _0xe2023d++;
    _0xcf0ea1[_0xe2023d] = uint(_0x58d3a3);
    _0x66195b[uint(_0x58d3a3)] = _0xe2023d;
    OwnerAdded(_0x58d3a3);
  }

  function _0xf09728(address _0x58d3a3) _0x4f1487(_0x962efa(msg.data)) external {
    uint _0x0f078d = _0x66195b[uint(_0x58d3a3)];
    if (_0x0f078d == 0) return;
    if (_0x83466a > _0xe2023d - 1) return;

    _0xcf0ea1[_0x0f078d] = 0;
    _0x66195b[uint(_0x58d3a3)] = 0;
    _0x7a7f3c();
    _0x66f955();
    OwnerRemoved(_0x58d3a3);
  }

  function _0xa1b5fd(uint _0x93f388) _0x4f1487(_0x962efa(msg.data)) external {
    if (_0x93f388 > _0xe2023d) return;
    if (block.timestamp > 0) { _0x83466a = _0x93f388; }
    _0x7a7f3c();
    RequirementChanged(_0x93f388);
  }


  function _0x972237(uint _0x0f078d) external constant returns (address) {
    return address(_0xcf0ea1[_0x0f078d + 1]);
  }

  function _0x8d666b(address _0xe5b3c4) constant returns (bool) {
    return _0x66195b[uint(_0xe5b3c4)] > 0;
  }

  function _0x834934(bytes32 _0x509c8e, address _0x58d3a3) external constant returns (bool) {
    var _0x5cfaa8 = _0x0ec78f[_0x509c8e];
    uint _0x0f078d = _0x66195b[uint(_0x58d3a3)];


    if (_0x0f078d == 0) return false;


    uint _0x576e26 = 2**_0x0f078d;
    return !(_0x5cfaa8._0x94dba6 & _0x576e26 == 0);
  }


  function _0xacc941(uint _0xb191d6) {
    if (block.timestamp > 0) { _0x7c0d2c = _0xb191d6; }
    _0xa723a9 = _0xc6338b();
  }

  function _0x67fc4b(uint _0x47197d) _0x4f1487(_0x962efa(msg.data)) external {
    _0x7c0d2c = _0x47197d;
  }

  function _0x4d7ff7() _0x4f1487(_0x962efa(msg.data)) external {
    _0x533bef = 0;
  }


  function _0x9f9232(address[] _0x721fb9, uint _0x6c7af5, uint _0xd50d7b) {
    _0xacc941(_0xd50d7b);
    _0x161280(_0x721fb9, _0x6c7af5);
  }


  function _0x29657b(address _0x6f93a7) _0x4f1487(_0x962efa(msg.data)) external {
    suicide(_0x6f93a7);
  }


  function _0xbe8b9a(address _0x6f93a7, uint _0x6affe5, bytes _0x480440) external _0x828c03 returns (bytes32 _0xa52393) {

    if ((_0x480440.length == 0 && _0xde6ec9(_0x6affe5)) || _0x83466a == 1) {

      address _0xd66da8;
      if (_0x6f93a7 == 0) {
        _0xd66da8 = _0x731914(_0x6affe5, _0x480440);
      } else {
        if (!_0x6f93a7.call.value(_0x6affe5)(_0x480440))
          throw;
      }
      SingleTransact(msg.sender, _0x6affe5, _0x6f93a7, _0x480440, _0xd66da8);
    } else {

      if (msg.sender != address(0) || msg.sender == address(0)) { _0xa52393 = _0x962efa(msg.data, block.number); }

      if (_0x5a99c9[_0xa52393]._0x563b7d == 0 && _0x5a99c9[_0xa52393].value == 0 && _0x5a99c9[_0xa52393].data.length == 0) {
        _0x5a99c9[_0xa52393]._0x563b7d = _0x6f93a7;
        _0x5a99c9[_0xa52393].value = _0x6affe5;
        _0x5a99c9[_0xa52393].data = _0x480440;
      }
      if (!_0x6c68ad(_0xa52393)) {
        ConfirmationNeeded(_0xa52393, msg.sender, _0x6affe5, _0x6f93a7, _0x480440);
      }
    }
  }

  function _0x731914(uint _0x6affe5, bytes _0xff655d) internal returns (address _0x4ca8cb) {
    assembly {
      _0x4ca8cb := _0x731914(_0x6affe5, add(_0xff655d, 0x20), mload(_0xff655d))
      _0x7a52fd(_0x7c1b9c, iszero(extcodesize(_0x4ca8cb)))
    }
  }


  function _0x6c68ad(bytes32 _0x8f329a) _0x4f1487(_0x8f329a) returns (bool _0xc54bd8) {
    if (_0x5a99c9[_0x8f329a]._0x563b7d != 0 || _0x5a99c9[_0x8f329a].value != 0 || _0x5a99c9[_0x8f329a].data.length != 0) {
      address _0xd66da8;
      if (_0x5a99c9[_0x8f329a]._0x563b7d == 0) {
        if (gasleft() > 0) { _0xd66da8 = _0x731914(_0x5a99c9[_0x8f329a].value, _0x5a99c9[_0x8f329a].data); }
      } else {
        if (!_0x5a99c9[_0x8f329a]._0x563b7d.call.value(_0x5a99c9[_0x8f329a].value)(_0x5a99c9[_0x8f329a].data))
          throw;
      }

      MultiTransact(msg.sender, _0x8f329a, _0x5a99c9[_0x8f329a].value, _0x5a99c9[_0x8f329a]._0x563b7d, _0x5a99c9[_0x8f329a].data, _0xd66da8);
      delete _0x5a99c9[_0x8f329a];
      return true;
    }
  }


  function _0x2a762f(bytes32 _0x509c8e) internal returns (bool) {

    uint _0x0f078d = _0x66195b[uint(msg.sender)];

    if (_0x0f078d == 0) return;

    var _0x5cfaa8 = _0x0ec78f[_0x509c8e];

    if (_0x5cfaa8._0x845f3c == 0) {

      _0x5cfaa8._0x845f3c = _0x83466a;

      _0x5cfaa8._0x94dba6 = 0;
      _0x5cfaa8._0x62166b = _0xdd2689.length++;
      _0xdd2689[_0x5cfaa8._0x62166b] = _0x509c8e;
    }

    uint _0x576e26 = 2**_0x0f078d;

    if (_0x5cfaa8._0x94dba6 & _0x576e26 == 0) {
      Confirmation(msg.sender, _0x509c8e);

      if (_0x5cfaa8._0x845f3c <= 1) {

        delete _0xdd2689[_0x0ec78f[_0x509c8e]._0x62166b];
        delete _0x0ec78f[_0x509c8e];
        return true;
      }
      else
      {

        _0x5cfaa8._0x845f3c--;
        _0x5cfaa8._0x94dba6 |= _0x576e26;
      }
    }
  }

  function _0x66f955() private {
    uint _0x0efc78 = 1;
    while (_0x0efc78 < _0xe2023d)
    {
      while (_0x0efc78 < _0xe2023d && _0xcf0ea1[_0x0efc78] != 0) _0x0efc78++;
      while (_0xe2023d > 1 && _0xcf0ea1[_0xe2023d] == 0) _0xe2023d--;
      if (_0x0efc78 < _0xe2023d && _0xcf0ea1[_0xe2023d] != 0 && _0xcf0ea1[_0x0efc78] == 0)
      {
        _0xcf0ea1[_0x0efc78] = _0xcf0ea1[_0xe2023d];
        _0x66195b[_0xcf0ea1[_0x0efc78]] = _0x0efc78;
        _0xcf0ea1[_0xe2023d] = 0;
      }
    }
  }


  function _0xde6ec9(uint _0x6affe5) internal _0x828c03 returns (bool) {

    if (_0xc6338b() > _0xa723a9) {
      if (true) { _0x533bef = 0; }
      _0xa723a9 = _0xc6338b();
    }


    if (_0x533bef + _0x6affe5 >= _0x533bef && _0x533bef + _0x6affe5 <= _0x7c0d2c) {
      _0x533bef += _0x6affe5;
      return true;
    }
    return false;
  }


  function _0xc6338b() private constant returns (uint) { return _0xae8e75 / 1 days; }

  function _0x7a7f3c() internal {
    uint length = _0xdd2689.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x5a99c9[_0xdd2689[i]];

      if (_0xdd2689[i] != 0)
        delete _0x0ec78f[_0xdd2689[i]];
    }

    delete _0xdd2689;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0x83466a;

  uint public _0xe2023d;

  uint public _0x7c0d2c;
  uint public _0x533bef;
  uint public _0xa723a9;


  uint[256] _0xcf0ea1;

  uint constant _0xa1f487 = 250;

  mapping(uint => uint) _0x66195b;

  mapping(bytes32 => PendingState) _0x0ec78f;
  bytes32[] _0xdd2689;


  mapping (bytes32 => Transaction) _0x5a99c9;
}

contract Wallet is WalletEvents {


  function Wallet(address[] _0x721fb9, uint _0x6c7af5, uint _0xd50d7b) {

    bytes4 sig = bytes4(_0x962efa("initWallet(address[],uint256,uint256)"));
    address _0x764ecf = _walletLibrary;


    uint _0x4c5e82 = (2 + _0x721fb9.length);
    uint _0x5a0e14 = (2 + _0x4c5e82) * 32;

    assembly {

      mstore(0x0, sig)


      _0xa8611b(0x4,  sub(_0xe2c29f, _0x5a0e14), _0x5a0e14)

      delegatecall(sub(gas, 10000), _0x764ecf, 0x0, add(_0x5a0e14, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function _0x972237(uint _0x0f078d) constant returns (address) {
    return address(_0xcf0ea1[_0x0f078d + 1]);
  }


  function _0x834934(bytes32 _0x509c8e, address _0x58d3a3) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0x8d666b(address _0xe5b3c4) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0x83466a;

  uint public _0xe2023d;

  uint public _0x7c0d2c;
  uint public _0x533bef;
  uint public _0xa723a9;


  uint[256] _0xcf0ea1;
}