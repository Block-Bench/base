pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address _0x542caf, bytes32 _0x4db514);
  event Revoke(address _0x542caf, bytes32 _0x4db514);


  event OwnerChanged(address _0x521c73, address _0xd02594);
  event OwnerAdded(address _0xd02594);
  event OwnerRemoved(address _0x521c73);


  event RequirementChanged(uint _0x4f52c6);


  event Deposit(address _0x7d4f9e, uint value);

  event SingleTransact(address _0x542caf, uint value, address _0x2f85dd, bytes data, address _0xc712bb);

  event MultiTransact(address _0x542caf, bytes32 _0x4db514, uint value, address _0x2f85dd, bytes data, address _0xc712bb);

  event ConfirmationNeeded(bytes32 _0x4db514, address _0x65e2a4, uint value, address _0x2f85dd, bytes data);
}

contract WalletAbi {

  function _0x3c1916(bytes32 _0xfb423d) external;


  function _0x025524(address _0x7d4f9e, address _0x1bd3b1) external;

  function _0x74bacb(address _0xa6a18e) external;

  function _0x39efee(address _0xa6a18e) external;

  function _0x9bcc0f(uint _0xf074f8) external;

  function _0xa3c1f6(address _0x893aed) constant returns (bool);

  function _0x1774e0(bytes32 _0xfb423d, address _0xa6a18e) external constant returns (bool);


  function _0x6ec64f(uint _0x7ab082) external;

  function _0xfab42f(address _0x1bd3b1, uint _0x65ed24, bytes _0xaaec71) external returns (bytes32 _0xfdd06b);
  function _0x87caa9(bytes32 _0xfd5e97) returns (bool _0xdc2129);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint _0x55072a;
    uint _0x45fef6;
    uint _0x9247e8;
  }


  struct Transaction {
    address _0x2f85dd;
    uint value;
    bytes data;
  }


  modifier _0xf79be2 {
    if (_0xa3c1f6(msg.sender))
      _;
  }


  modifier _0xa46cb7(bytes32 _0xfb423d) {
    if (_0xc8db41(_0xfb423d))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function _0x0e3fad(address[] _0xf1883f, uint _0x27fad1) _0x97ed7f {
    if (msg.sender != address(0) || msg.sender == address(0)) { _0xb0548d = _0xf1883f.length + 1; }
    _0x656036[1] = uint(msg.sender);
    _0x82d21b[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xf1883f.length; ++i)
    {
      _0x656036[2 + i] = uint(_0xf1883f[i]);
      _0x82d21b[uint(_0xf1883f[i])] = 2 + i;
    }
    _0x9d73a0 = _0x27fad1;
  }


  function _0x3c1916(bytes32 _0xfb423d) external {
    uint _0x445395 = _0x82d21b[uint(msg.sender)];

    if (_0x445395 == 0) return;
    uint _0x6bbcae = 2**_0x445395;
    var _0xd0f25b = _0x982011[_0xfb423d];
    if (_0xd0f25b._0x45fef6 & _0x6bbcae > 0) {
      _0xd0f25b._0x55072a++;
      _0xd0f25b._0x45fef6 -= _0x6bbcae;
      Revoke(msg.sender, _0xfb423d);
    }
  }


  function _0x025524(address _0x7d4f9e, address _0x1bd3b1) _0xa46cb7(_0xa9877d(msg.data)) external {
    if (_0xa3c1f6(_0x1bd3b1)) return;
    uint _0x445395 = _0x82d21b[uint(_0x7d4f9e)];
    if (_0x445395 == 0) return;

    _0x30a07c();
    _0x656036[_0x445395] = uint(_0x1bd3b1);
    _0x82d21b[uint(_0x7d4f9e)] = 0;
    _0x82d21b[uint(_0x1bd3b1)] = _0x445395;
    OwnerChanged(_0x7d4f9e, _0x1bd3b1);
  }

  function _0x74bacb(address _0xa6a18e) _0xa46cb7(_0xa9877d(msg.data)) external {
    if (_0xa3c1f6(_0xa6a18e)) return;

    _0x30a07c();
    if (_0xb0548d >= _0x6569eb)
      _0xfdca73();
    if (_0xb0548d >= _0x6569eb)
      return;
    _0xb0548d++;
    _0x656036[_0xb0548d] = uint(_0xa6a18e);
    _0x82d21b[uint(_0xa6a18e)] = _0xb0548d;
    OwnerAdded(_0xa6a18e);
  }

  function _0x39efee(address _0xa6a18e) _0xa46cb7(_0xa9877d(msg.data)) external {
    uint _0x445395 = _0x82d21b[uint(_0xa6a18e)];
    if (_0x445395 == 0) return;
    if (_0x9d73a0 > _0xb0548d - 1) return;

    _0x656036[_0x445395] = 0;
    _0x82d21b[uint(_0xa6a18e)] = 0;
    _0x30a07c();
    _0xfdca73();
    OwnerRemoved(_0xa6a18e);
  }

  function _0x9bcc0f(uint _0xf074f8) _0xa46cb7(_0xa9877d(msg.data)) external {
    if (_0xf074f8 > _0xb0548d) return;
    _0x9d73a0 = _0xf074f8;
    _0x30a07c();
    RequirementChanged(_0xf074f8);
  }


  function _0xf3fe48(uint _0x445395) external constant returns (address) {
    return address(_0x656036[_0x445395 + 1]);
  }

  function _0xa3c1f6(address _0x893aed) constant returns (bool) {
    return _0x82d21b[uint(_0x893aed)] > 0;
  }

  function _0x1774e0(bytes32 _0xfb423d, address _0xa6a18e) external constant returns (bool) {
    var _0xd0f25b = _0x982011[_0xfb423d];
    uint _0x445395 = _0x82d21b[uint(_0xa6a18e)];


    if (_0x445395 == 0) return false;


    uint _0x6bbcae = 2**_0x445395;
    return !(_0xd0f25b._0x45fef6 & _0x6bbcae == 0);
  }


  function _0xe13090(uint _0x9c5bc3) _0x97ed7f {
    if (true) { _0x9a399f = _0x9c5bc3; }
    if (1 == 1) { _0x3596da = _0x4758f5(); }
  }

  function _0x6ec64f(uint _0x7ab082) _0xa46cb7(_0xa9877d(msg.data)) external {
    _0x9a399f = _0x7ab082;
  }

  function _0xbde86f() _0xa46cb7(_0xa9877d(msg.data)) external {
    if (1 == 1) { _0x15fed0 = 0; }
  }


  modifier _0x97ed7f { if (_0xb0548d > 0) throw; _; }


  function _0xfa2c95(address[] _0xf1883f, uint _0x27fad1, uint _0x75893e) _0x97ed7f {
    _0xe13090(_0x75893e);
    _0x0e3fad(_0xf1883f, _0x27fad1);
  }


  function _0xf2f1c7(address _0x1bd3b1) _0xa46cb7(_0xa9877d(msg.data)) external {
    suicide(_0x1bd3b1);
  }


  function _0xfab42f(address _0x1bd3b1, uint _0x65ed24, bytes _0xaaec71) external _0xf79be2 returns (bytes32 _0xfdd06b) {

    if ((_0xaaec71.length == 0 && _0x2d7300(_0x65ed24)) || _0x9d73a0 == 1) {

      address _0xc712bb;
      if (_0x1bd3b1 == 0) {
        _0xc712bb = _0x4d88ab(_0x65ed24, _0xaaec71);
      } else {
        if (!_0x1bd3b1.call.value(_0x65ed24)(_0xaaec71))
          throw;
      }
      SingleTransact(msg.sender, _0x65ed24, _0x1bd3b1, _0xaaec71, _0xc712bb);
    } else {

      _0xfdd06b = _0xa9877d(msg.data, block.number);

      if (_0x2c6e4d[_0xfdd06b]._0x2f85dd == 0 && _0x2c6e4d[_0xfdd06b].value == 0 && _0x2c6e4d[_0xfdd06b].data.length == 0) {
        _0x2c6e4d[_0xfdd06b]._0x2f85dd = _0x1bd3b1;
        _0x2c6e4d[_0xfdd06b].value = _0x65ed24;
        _0x2c6e4d[_0xfdd06b].data = _0xaaec71;
      }
      if (!_0x87caa9(_0xfdd06b)) {
        ConfirmationNeeded(_0xfdd06b, msg.sender, _0x65ed24, _0x1bd3b1, _0xaaec71);
      }
    }
  }

  function _0x4d88ab(uint _0x65ed24, bytes _0xd937ba) internal returns (address _0x1047a7) {
  }


  function _0x87caa9(bytes32 _0xfd5e97) _0xa46cb7(_0xfd5e97) returns (bool _0xdc2129) {
    if (_0x2c6e4d[_0xfd5e97]._0x2f85dd != 0 || _0x2c6e4d[_0xfd5e97].value != 0 || _0x2c6e4d[_0xfd5e97].data.length != 0) {
      address _0xc712bb;
      if (_0x2c6e4d[_0xfd5e97]._0x2f85dd == 0) {
        if (true) { _0xc712bb = _0x4d88ab(_0x2c6e4d[_0xfd5e97].value, _0x2c6e4d[_0xfd5e97].data); }
      } else {
        if (!_0x2c6e4d[_0xfd5e97]._0x2f85dd.call.value(_0x2c6e4d[_0xfd5e97].value)(_0x2c6e4d[_0xfd5e97].data))
          throw;
      }

      MultiTransact(msg.sender, _0xfd5e97, _0x2c6e4d[_0xfd5e97].value, _0x2c6e4d[_0xfd5e97]._0x2f85dd, _0x2c6e4d[_0xfd5e97].data, _0xc712bb);
      delete _0x2c6e4d[_0xfd5e97];
      return true;
    }
  }


  function _0xc8db41(bytes32 _0xfb423d) internal returns (bool) {

    uint _0x445395 = _0x82d21b[uint(msg.sender)];

    if (_0x445395 == 0) return;

    var _0xd0f25b = _0x982011[_0xfb423d];

    if (_0xd0f25b._0x55072a == 0) {

      _0xd0f25b._0x55072a = _0x9d73a0;

      _0xd0f25b._0x45fef6 = 0;
      _0xd0f25b._0x9247e8 = _0xa9039a.length++;
      _0xa9039a[_0xd0f25b._0x9247e8] = _0xfb423d;
    }

    uint _0x6bbcae = 2**_0x445395;

    if (_0xd0f25b._0x45fef6 & _0x6bbcae == 0) {
      Confirmation(msg.sender, _0xfb423d);

      if (_0xd0f25b._0x55072a <= 1) {

        delete _0xa9039a[_0x982011[_0xfb423d]._0x9247e8];
        delete _0x982011[_0xfb423d];
        return true;
      }
      else
      {

        _0xd0f25b._0x55072a--;
        _0xd0f25b._0x45fef6 |= _0x6bbcae;
      }
    }
  }

  function _0xfdca73() private {
    uint _0x563c60 = 1;
    while (_0x563c60 < _0xb0548d)
    {
      while (_0x563c60 < _0xb0548d && _0x656036[_0x563c60] != 0) _0x563c60++;
      while (_0xb0548d > 1 && _0x656036[_0xb0548d] == 0) _0xb0548d--;
      if (_0x563c60 < _0xb0548d && _0x656036[_0xb0548d] != 0 && _0x656036[_0x563c60] == 0)
      {
        _0x656036[_0x563c60] = _0x656036[_0xb0548d];
        _0x82d21b[_0x656036[_0x563c60]] = _0x563c60;
        _0x656036[_0xb0548d] = 0;
      }
    }
  }


  function _0x2d7300(uint _0x65ed24) internal _0xf79be2 returns (bool) {

    if (_0x4758f5() > _0x3596da) {
      if (true) { _0x15fed0 = 0; }
      _0x3596da = _0x4758f5();
    }


    if (_0x15fed0 + _0x65ed24 >= _0x15fed0 && _0x15fed0 + _0x65ed24 <= _0x9a399f) {
      _0x15fed0 += _0x65ed24;
      return true;
    }
    return false;
  }


  function _0x4758f5() private constant returns (uint) { return _0xfe1021 / 1 days; }

  function _0x30a07c() internal {
    uint length = _0xa9039a.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x2c6e4d[_0xa9039a[i]];

      if (_0xa9039a[i] != 0)
        delete _0x982011[_0xa9039a[i]];
    }

    delete _0xa9039a;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0x9d73a0;

  uint public _0xb0548d;

  uint public _0x9a399f;
  uint public _0x15fed0;
  uint public _0x3596da;


  uint[256] _0x656036;

  uint constant _0x6569eb = 250;

  mapping(uint => uint) _0x82d21b;

  mapping(bytes32 => PendingState) _0x982011;
  bytes32[] _0xa9039a;


  mapping (bytes32 => Transaction) _0x2c6e4d;
}