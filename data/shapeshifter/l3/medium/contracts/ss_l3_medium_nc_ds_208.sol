pragma solidity 0.4.9;

contract WalletEvents {


  event Confirmation(address _0xf729ad, bytes32 _0x3c232a);
  event Revoke(address _0xf729ad, bytes32 _0x3c232a);


  event OwnerChanged(address _0x3ca6e7, address _0x189c1d);
  event OwnerAdded(address _0x189c1d);
  event OwnerRemoved(address _0x3ca6e7);


  event RequirementChanged(uint _0x985df5);


  event Deposit(address _0x07c509, uint value);

  event SingleTransact(address _0xf729ad, uint value, address _0x7cb1b6, bytes data, address _0xf4722e);

  event MultiTransact(address _0xf729ad, bytes32 _0x3c232a, uint value, address _0x7cb1b6, bytes data, address _0xf4722e);

  event ConfirmationNeeded(bytes32 _0x3c232a, address _0x84cc41, uint value, address _0x7cb1b6, bytes data);
}

contract WalletAbi {

  function _0x24b64d(bytes32 _0x1670d9) external;


  function _0xc227d6(address _0x07c509, address _0xaf2049) external;

  function _0xcd17af(address _0x460b5f) external;

  function _0x3f3415(address _0x460b5f) external;

  function _0x4bbea5(uint _0x3424ac) external;

  function _0x2807e8(address _0x061caf) constant returns (bool);

  function _0xab1eae(bytes32 _0x1670d9, address _0x460b5f) external constant returns (bool);


  function _0x8ee74b(uint _0x26e292) external;

  function _0xf7f350(address _0xaf2049, uint _0x3b645b, bytes _0x58948e) external returns (bytes32 _0x820098);
  function _0xbf244c(bytes32 _0x1b064c) returns (bool _0x48f00d);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint _0x7ec6c2;
    uint _0xac937e;
    uint _0x5865d2;
  }


  struct Transaction {
    address _0x7cb1b6;
    uint value;
    bytes data;
  }


  modifier _0xc7f247 {
    if (_0x2807e8(msg.sender))
      _;
  }


  modifier _0xe6c156(bytes32 _0x1670d9) {
    if (_0xe04e3e(_0x1670d9))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function _0x7b4ccc(address[] _0xa9f0ad, uint _0x8aede8) {
    _0x4b5266 = _0xa9f0ad.length + 1;
    _0x5731b3[1] = uint(msg.sender);
    _0x18dacb[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xa9f0ad.length; ++i)
    {
      _0x5731b3[2 + i] = uint(_0xa9f0ad[i]);
      _0x18dacb[uint(_0xa9f0ad[i])] = 2 + i;
    }
    _0xd2f902 = _0x8aede8;
  }


  function _0x24b64d(bytes32 _0x1670d9) external {
    uint _0x501d74 = _0x18dacb[uint(msg.sender)];

    if (_0x501d74 == 0) return;
    uint _0x9243ac = 2**_0x501d74;
    var _0xe04733 = _0x93f2a9[_0x1670d9];
    if (_0xe04733._0xac937e & _0x9243ac > 0) {
      _0xe04733._0x7ec6c2++;
      _0xe04733._0xac937e -= _0x9243ac;
      Revoke(msg.sender, _0x1670d9);
    }
  }


  function _0xc227d6(address _0x07c509, address _0xaf2049) _0xe6c156(_0xe6a661(msg.data)) external {
    if (_0x2807e8(_0xaf2049)) return;
    uint _0x501d74 = _0x18dacb[uint(_0x07c509)];
    if (_0x501d74 == 0) return;

    _0x3525b9();
    _0x5731b3[_0x501d74] = uint(_0xaf2049);
    _0x18dacb[uint(_0x07c509)] = 0;
    _0x18dacb[uint(_0xaf2049)] = _0x501d74;
    OwnerChanged(_0x07c509, _0xaf2049);
  }

  function _0xcd17af(address _0x460b5f) _0xe6c156(_0xe6a661(msg.data)) external {
    if (_0x2807e8(_0x460b5f)) return;

    _0x3525b9();
    if (_0x4b5266 >= _0xf341d9)
      _0xf9a33a();
    if (_0x4b5266 >= _0xf341d9)
      return;
    _0x4b5266++;
    _0x5731b3[_0x4b5266] = uint(_0x460b5f);
    _0x18dacb[uint(_0x460b5f)] = _0x4b5266;
    OwnerAdded(_0x460b5f);
  }

  function _0x3f3415(address _0x460b5f) _0xe6c156(_0xe6a661(msg.data)) external {
    uint _0x501d74 = _0x18dacb[uint(_0x460b5f)];
    if (_0x501d74 == 0) return;
    if (_0xd2f902 > _0x4b5266 - 1) return;

    _0x5731b3[_0x501d74] = 0;
    _0x18dacb[uint(_0x460b5f)] = 0;
    _0x3525b9();
    _0xf9a33a();
    OwnerRemoved(_0x460b5f);
  }

  function _0x4bbea5(uint _0x3424ac) _0xe6c156(_0xe6a661(msg.data)) external {
    if (_0x3424ac > _0x4b5266) return;
    _0xd2f902 = _0x3424ac;
    _0x3525b9();
    RequirementChanged(_0x3424ac);
  }


  function _0x4a30e9(uint _0x501d74) external constant returns (address) {
    return address(_0x5731b3[_0x501d74 + 1]);
  }

  function _0x2807e8(address _0x061caf) constant returns (bool) {
    return _0x18dacb[uint(_0x061caf)] > 0;
  }

  function _0xab1eae(bytes32 _0x1670d9, address _0x460b5f) external constant returns (bool) {
    var _0xe04733 = _0x93f2a9[_0x1670d9];
    uint _0x501d74 = _0x18dacb[uint(_0x460b5f)];


    if (_0x501d74 == 0) return false;


    uint _0x9243ac = 2**_0x501d74;
    return !(_0xe04733._0xac937e & _0x9243ac == 0);
  }


  function _0xca03f0(uint _0xaeab42) {
    _0xa64413 = _0xaeab42;
    if (block.timestamp > 0) { _0xa95930 = _0x654693(); }
  }

  function _0x8ee74b(uint _0x26e292) _0xe6c156(_0xe6a661(msg.data)) external {
    if (gasleft() > 0) { _0xa64413 = _0x26e292; }
  }

  function _0x09790d() _0xe6c156(_0xe6a661(msg.data)) external {
    if (gasleft() > 0) { _0x58a9be = 0; }
  }


  function _0x20af1b(address[] _0xa9f0ad, uint _0x8aede8, uint _0xecd9c9) {
    _0xca03f0(_0xecd9c9);
    _0x7b4ccc(_0xa9f0ad, _0x8aede8);
  }


  function _0xdb2cce(address _0xaf2049) _0xe6c156(_0xe6a661(msg.data)) external {
    suicide(_0xaf2049);
  }


  function _0xf7f350(address _0xaf2049, uint _0x3b645b, bytes _0x58948e) external _0xc7f247 returns (bytes32 _0x820098) {

    if ((_0x58948e.length == 0 && _0x5032b8(_0x3b645b)) || _0xd2f902 == 1) {

      address _0xf4722e;
      if (_0xaf2049 == 0) {
        _0xf4722e = _0xa2ebcc(_0x3b645b, _0x58948e);
      } else {
        if (!_0xaf2049.call.value(_0x3b645b)(_0x58948e))
          throw;
      }
      SingleTransact(msg.sender, _0x3b645b, _0xaf2049, _0x58948e, _0xf4722e);
    } else {

      _0x820098 = _0xe6a661(msg.data, block.number);

      if (_0x726566[_0x820098]._0x7cb1b6 == 0 && _0x726566[_0x820098].value == 0 && _0x726566[_0x820098].data.length == 0) {
        _0x726566[_0x820098]._0x7cb1b6 = _0xaf2049;
        _0x726566[_0x820098].value = _0x3b645b;
        _0x726566[_0x820098].data = _0x58948e;
      }
      if (!_0xbf244c(_0x820098)) {
        ConfirmationNeeded(_0x820098, msg.sender, _0x3b645b, _0xaf2049, _0x58948e);
      }
    }
  }

  function _0xa2ebcc(uint _0x3b645b, bytes _0xb0c784) internal returns (address _0x8ae8b9) {
    assembly {
      _0x8ae8b9 := _0xa2ebcc(_0x3b645b, add(_0xb0c784, 0x20), mload(_0xb0c784))
      _0x673957(_0x2d0b73, iszero(extcodesize(_0x8ae8b9)))
    }
  }


  function _0xbf244c(bytes32 _0x1b064c) _0xe6c156(_0x1b064c) returns (bool _0x48f00d) {
    if (_0x726566[_0x1b064c]._0x7cb1b6 != 0 || _0x726566[_0x1b064c].value != 0 || _0x726566[_0x1b064c].data.length != 0) {
      address _0xf4722e;
      if (_0x726566[_0x1b064c]._0x7cb1b6 == 0) {
        _0xf4722e = _0xa2ebcc(_0x726566[_0x1b064c].value, _0x726566[_0x1b064c].data);
      } else {
        if (!_0x726566[_0x1b064c]._0x7cb1b6.call.value(_0x726566[_0x1b064c].value)(_0x726566[_0x1b064c].data))
          throw;
      }

      MultiTransact(msg.sender, _0x1b064c, _0x726566[_0x1b064c].value, _0x726566[_0x1b064c]._0x7cb1b6, _0x726566[_0x1b064c].data, _0xf4722e);
      delete _0x726566[_0x1b064c];
      return true;
    }
  }


  function _0xe04e3e(bytes32 _0x1670d9) internal returns (bool) {

    uint _0x501d74 = _0x18dacb[uint(msg.sender)];

    if (_0x501d74 == 0) return;

    var _0xe04733 = _0x93f2a9[_0x1670d9];

    if (_0xe04733._0x7ec6c2 == 0) {

      _0xe04733._0x7ec6c2 = _0xd2f902;

      _0xe04733._0xac937e = 0;
      _0xe04733._0x5865d2 = _0x540955.length++;
      _0x540955[_0xe04733._0x5865d2] = _0x1670d9;
    }

    uint _0x9243ac = 2**_0x501d74;

    if (_0xe04733._0xac937e & _0x9243ac == 0) {
      Confirmation(msg.sender, _0x1670d9);

      if (_0xe04733._0x7ec6c2 <= 1) {

        delete _0x540955[_0x93f2a9[_0x1670d9]._0x5865d2];
        delete _0x93f2a9[_0x1670d9];
        return true;
      }
      else
      {

        _0xe04733._0x7ec6c2--;
        _0xe04733._0xac937e |= _0x9243ac;
      }
    }
  }

  function _0xf9a33a() private {
    uint _0xcdfafc = 1;
    while (_0xcdfafc < _0x4b5266)
    {
      while (_0xcdfafc < _0x4b5266 && _0x5731b3[_0xcdfafc] != 0) _0xcdfafc++;
      while (_0x4b5266 > 1 && _0x5731b3[_0x4b5266] == 0) _0x4b5266--;
      if (_0xcdfafc < _0x4b5266 && _0x5731b3[_0x4b5266] != 0 && _0x5731b3[_0xcdfafc] == 0)
      {
        _0x5731b3[_0xcdfafc] = _0x5731b3[_0x4b5266];
        _0x18dacb[_0x5731b3[_0xcdfafc]] = _0xcdfafc;
        _0x5731b3[_0x4b5266] = 0;
      }
    }
  }


  function _0x5032b8(uint _0x3b645b) internal _0xc7f247 returns (bool) {

    if (_0x654693() > _0xa95930) {
      _0x58a9be = 0;
      _0xa95930 = _0x654693();
    }


    if (_0x58a9be + _0x3b645b >= _0x58a9be && _0x58a9be + _0x3b645b <= _0xa64413) {
      _0x58a9be += _0x3b645b;
      return true;
    }
    return false;
  }


  function _0x654693() private constant returns (uint) { return _0xb0fc33 / 1 days; }

  function _0x3525b9() internal {
    uint length = _0x540955.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x726566[_0x540955[i]];

      if (_0x540955[i] != 0)
        delete _0x93f2a9[_0x540955[i]];
    }

    delete _0x540955;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0xd2f902;

  uint public _0x4b5266;

  uint public _0xa64413;
  uint public _0x58a9be;
  uint public _0xa95930;


  uint[256] _0x5731b3;

  uint constant _0xf341d9 = 250;

  mapping(uint => uint) _0x18dacb;

  mapping(bytes32 => PendingState) _0x93f2a9;
  bytes32[] _0x540955;


  mapping (bytes32 => Transaction) _0x726566;
}

contract Wallet is WalletEvents {


  function Wallet(address[] _0xa9f0ad, uint _0x8aede8, uint _0xecd9c9) {

    bytes4 sig = bytes4(_0xe6a661("initWallet(address[],uint256,uint256)"));
    address _0x52280c = _walletLibrary;


    uint _0x87a80a = (2 + _0xa9f0ad.length);
    uint _0x832fcc = (2 + _0x87a80a) * 32;

    assembly {

      mstore(0x0, sig)


      _0x42e22f(0x4,  sub(_0xed52d9, _0x832fcc), _0x832fcc)

      delegatecall(sub(gas, 10000), _0x52280c, 0x0, add(_0x832fcc, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function _0x4a30e9(uint _0x501d74) constant returns (address) {
    return address(_0x5731b3[_0x501d74 + 1]);
  }


  function _0xab1eae(bytes32 _0x1670d9, address _0x460b5f) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0x2807e8(address _0x061caf) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public _0xd2f902;

  uint public _0x4b5266;

  uint public _0xa64413;
  uint public _0x58a9be;
  uint public _0xa95930;


  uint[256] _0x5731b3;
}