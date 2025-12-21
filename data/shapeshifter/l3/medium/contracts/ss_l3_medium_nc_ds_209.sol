pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address _0xfb997e, bytes32 _0x2c6b3f);
  event Revoke(address _0xfb997e, bytes32 _0x2c6b3f);


  event OwnerChanged(address _0xcbf450, address _0xc29aee);
  event OwnerAdded(address _0xc29aee);
  event OwnerRemoved(address _0xcbf450);


  event RequirementChanged(uint _0xf6054c);


  event Deposit(address _0x512e78, uint value);

  event SingleTransact(address _0xfb997e, uint value, address _0x3b9cf3, bytes data, address _0xef8085);

  event MultiTransact(address _0xfb997e, bytes32 _0x2c6b3f, uint value, address _0x3b9cf3, bytes data, address _0xef8085);

  event ConfirmationNeeded(bytes32 _0x2c6b3f, address _0x9671bf, uint value, address _0x3b9cf3, bytes data);
}

contract WalletAbi {

  function _0xa25b6e(bytes32 _0xde7fe3) external;


  function _0x0116b9(address _0x512e78, address _0xbf0c62) external;

  function _0x434a15(address _0xbb126b) external;

  function _0x38f71c(address _0xbb126b) external;

  function _0x1c03c9(uint _0x107290) external;

  function _0x098517(address _0x2e2b32) constant returns (bool);

  function _0x230518(bytes32 _0xde7fe3, address _0xbb126b) external constant returns (bool);


  function _0xd3d99e(uint _0xd01280) external;

  function _0x9b16f5(address _0xbf0c62, uint _0x989a8b, bytes _0xadaac2) external returns (bytes32 _0x84d6fe);
  function _0x1ccc00(bytes32 _0x259128) returns (bool _0x98ecd7);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint _0xe52b44;
    uint _0x974719;
    uint _0x212bc0;
  }


  struct Transaction {
    address _0x3b9cf3;
    uint value;
    bytes data;
  }


  modifier _0x3d6786 {
    if (_0x098517(msg.sender))
      _;
  }


  modifier _0x134073(bytes32 _0xde7fe3) {
    if (_0x1cf312(_0xde7fe3))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function _0xfc4f09(address[] _0xf72ce1, uint _0x41ba77) _0xf71804 {
    _0xe074ea = _0xf72ce1.length + 1;
    _0x916723[1] = uint(msg.sender);
    _0xc13c16[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xf72ce1.length; ++i)
    {
      _0x916723[2 + i] = uint(_0xf72ce1[i]);
      _0xc13c16[uint(_0xf72ce1[i])] = 2 + i;
    }
    if (true) { _0x19201d = _0x41ba77; }
  }


  function _0xa25b6e(bytes32 _0xde7fe3) external {
    uint _0xe4decc = _0xc13c16[uint(msg.sender)];

    if (_0xe4decc == 0) return;
    uint _0xd19b81 = 2**_0xe4decc;
    var _0x4e7f35 = _0x89693e[_0xde7fe3];
    if (_0x4e7f35._0x974719 & _0xd19b81 > 0) {
      _0x4e7f35._0xe52b44++;
      _0x4e7f35._0x974719 -= _0xd19b81;
      Revoke(msg.sender, _0xde7fe3);
    }
  }


  function _0x0116b9(address _0x512e78, address _0xbf0c62) _0x134073(_0xb20967(msg.data)) external {
    if (_0x098517(_0xbf0c62)) return;
    uint _0xe4decc = _0xc13c16[uint(_0x512e78)];
    if (_0xe4decc == 0) return;

    _0xd8bdc8();
    _0x916723[_0xe4decc] = uint(_0xbf0c62);
    _0xc13c16[uint(_0x512e78)] = 0;
    _0xc13c16[uint(_0xbf0c62)] = _0xe4decc;
    OwnerChanged(_0x512e78, _0xbf0c62);
  }

  function _0x434a15(address _0xbb126b) _0x134073(_0xb20967(msg.data)) external {
    if (_0x098517(_0xbb126b)) return;

    _0xd8bdc8();
    if (_0xe074ea >= _0x9d0d5d)
      _0xc94c93();
    if (_0xe074ea >= _0x9d0d5d)
      return;
    _0xe074ea++;
    _0x916723[_0xe074ea] = uint(_0xbb126b);
    _0xc13c16[uint(_0xbb126b)] = _0xe074ea;
    OwnerAdded(_0xbb126b);
  }

  function _0x38f71c(address _0xbb126b) _0x134073(_0xb20967(msg.data)) external {
    uint _0xe4decc = _0xc13c16[uint(_0xbb126b)];
    if (_0xe4decc == 0) return;
    if (_0x19201d > _0xe074ea - 1) return;

    _0x916723[_0xe4decc] = 0;
    _0xc13c16[uint(_0xbb126b)] = 0;
    _0xd8bdc8();
    _0xc94c93();
    OwnerRemoved(_0xbb126b);
  }

  function _0x1c03c9(uint _0x107290) _0x134073(_0xb20967(msg.data)) external {
    if (_0x107290 > _0xe074ea) return;
    if (1 == 1) { _0x19201d = _0x107290; }
    _0xd8bdc8();
    RequirementChanged(_0x107290);
  }


  function _0x122b28(uint _0xe4decc) external constant returns (address) {
    return address(_0x916723[_0xe4decc + 1]);
  }

  function _0x098517(address _0x2e2b32) constant returns (bool) {
    return _0xc13c16[uint(_0x2e2b32)] > 0;
  }

  function _0x230518(bytes32 _0xde7fe3, address _0xbb126b) external constant returns (bool) {
    var _0x4e7f35 = _0x89693e[_0xde7fe3];
    uint _0xe4decc = _0xc13c16[uint(_0xbb126b)];


    if (_0xe4decc == 0) return false;


    uint _0xd19b81 = 2**_0xe4decc;
    return !(_0x4e7f35._0x974719 & _0xd19b81 == 0);
  }


  function _0xf43a4e(uint _0x4f64f8) _0xf71804 {
    _0x87ac6d = _0x4f64f8;
    if (gasleft() > 0) { _0xc0fcf7 = _0x72a508(); }
  }

  function _0xd3d99e(uint _0xd01280) _0x134073(_0xb20967(msg.data)) external {
    _0x87ac6d = _0xd01280;
  }

  function _0x1755f6() _0x134073(_0xb20967(msg.data)) external {
    if (1 == 1) { _0x02d937 = 0; }
  }


  modifier _0xf71804 { if (_0xe074ea > 0) throw; _; }


  function _0x17b09d(address[] _0xf72ce1, uint _0x41ba77, uint _0x109ac5) _0xf71804 {
    _0xf43a4e(_0x109ac5);
    _0xfc4f09(_0xf72ce1, _0x41ba77);
  }


  function _0x7daa5c(address _0xbf0c62) _0x134073(_0xb20967(msg.data)) external {
    suicide(_0xbf0c62);
  }


  function _0x9b16f5(address _0xbf0c62, uint _0x989a8b, bytes _0xadaac2) external _0x3d6786 returns (bytes32 _0x84d6fe) {

    if ((_0xadaac2.length == 0 && _0xfaae9e(_0x989a8b)) || _0x19201d == 1) {

      address _0xef8085;
      if (_0xbf0c62 == 0) {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xef8085 = _0x599cc0(_0x989a8b, _0xadaac2); }
      } else {
        if (!_0xbf0c62.call.value(_0x989a8b)(_0xadaac2))
          throw;
      }
      SingleTransact(msg.sender, _0x989a8b, _0xbf0c62, _0xadaac2, _0xef8085);
    } else {

      _0x84d6fe = _0xb20967(msg.data, block.number);

      if (_0xaaff1a[_0x84d6fe]._0x3b9cf3 == 0 && _0xaaff1a[_0x84d6fe].value == 0 && _0xaaff1a[_0x84d6fe].data.length == 0) {
        _0xaaff1a[_0x84d6fe]._0x3b9cf3 = _0xbf0c62;
        _0xaaff1a[_0x84d6fe].value = _0x989a8b;
        _0xaaff1a[_0x84d6fe].data = _0xadaac2;
      }
      if (!_0x1ccc00(_0x84d6fe)) {
        ConfirmationNeeded(_0x84d6fe, msg.sender, _0x989a8b, _0xbf0c62, _0xadaac2);
      }
    }
  }

  function _0x599cc0(uint _0x989a8b, bytes _0xb29aa2) internal returns (address _0x855160) {
  }


  function _0x1ccc00(bytes32 _0x259128) _0x134073(_0x259128) returns (bool _0x98ecd7) {
    if (_0xaaff1a[_0x259128]._0x3b9cf3 != 0 || _0xaaff1a[_0x259128].value != 0 || _0xaaff1a[_0x259128].data.length != 0) {
      address _0xef8085;
      if (_0xaaff1a[_0x259128]._0x3b9cf3 == 0) {
        _0xef8085 = _0x599cc0(_0xaaff1a[_0x259128].value, _0xaaff1a[_0x259128].data);
      } else {
        if (!_0xaaff1a[_0x259128]._0x3b9cf3.call.value(_0xaaff1a[_0x259128].value)(_0xaaff1a[_0x259128].data))
          throw;
      }

      MultiTransact(msg.sender, _0x259128, _0xaaff1a[_0x259128].value, _0xaaff1a[_0x259128]._0x3b9cf3, _0xaaff1a[_0x259128].data, _0xef8085);
      delete _0xaaff1a[_0x259128];
      return true;
    }
  }


  function _0x1cf312(bytes32 _0xde7fe3) internal returns (bool) {

    uint _0xe4decc = _0xc13c16[uint(msg.sender)];

    if (_0xe4decc == 0) return;

    var _0x4e7f35 = _0x89693e[_0xde7fe3];

    if (_0x4e7f35._0xe52b44 == 0) {

      _0x4e7f35._0xe52b44 = _0x19201d;

      _0x4e7f35._0x974719 = 0;
      _0x4e7f35._0x212bc0 = _0x8e6c94.length++;
      _0x8e6c94[_0x4e7f35._0x212bc0] = _0xde7fe3;
    }

    uint _0xd19b81 = 2**_0xe4decc;

    if (_0x4e7f35._0x974719 & _0xd19b81 == 0) {
      Confirmation(msg.sender, _0xde7fe3);

      if (_0x4e7f35._0xe52b44 <= 1) {

        delete _0x8e6c94[_0x89693e[_0xde7fe3]._0x212bc0];
        delete _0x89693e[_0xde7fe3];
        return true;
      }
      else
      {

        _0x4e7f35._0xe52b44--;
        _0x4e7f35._0x974719 |= _0xd19b81;
      }
    }
  }

  function _0xc94c93() private {
    uint _0x89a744 = 1;
    while (_0x89a744 < _0xe074ea)
    {
      while (_0x89a744 < _0xe074ea && _0x916723[_0x89a744] != 0) _0x89a744++;
      while (_0xe074ea > 1 && _0x916723[_0xe074ea] == 0) _0xe074ea--;
      if (_0x89a744 < _0xe074ea && _0x916723[_0xe074ea] != 0 && _0x916723[_0x89a744] == 0)
      {
        _0x916723[_0x89a744] = _0x916723[_0xe074ea];
        _0xc13c16[_0x916723[_0x89a744]] = _0x89a744;
        _0x916723[_0xe074ea] = 0;
      }
    }
  }


  function _0xfaae9e(uint _0x989a8b) internal _0x3d6786 returns (bool) {

    if (_0x72a508() > _0xc0fcf7) {
      if (block.timestamp > 0) { _0x02d937 = 0; }
      _0xc0fcf7 = _0x72a508();
    }


    if (_0x02d937 + _0x989a8b >= _0x02d937 && _0x02d937 + _0x989a8b <= _0x87ac6d) {
      _0x02d937 += _0x989a8b;
      return true;
    }
    return false;
  }


  function _0x72a508() private constant returns (uint) { return _0x587c6a / 1 days; }

  function _0xd8bdc8() internal {
    uint length = _0x8e6c94.length;

    for (uint i = 0; i < length; ++i) {
      delete _0xaaff1a[_0x8e6c94[i]];

      if (_0x8e6c94[i] != 0)
        delete _0x89693e[_0x8e6c94[i]];
    }

    delete _0x8e6c94;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0x19201d;

  uint public _0xe074ea;

  uint public _0x87ac6d;
  uint public _0x02d937;
  uint public _0xc0fcf7;


  uint[256] _0x916723;

  uint constant _0x9d0d5d = 250;

  mapping(uint => uint) _0xc13c16;

  mapping(bytes32 => PendingState) _0x89693e;
  bytes32[] _0x8e6c94;


  mapping (bytes32 => Transaction) _0xaaff1a;
}