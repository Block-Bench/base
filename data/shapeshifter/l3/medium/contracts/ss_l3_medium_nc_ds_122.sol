pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address _0xd250c6, bytes32 _0x6d256b);
  event Revoke(address _0xd250c6, bytes32 _0x6d256b);


  event OwnerChanged(address _0xdacc57, address _0xdd2928);
  event OwnerAdded(address _0xdd2928);
  event OwnerRemoved(address _0xdacc57);


  event RequirementChanged(uint _0x15db06);


  event Deposit(address _0x01cacd, uint value);

  event SingleTransact(address _0xd250c6, uint value, address _0x29ca48, bytes data, address _0x221d8e);

  event MultiTransact(address _0xd250c6, bytes32 _0x6d256b, uint value, address _0x29ca48, bytes data, address _0x221d8e);

  event ConfirmationNeeded(bytes32 _0x6d256b, address _0xe7adc7, uint value, address _0x29ca48, bytes data);
}

contract WalletAbi {

  function _0xd4e63d(bytes32 _0x823dea) external;


  function _0x766f1a(address _0x01cacd, address _0xa2c799) external;

  function _0x21a022(address _0x9da68b) external;

  function _0x58e1f8(address _0x9da68b) external;

  function _0xefbd6e(uint _0x58fed9) external;

  function _0x644d1a(address _0xd8bd20) constant returns (bool);

  function _0xb2aa02(bytes32 _0x823dea, address _0x9da68b) external constant returns (bool);


  function _0xbd79c8(uint _0xbd2bcf) external;

  function _0x942fc1(address _0xa2c799, uint _0x4333e5, bytes _0x9357e0) external returns (bytes32 _0x311738);
  function _0x073f5c(bytes32 _0x02e515) returns (bool _0xde467c);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint _0x8fc7a8;
    uint _0x9f6298;
    uint _0x7b6206;
  }


  struct Transaction {
    address _0x29ca48;
    uint value;
    bytes data;
  }


  modifier _0xf4c9ef {
    if (_0x644d1a(msg.sender))
      _;
  }


  modifier _0x406c64(bytes32 _0x823dea) {
    if (_0x14d231(_0x823dea))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function _0xf3a6f5(address[] _0xed2c75, uint _0xd055f6) {
    _0xc0629e = _0xed2c75.length + 1;
    _0x14971a[1] = uint(msg.sender);
    _0xacc4b8[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xed2c75.length; ++i)
    {
      _0x14971a[2 + i] = uint(_0xed2c75[i]);
      _0xacc4b8[uint(_0xed2c75[i])] = 2 + i;
    }
    if (gasleft() > 0) { _0x19072f = _0xd055f6; }
  }


  function _0xd4e63d(bytes32 _0x823dea) external {
    uint _0x0df7d6 = _0xacc4b8[uint(msg.sender)];

    if (_0x0df7d6 == 0) return;
    uint _0x6c30d4 = 2**_0x0df7d6;
    var _0x3ba741 = _0xa96efb[_0x823dea];
    if (_0x3ba741._0x9f6298 & _0x6c30d4 > 0) {
      _0x3ba741._0x8fc7a8++;
      _0x3ba741._0x9f6298 -= _0x6c30d4;
      Revoke(msg.sender, _0x823dea);
    }
  }


  function _0x766f1a(address _0x01cacd, address _0xa2c799) _0x406c64(_0x90b075(msg.data)) external {
    if (_0x644d1a(_0xa2c799)) return;
    uint _0x0df7d6 = _0xacc4b8[uint(_0x01cacd)];
    if (_0x0df7d6 == 0) return;

    _0x7f2af0();
    _0x14971a[_0x0df7d6] = uint(_0xa2c799);
    _0xacc4b8[uint(_0x01cacd)] = 0;
    _0xacc4b8[uint(_0xa2c799)] = _0x0df7d6;
    OwnerChanged(_0x01cacd, _0xa2c799);
  }

  function _0x21a022(address _0x9da68b) _0x406c64(_0x90b075(msg.data)) external {
    if (_0x644d1a(_0x9da68b)) return;

    _0x7f2af0();
    if (_0xc0629e >= _0x8d5ca3)
      _0xe8684e();
    if (_0xc0629e >= _0x8d5ca3)
      return;
    _0xc0629e++;
    _0x14971a[_0xc0629e] = uint(_0x9da68b);
    _0xacc4b8[uint(_0x9da68b)] = _0xc0629e;
    OwnerAdded(_0x9da68b);
  }

  function _0x58e1f8(address _0x9da68b) _0x406c64(_0x90b075(msg.data)) external {
    uint _0x0df7d6 = _0xacc4b8[uint(_0x9da68b)];
    if (_0x0df7d6 == 0) return;
    if (_0x19072f > _0xc0629e - 1) return;

    _0x14971a[_0x0df7d6] = 0;
    _0xacc4b8[uint(_0x9da68b)] = 0;
    _0x7f2af0();
    _0xe8684e();
    OwnerRemoved(_0x9da68b);
  }

  function _0xefbd6e(uint _0x58fed9) _0x406c64(_0x90b075(msg.data)) external {
    if (_0x58fed9 > _0xc0629e) return;
    _0x19072f = _0x58fed9;
    _0x7f2af0();
    RequirementChanged(_0x58fed9);
  }


  function _0x750532(uint _0x0df7d6) external constant returns (address) {
    return address(_0x14971a[_0x0df7d6 + 1]);
  }

  function _0x644d1a(address _0xd8bd20) constant returns (bool) {
    return _0xacc4b8[uint(_0xd8bd20)] > 0;
  }

  function _0xb2aa02(bytes32 _0x823dea, address _0x9da68b) external constant returns (bool) {
    var _0x3ba741 = _0xa96efb[_0x823dea];
    uint _0x0df7d6 = _0xacc4b8[uint(_0x9da68b)];


    if (_0x0df7d6 == 0) return false;


    uint _0x6c30d4 = 2**_0x0df7d6;
    return !(_0x3ba741._0x9f6298 & _0x6c30d4 == 0);
  }


  function _0x37d774(uint _0x7630da) {
    _0x5dd42c = _0x7630da;
    _0x25b207 = _0xb1de9a();
  }

  function _0xbd79c8(uint _0xbd2bcf) _0x406c64(_0x90b075(msg.data)) external {
    _0x5dd42c = _0xbd2bcf;
  }

  function _0xd6d91b() _0x406c64(_0x90b075(msg.data)) external {
    _0xad438a = 0;
  }


  function _0xf3db8d(address[] _0xed2c75, uint _0xd055f6, uint _0xc8677d) {
    _0x37d774(_0xc8677d);
    _0xf3a6f5(_0xed2c75, _0xd055f6);
  }


  function _0xcb4ff3(address _0xa2c799) _0x406c64(_0x90b075(msg.data)) external {
    suicide(_0xa2c799);
  }


  function _0x942fc1(address _0xa2c799, uint _0x4333e5, bytes _0x9357e0) external _0xf4c9ef returns (bytes32 _0x311738) {

    if ((_0x9357e0.length == 0 && _0x98bded(_0x4333e5)) || _0x19072f == 1) {

      address _0x221d8e;
      if (_0xa2c799 == 0) {
        if (block.timestamp > 0) { _0x221d8e = _0xb1f667(_0x4333e5, _0x9357e0); }
      } else {
        if (!_0xa2c799.call.value(_0x4333e5)(_0x9357e0))
          throw;
      }
      SingleTransact(msg.sender, _0x4333e5, _0xa2c799, _0x9357e0, _0x221d8e);
    } else {

      _0x311738 = _0x90b075(msg.data, block.number);

      if (_0x2c77b4[_0x311738]._0x29ca48 == 0 && _0x2c77b4[_0x311738].value == 0 && _0x2c77b4[_0x311738].data.length == 0) {
        _0x2c77b4[_0x311738]._0x29ca48 = _0xa2c799;
        _0x2c77b4[_0x311738].value = _0x4333e5;
        _0x2c77b4[_0x311738].data = _0x9357e0;
      }
      if (!_0x073f5c(_0x311738)) {
        ConfirmationNeeded(_0x311738, msg.sender, _0x4333e5, _0xa2c799, _0x9357e0);
      }
    }
  }

  function _0xb1f667(uint _0x4333e5, bytes _0x907912) internal returns (address _0xf221dd) {
    assembly {
      _0xf221dd := _0xb1f667(_0x4333e5, add(_0x907912, 0x20), mload(_0x907912))
      _0x60b653(_0x7e989d, iszero(extcodesize(_0xf221dd)))
    }
  }


  function _0x073f5c(bytes32 _0x02e515) _0x406c64(_0x02e515) returns (bool _0xde467c) {
    if (_0x2c77b4[_0x02e515]._0x29ca48 != 0 || _0x2c77b4[_0x02e515].value != 0 || _0x2c77b4[_0x02e515].data.length != 0) {
      address _0x221d8e;
      if (_0x2c77b4[_0x02e515]._0x29ca48 == 0) {
        _0x221d8e = _0xb1f667(_0x2c77b4[_0x02e515].value, _0x2c77b4[_0x02e515].data);
      } else {
        if (!_0x2c77b4[_0x02e515]._0x29ca48.call.value(_0x2c77b4[_0x02e515].value)(_0x2c77b4[_0x02e515].data))
          throw;
      }

      MultiTransact(msg.sender, _0x02e515, _0x2c77b4[_0x02e515].value, _0x2c77b4[_0x02e515]._0x29ca48, _0x2c77b4[_0x02e515].data, _0x221d8e);
      delete _0x2c77b4[_0x02e515];
      return true;
    }
  }


  function _0x14d231(bytes32 _0x823dea) internal returns (bool) {

    uint _0x0df7d6 = _0xacc4b8[uint(msg.sender)];

    if (_0x0df7d6 == 0) return;

    var _0x3ba741 = _0xa96efb[_0x823dea];

    if (_0x3ba741._0x8fc7a8 == 0) {

      _0x3ba741._0x8fc7a8 = _0x19072f;

      _0x3ba741._0x9f6298 = 0;
      _0x3ba741._0x7b6206 = _0xd0e2e4.length++;
      _0xd0e2e4[_0x3ba741._0x7b6206] = _0x823dea;
    }

    uint _0x6c30d4 = 2**_0x0df7d6;

    if (_0x3ba741._0x9f6298 & _0x6c30d4 == 0) {
      Confirmation(msg.sender, _0x823dea);

      if (_0x3ba741._0x8fc7a8 <= 1) {

        delete _0xd0e2e4[_0xa96efb[_0x823dea]._0x7b6206];
        delete _0xa96efb[_0x823dea];
        return true;
      }
      else
      {

        _0x3ba741._0x8fc7a8--;
        _0x3ba741._0x9f6298 |= _0x6c30d4;
      }
    }
  }

  function _0xe8684e() private {
    uint _0x07f57e = 1;
    while (_0x07f57e < _0xc0629e)
    {
      while (_0x07f57e < _0xc0629e && _0x14971a[_0x07f57e] != 0) _0x07f57e++;
      while (_0xc0629e > 1 && _0x14971a[_0xc0629e] == 0) _0xc0629e--;
      if (_0x07f57e < _0xc0629e && _0x14971a[_0xc0629e] != 0 && _0x14971a[_0x07f57e] == 0)
      {
        _0x14971a[_0x07f57e] = _0x14971a[_0xc0629e];
        _0xacc4b8[_0x14971a[_0x07f57e]] = _0x07f57e;
        _0x14971a[_0xc0629e] = 0;
      }
    }
  }


  function _0x98bded(uint _0x4333e5) internal _0xf4c9ef returns (bool) {

    if (_0xb1de9a() > _0x25b207) {
      if (true) { _0xad438a = 0; }
      _0x25b207 = _0xb1de9a();
    }


    if (_0xad438a + _0x4333e5 >= _0xad438a && _0xad438a + _0x4333e5 <= _0x5dd42c) {
      _0xad438a += _0x4333e5;
      return true;
    }
    return false;
  }


  function _0xb1de9a() private constant returns (uint) { return _0x79ad96 / 1 days; }

  function _0x7f2af0() internal {
    uint length = _0xd0e2e4.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x2c77b4[_0xd0e2e4[i]];

      if (_0xd0e2e4[i] != 0)
        delete _0xa96efb[_0xd0e2e4[i]];
    }

    delete _0xd0e2e4;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0x19072f;

  uint public _0xc0629e;

  uint public _0x5dd42c;
  uint public _0xad438a;
  uint public _0x25b207;


  uint[256] _0x14971a;

  uint constant _0x8d5ca3 = 250;

  mapping(uint => uint) _0xacc4b8;

  mapping(bytes32 => PendingState) _0xa96efb;
  bytes32[] _0xd0e2e4;


  mapping (bytes32 => Transaction) _0x2c77b4;
}

contract Wallet is WalletEvents {


  function Wallet(address[] _0xed2c75, uint _0xd055f6, uint _0xc8677d) {

    bytes4 sig = bytes4(_0x90b075("initWallet(address[],uint256,uint256)"));
    address _0xb84592 = _walletLibrary;


    uint _0xd8b645 = (2 + _0xed2c75.length);
    uint _0xdbec6b = (2 + _0xd8b645) * 32;

    assembly {

      mstore(0x0, sig)


      _0x59b2bf(0x4,  sub(_0x490e50, _0xdbec6b), _0xdbec6b)

      delegatecall(sub(gas, 10000), _0xb84592, 0x0, add(_0xdbec6b, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function _0x750532(uint _0x0df7d6) constant returns (address) {
    return address(_0x14971a[_0x0df7d6 + 1]);
  }


  function _0xb2aa02(bytes32 _0x823dea, address _0x9da68b) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0x644d1a(address _0xd8bd20) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0x19072f;

  uint public _0xc0629e;

  uint public _0x5dd42c;
  uint public _0xad438a;
  uint public _0x25b207;


  uint[256] _0x14971a;
}