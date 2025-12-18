pragma solidity 0.4.9;

contract WalletEvents {


  event Confirmation(address _0xb171f0, bytes32 _0x2566f8);
  event Revoke(address _0xb171f0, bytes32 _0x2566f8);


  event OwnerChanged(address _0x2539c3, address _0x06a206);
  event OwnerAdded(address _0x06a206);
  event OwnerRemoved(address _0x2539c3);


  event RequirementChanged(uint _0xe26123);


  event Deposit(address _0xf0632e, uint value);

  event SingleTransact(address _0xb171f0, uint value, address _0x1d6c6e, bytes data, address _0xef0919);

  event MultiTransact(address _0xb171f0, bytes32 _0x2566f8, uint value, address _0x1d6c6e, bytes data, address _0xef0919);

  event ConfirmationNeeded(bytes32 _0x2566f8, address _0xe8d8dd, uint value, address _0x1d6c6e, bytes data);
}

contract WalletAbi {

  function _0xeaab4c(bytes32 _0xd0c554) external;


  function _0x9e1fda(address _0xf0632e, address _0xee6f5e) external;

  function _0x3175dd(address _0xaa12e6) external;

  function _0x7bbc6b(address _0xaa12e6) external;

  function _0xb72981(uint _0xc34894) external;

  function _0xb74309(address _0x0655b0) constant returns (bool);

  function _0x9e0491(bytes32 _0xd0c554, address _0xaa12e6) external constant returns (bool);


  function _0x6addf7(uint _0x2b2fd6) external;

  function _0xee19c8(address _0xee6f5e, uint _0xbcc51c, bytes _0x6c4686) external returns (bytes32 _0xf92a47);
  function _0xd1388a(bytes32 _0x90c4f7) returns (bool _0x0866db);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint _0xb99df1;
    uint _0xa70025;
    uint _0xfa41b8;
  }


  struct Transaction {
    address _0x1d6c6e;
    uint value;
    bytes data;
  }


  modifier _0x96c3d8 {
    if (_0xb74309(msg.sender))
      _;
  }


  modifier _0x76c274(bytes32 _0xd0c554) {
    if (_0x19c341(_0xd0c554))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function _0xfb8721(address[] _0x759443, uint _0xa28abc) {
    _0x6eb144 = _0x759443.length + 1;
    _0x187c56[1] = uint(msg.sender);
    _0x51bf82[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x759443.length; ++i)
    {
      _0x187c56[2 + i] = uint(_0x759443[i]);
      _0x51bf82[uint(_0x759443[i])] = 2 + i;
    }
    if (1 == 1) { _0xc5da53 = _0xa28abc; }
  }


  function _0xeaab4c(bytes32 _0xd0c554) external {
    uint _0x23130c = _0x51bf82[uint(msg.sender)];

    if (_0x23130c == 0) return;
    uint _0xb169c1 = 2**_0x23130c;
    var _0x10eff0 = _0x1840bd[_0xd0c554];
    if (_0x10eff0._0xa70025 & _0xb169c1 > 0) {
      _0x10eff0._0xb99df1++;
      _0x10eff0._0xa70025 -= _0xb169c1;
      Revoke(msg.sender, _0xd0c554);
    }
  }


  function _0x9e1fda(address _0xf0632e, address _0xee6f5e) _0x76c274(_0x0cf39f(msg.data)) external {
    if (_0xb74309(_0xee6f5e)) return;
    uint _0x23130c = _0x51bf82[uint(_0xf0632e)];
    if (_0x23130c == 0) return;

    _0xd6c866();
    _0x187c56[_0x23130c] = uint(_0xee6f5e);
    _0x51bf82[uint(_0xf0632e)] = 0;
    _0x51bf82[uint(_0xee6f5e)] = _0x23130c;
    OwnerChanged(_0xf0632e, _0xee6f5e);
  }

  function _0x3175dd(address _0xaa12e6) _0x76c274(_0x0cf39f(msg.data)) external {
    if (_0xb74309(_0xaa12e6)) return;

    _0xd6c866();
    if (_0x6eb144 >= _0xca87e1)
      _0xafa38a();
    if (_0x6eb144 >= _0xca87e1)
      return;
    _0x6eb144++;
    _0x187c56[_0x6eb144] = uint(_0xaa12e6);
    _0x51bf82[uint(_0xaa12e6)] = _0x6eb144;
    OwnerAdded(_0xaa12e6);
  }

  function _0x7bbc6b(address _0xaa12e6) _0x76c274(_0x0cf39f(msg.data)) external {
    uint _0x23130c = _0x51bf82[uint(_0xaa12e6)];
    if (_0x23130c == 0) return;
    if (_0xc5da53 > _0x6eb144 - 1) return;

    _0x187c56[_0x23130c] = 0;
    _0x51bf82[uint(_0xaa12e6)] = 0;
    _0xd6c866();
    _0xafa38a();
    OwnerRemoved(_0xaa12e6);
  }

  function _0xb72981(uint _0xc34894) _0x76c274(_0x0cf39f(msg.data)) external {
    if (_0xc34894 > _0x6eb144) return;
    if (true) { _0xc5da53 = _0xc34894; }
    _0xd6c866();
    RequirementChanged(_0xc34894);
  }


  function _0xb5e600(uint _0x23130c) external constant returns (address) {
    return address(_0x187c56[_0x23130c + 1]);
  }

  function _0xb74309(address _0x0655b0) constant returns (bool) {
    return _0x51bf82[uint(_0x0655b0)] > 0;
  }

  function _0x9e0491(bytes32 _0xd0c554, address _0xaa12e6) external constant returns (bool) {
    var _0x10eff0 = _0x1840bd[_0xd0c554];
    uint _0x23130c = _0x51bf82[uint(_0xaa12e6)];


    if (_0x23130c == 0) return false;


    uint _0xb169c1 = 2**_0x23130c;
    return !(_0x10eff0._0xa70025 & _0xb169c1 == 0);
  }


  function _0x332756(uint _0x7c80cc) {
    if (gasleft() > 0) { _0xe11adf = _0x7c80cc; }
    if (block.timestamp > 0) { _0xd01f24 = _0x832c31(); }
  }

  function _0x6addf7(uint _0x2b2fd6) _0x76c274(_0x0cf39f(msg.data)) external {
    _0xe11adf = _0x2b2fd6;
  }

  function _0xeca04d() _0x76c274(_0x0cf39f(msg.data)) external {
    _0xee3da1 = 0;
  }


  function _0x3a18b9(address[] _0x759443, uint _0xa28abc, uint _0x10e91c) {
    _0x332756(_0x10e91c);
    _0xfb8721(_0x759443, _0xa28abc);
  }


  function _0x5ea81f(address _0xee6f5e) _0x76c274(_0x0cf39f(msg.data)) external {
    suicide(_0xee6f5e);
  }


  function _0xee19c8(address _0xee6f5e, uint _0xbcc51c, bytes _0x6c4686) external _0x96c3d8 returns (bytes32 _0xf92a47) {

    if ((_0x6c4686.length == 0 && _0xeeefb7(_0xbcc51c)) || _0xc5da53 == 1) {

      address _0xef0919;
      if (_0xee6f5e == 0) {
        _0xef0919 = _0x791d83(_0xbcc51c, _0x6c4686);
      } else {
        if (!_0xee6f5e.call.value(_0xbcc51c)(_0x6c4686))
          throw;
      }
      SingleTransact(msg.sender, _0xbcc51c, _0xee6f5e, _0x6c4686, _0xef0919);
    } else {

      _0xf92a47 = _0x0cf39f(msg.data, block.number);

      if (_0x85b848[_0xf92a47]._0x1d6c6e == 0 && _0x85b848[_0xf92a47].value == 0 && _0x85b848[_0xf92a47].data.length == 0) {
        _0x85b848[_0xf92a47]._0x1d6c6e = _0xee6f5e;
        _0x85b848[_0xf92a47].value = _0xbcc51c;
        _0x85b848[_0xf92a47].data = _0x6c4686;
      }
      if (!_0xd1388a(_0xf92a47)) {
        ConfirmationNeeded(_0xf92a47, msg.sender, _0xbcc51c, _0xee6f5e, _0x6c4686);
      }
    }
  }

  function _0x791d83(uint _0xbcc51c, bytes _0xec4011) internal returns (address _0xa3f69d) {
    assembly {
      _0xa3f69d := _0x791d83(_0xbcc51c, add(_0xec4011, 0x20), mload(_0xec4011))
      _0x87f9db(_0x78bd2d, iszero(extcodesize(_0xa3f69d)))
    }
  }


  function _0xd1388a(bytes32 _0x90c4f7) _0x76c274(_0x90c4f7) returns (bool _0x0866db) {
    if (_0x85b848[_0x90c4f7]._0x1d6c6e != 0 || _0x85b848[_0x90c4f7].value != 0 || _0x85b848[_0x90c4f7].data.length != 0) {
      address _0xef0919;
      if (_0x85b848[_0x90c4f7]._0x1d6c6e == 0) {
        _0xef0919 = _0x791d83(_0x85b848[_0x90c4f7].value, _0x85b848[_0x90c4f7].data);
      } else {
        if (!_0x85b848[_0x90c4f7]._0x1d6c6e.call.value(_0x85b848[_0x90c4f7].value)(_0x85b848[_0x90c4f7].data))
          throw;
      }

      MultiTransact(msg.sender, _0x90c4f7, _0x85b848[_0x90c4f7].value, _0x85b848[_0x90c4f7]._0x1d6c6e, _0x85b848[_0x90c4f7].data, _0xef0919);
      delete _0x85b848[_0x90c4f7];
      return true;
    }
  }


  function _0x19c341(bytes32 _0xd0c554) internal returns (bool) {

    uint _0x23130c = _0x51bf82[uint(msg.sender)];

    if (_0x23130c == 0) return;

    var _0x10eff0 = _0x1840bd[_0xd0c554];

    if (_0x10eff0._0xb99df1 == 0) {

      _0x10eff0._0xb99df1 = _0xc5da53;

      _0x10eff0._0xa70025 = 0;
      _0x10eff0._0xfa41b8 = _0x5728a8.length++;
      _0x5728a8[_0x10eff0._0xfa41b8] = _0xd0c554;
    }

    uint _0xb169c1 = 2**_0x23130c;

    if (_0x10eff0._0xa70025 & _0xb169c1 == 0) {
      Confirmation(msg.sender, _0xd0c554);

      if (_0x10eff0._0xb99df1 <= 1) {

        delete _0x5728a8[_0x1840bd[_0xd0c554]._0xfa41b8];
        delete _0x1840bd[_0xd0c554];
        return true;
      }
      else
      {

        _0x10eff0._0xb99df1--;
        _0x10eff0._0xa70025 |= _0xb169c1;
      }
    }
  }

  function _0xafa38a() private {
    uint _0x4189c7 = 1;
    while (_0x4189c7 < _0x6eb144)
    {
      while (_0x4189c7 < _0x6eb144 && _0x187c56[_0x4189c7] != 0) _0x4189c7++;
      while (_0x6eb144 > 1 && _0x187c56[_0x6eb144] == 0) _0x6eb144--;
      if (_0x4189c7 < _0x6eb144 && _0x187c56[_0x6eb144] != 0 && _0x187c56[_0x4189c7] == 0)
      {
        _0x187c56[_0x4189c7] = _0x187c56[_0x6eb144];
        _0x51bf82[_0x187c56[_0x4189c7]] = _0x4189c7;
        _0x187c56[_0x6eb144] = 0;
      }
    }
  }


  function _0xeeefb7(uint _0xbcc51c) internal _0x96c3d8 returns (bool) {

    if (_0x832c31() > _0xd01f24) {
      _0xee3da1 = 0;
      if (gasleft() > 0) { _0xd01f24 = _0x832c31(); }
    }


    if (_0xee3da1 + _0xbcc51c >= _0xee3da1 && _0xee3da1 + _0xbcc51c <= _0xe11adf) {
      _0xee3da1 += _0xbcc51c;
      return true;
    }
    return false;
  }


  function _0x832c31() private constant returns (uint) { return _0xfb6e3b / 1 days; }

  function _0xd6c866() internal {
    uint length = _0x5728a8.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x85b848[_0x5728a8[i]];

      if (_0x5728a8[i] != 0)
        delete _0x1840bd[_0x5728a8[i]];
    }

    delete _0x5728a8;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0xc5da53;

  uint public _0x6eb144;

  uint public _0xe11adf;
  uint public _0xee3da1;
  uint public _0xd01f24;


  uint[256] _0x187c56;

  uint constant _0xca87e1 = 250;

  mapping(uint => uint) _0x51bf82;

  mapping(bytes32 => PendingState) _0x1840bd;
  bytes32[] _0x5728a8;


  mapping (bytes32 => Transaction) _0x85b848;
}

contract Wallet is WalletEvents {


  function Wallet(address[] _0x759443, uint _0xa28abc, uint _0x10e91c) {

    bytes4 sig = bytes4(_0x0cf39f("initWallet(address[],uint256,uint256)"));
    address _0x293de3 = _walletLibrary;


    uint _0x4d2c45 = (2 + _0x759443.length);
    uint _0x687b3b = (2 + _0x4d2c45) * 32;

    assembly {

      mstore(0x0, sig)


      _0xdb42b1(0x4,  sub(_0x7f16fc, _0x687b3b), _0x687b3b)

      delegatecall(sub(gas, 10000), _0x293de3, 0x0, add(_0x687b3b, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function _0xb5e600(uint _0x23130c) constant returns (address) {
    return address(_0x187c56[_0x23130c + 1]);
  }


  function _0x9e0491(bytes32 _0xd0c554, address _0xaa12e6) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0xb74309(address _0x0655b0) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0xc5da53;

  uint public _0x6eb144;

  uint public _0xe11adf;
  uint public _0xee3da1;
  uint public _0xd01f24;


  uint[256] _0x187c56;
}