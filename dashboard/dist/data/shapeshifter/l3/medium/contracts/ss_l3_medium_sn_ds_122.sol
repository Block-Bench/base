// 0xa657491c1e7f16adb39b9b60e87bbb8d93988bc3#code
//sol Wallet
// Multi-sig, daily-limited account proxy/wallet.
// @authors:
// Gav Wood <g@ethdev.com>
// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a
// single, or, crucially, each of a number of, designated owners.
// usage:
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the
// interior is executed.

pragma solidity ^0.4.9;

contract WalletEvents {
  // EVENTS

  // this contract only has six types of events: it can accept a confirmation, in which case
  // we record owner and operation (hash) alongside it.
  event Confirmation(address _0x61ada9, bytes32 _0x44c9bd);
  event Revoke(address _0x61ada9, bytes32 _0x44c9bd);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0x8e39ae, address _0x6b12f5);
  event OwnerAdded(address _0x6b12f5);
  event OwnerRemoved(address _0x8e39ae);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x862867);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0xe5c671, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x61ada9, uint value, address _0xe7f958, bytes data, address _0x6a73c9);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x61ada9, bytes32 _0x44c9bd, uint value, address _0xe7f958, bytes data, address _0x6a73c9);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x44c9bd, address _0x30f711, uint value, address _0xe7f958, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x0f02d7(bytes32 _0xd23b90) external;

  // Replaces an owner `_from` with another `_to`.
  function _0x37c92b(address _0xe5c671, address _0xba3a9c) external;

  function _0x78a8ca(address _0x49e0f7) external;

  function _0xab73e8(address _0x49e0f7) external;

  function _0x40a7b4(uint _0x78a746) external;

  function _0xe47472(address _0x4342c2) constant returns (bool);

  function _0x02d7da(bytes32 _0xd23b90, address _0x49e0f7) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xebe892(uint _0xde2434) external;

  function _0x2c6bd8(address _0xba3a9c, uint _0xbc8a62, bytes _0x5dcdf9) external returns (bytes32 _0x309a1e);
  function _0x9afe25(bytes32 _0x32e89a) returns (bool _0x6c4525);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0xa94248;
    uint _0xbc4b8f;
    uint _0xcbbb72;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0xe7f958;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0xdd4c35 {
    if (_0xe47472(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0xe2b215(bytes32 _0xd23b90) {
    if (_0x0d988b(_0xd23b90))
      _;
  }

  // METHODS

  // gets called when no other function matches
  function() payable {
    // just being sent some cash?
    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }

  // constructor is given number of sigs required to do protected "onlymanyowners" transactions
  // as well as the selection of addresses capable of confirming them.
  function _0xeed7ff(address[] _0xfeaa9e, uint _0xef1491) {
    _0x98733a = _0xfeaa9e.length + 1;
    _0x7c7396[1] = uint(msg.sender);
    _0xc3d3b1[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xfeaa9e.length; ++i)
    {
      _0x7c7396[2 + i] = uint(_0xfeaa9e[i]);
      _0xc3d3b1[uint(_0xfeaa9e[i])] = 2 + i;
    }
    _0x9d3d8a = _0xef1491;
  }

  // Revokes a prior confirmation of the given operation
  function _0x0f02d7(bytes32 _0xd23b90) external {
    uint _0x868014 = _0xc3d3b1[uint(msg.sender)];
    // make sure they're an owner
    if (_0x868014 == 0) return;
    uint _0xb4b629 = 2**_0x868014;
    var _0x1bf723 = _0x6145ef[_0xd23b90];
    if (_0x1bf723._0xbc4b8f & _0xb4b629 > 0) {
      _0x1bf723._0xa94248++;
      _0x1bf723._0xbc4b8f -= _0xb4b629;
      Revoke(msg.sender, _0xd23b90);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0x37c92b(address _0xe5c671, address _0xba3a9c) _0xe2b215(_0x0eb722(msg.data)) external {
    if (_0xe47472(_0xba3a9c)) return;
    uint _0x868014 = _0xc3d3b1[uint(_0xe5c671)];
    if (_0x868014 == 0) return;

    _0x655dc0();
    _0x7c7396[_0x868014] = uint(_0xba3a9c);
    _0xc3d3b1[uint(_0xe5c671)] = 0;
    _0xc3d3b1[uint(_0xba3a9c)] = _0x868014;
    OwnerChanged(_0xe5c671, _0xba3a9c);
  }

  function _0x78a8ca(address _0x49e0f7) _0xe2b215(_0x0eb722(msg.data)) external {
    if (_0xe47472(_0x49e0f7)) return;

    _0x655dc0();
    if (_0x98733a >= _0x49f2ca)
      _0xa3fc23();
    if (_0x98733a >= _0x49f2ca)
      return;
    _0x98733a++;
    _0x7c7396[_0x98733a] = uint(_0x49e0f7);
    _0xc3d3b1[uint(_0x49e0f7)] = _0x98733a;
    OwnerAdded(_0x49e0f7);
  }

  function _0xab73e8(address _0x49e0f7) _0xe2b215(_0x0eb722(msg.data)) external {
    uint _0x868014 = _0xc3d3b1[uint(_0x49e0f7)];
    if (_0x868014 == 0) return;
    if (_0x9d3d8a > _0x98733a - 1) return;

    _0x7c7396[_0x868014] = 0;
    _0xc3d3b1[uint(_0x49e0f7)] = 0;
    _0x655dc0();
    _0xa3fc23(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0x49e0f7);
  }

  function _0x40a7b4(uint _0x78a746) _0xe2b215(_0x0eb722(msg.data)) external {
    if (_0x78a746 > _0x98733a) return;
    _0x9d3d8a = _0x78a746;
    _0x655dc0();
    RequirementChanged(_0x78a746);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x28f1c8(uint _0x868014) external constant returns (address) {
    return address(_0x7c7396[_0x868014 + 1]);
  }

  function _0xe47472(address _0x4342c2) constant returns (bool) {
    return _0xc3d3b1[uint(_0x4342c2)] > 0;
  }

  function _0x02d7da(bytes32 _0xd23b90, address _0x49e0f7) external constant returns (bool) {
    var _0x1bf723 = _0x6145ef[_0xd23b90];
    uint _0x868014 = _0xc3d3b1[uint(_0x49e0f7)];

    // make sure they're an owner
    if (_0x868014 == 0) return false;

    // determine the bit to set for this owner.
    uint _0xb4b629 = 2**_0x868014;
    return !(_0x1bf723._0xbc4b8f & _0xb4b629 == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0xded1d4(uint _0xcf2439) {
    _0x93e64f = _0xcf2439;
    _0xd2ce4a = _0x80fe96();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xebe892(uint _0xde2434) _0xe2b215(_0x0eb722(msg.data)) external {
    _0x93e64f = _0xde2434;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x34b3a0() _0xe2b215(_0x0eb722(msg.data)) external {
    _0x27671f = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x4b09b4(address[] _0xfeaa9e, uint _0xef1491, uint _0xc15d73) {
    _0xded1d4(_0xc15d73);
    _0xeed7ff(_0xfeaa9e, _0xef1491);
  }

  // kills the contract sending everything to `_to`.
  function _0xd3eca5(address _0xba3a9c) _0xe2b215(_0x0eb722(msg.data)) external {
    suicide(_0xba3a9c);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0x2c6bd8(address _0xba3a9c, uint _0xbc8a62, bytes _0x5dcdf9) external _0xdd4c35 returns (bytes32 _0x309a1e) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x5dcdf9.length == 0 && _0xdf9169(_0xbc8a62)) || _0x9d3d8a == 1) {
      // yes - just execute the call.
      address _0x6a73c9;
      if (_0xba3a9c == 0) {
        _0x6a73c9 = _0x7a3eb8(_0xbc8a62, _0x5dcdf9);
      } else {
        if (!_0xba3a9c.call.value(_0xbc8a62)(_0x5dcdf9))
          throw;
      }
      SingleTransact(msg.sender, _0xbc8a62, _0xba3a9c, _0x5dcdf9, _0x6a73c9);
    } else {
      // determine our operation hash.
      _0x309a1e = _0x0eb722(msg.data, block.number);
      // store if it's new
      if (_0x38d6a4[_0x309a1e]._0xe7f958 == 0 && _0x38d6a4[_0x309a1e].value == 0 && _0x38d6a4[_0x309a1e].data.length == 0) {
        _0x38d6a4[_0x309a1e]._0xe7f958 = _0xba3a9c;
        _0x38d6a4[_0x309a1e].value = _0xbc8a62;
        _0x38d6a4[_0x309a1e].data = _0x5dcdf9;
      }
      if (!_0x9afe25(_0x309a1e)) {
        ConfirmationNeeded(_0x309a1e, msg.sender, _0xbc8a62, _0xba3a9c, _0x5dcdf9);
      }
    }
  }

  function _0x7a3eb8(uint _0xbc8a62, bytes _0x6e769b) internal returns (address _0xef19ca) {
    assembly {
      _0xef19ca := _0x7a3eb8(_0xbc8a62, add(_0x6e769b, 0x20), mload(_0x6e769b))
      _0x03f108(_0x5a2ef2, iszero(extcodesize(_0xef19ca)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0x9afe25(bytes32 _0x32e89a) _0xe2b215(_0x32e89a) returns (bool _0x6c4525) {
    if (_0x38d6a4[_0x32e89a]._0xe7f958 != 0 || _0x38d6a4[_0x32e89a].value != 0 || _0x38d6a4[_0x32e89a].data.length != 0) {
      address _0x6a73c9;
      if (_0x38d6a4[_0x32e89a]._0xe7f958 == 0) {
        if (gasleft() > 0) { _0x6a73c9 = _0x7a3eb8(_0x38d6a4[_0x32e89a].value, _0x38d6a4[_0x32e89a].data); }
      } else {
        if (!_0x38d6a4[_0x32e89a]._0xe7f958.call.value(_0x38d6a4[_0x32e89a].value)(_0x38d6a4[_0x32e89a].data))
          throw;
      }

      MultiTransact(msg.sender, _0x32e89a, _0x38d6a4[_0x32e89a].value, _0x38d6a4[_0x32e89a]._0xe7f958, _0x38d6a4[_0x32e89a].data, _0x6a73c9);
      delete _0x38d6a4[_0x32e89a];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0x0d988b(bytes32 _0xd23b90) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x868014 = _0xc3d3b1[uint(msg.sender)];
    // make sure they're an owner
    if (_0x868014 == 0) return;

    var _0x1bf723 = _0x6145ef[_0xd23b90];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x1bf723._0xa94248 == 0) {
      // reset count of confirmations needed.
      _0x1bf723._0xa94248 = _0x9d3d8a;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x1bf723._0xbc4b8f = 0;
      _0x1bf723._0xcbbb72 = _0xa9e2d2.length++;
      _0xa9e2d2[_0x1bf723._0xcbbb72] = _0xd23b90;
    }
    // determine the bit to set for this owner.
    uint _0xb4b629 = 2**_0x868014;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x1bf723._0xbc4b8f & _0xb4b629 == 0) {
      Confirmation(msg.sender, _0xd23b90);
      // ok - check if count is enough to go ahead.
      if (_0x1bf723._0xa94248 <= 1) {
        // enough confirmations: reset and run interior.
        delete _0xa9e2d2[_0x6145ef[_0xd23b90]._0xcbbb72];
        delete _0x6145ef[_0xd23b90];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x1bf723._0xa94248--;
        _0x1bf723._0xbc4b8f |= _0xb4b629;
      }
    }
  }

  function _0xa3fc23() private {
    uint _0xc89796 = 1;
    while (_0xc89796 < _0x98733a)
    {
      while (_0xc89796 < _0x98733a && _0x7c7396[_0xc89796] != 0) _0xc89796++;
      while (_0x98733a > 1 && _0x7c7396[_0x98733a] == 0) _0x98733a--;
      if (_0xc89796 < _0x98733a && _0x7c7396[_0x98733a] != 0 && _0x7c7396[_0xc89796] == 0)
      {
        _0x7c7396[_0xc89796] = _0x7c7396[_0x98733a];
        _0xc3d3b1[_0x7c7396[_0xc89796]] = _0xc89796;
        _0x7c7396[_0x98733a] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0xdf9169(uint _0xbc8a62) internal _0xdd4c35 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0x80fe96() > _0xd2ce4a) {
      _0x27671f = 0;
      _0xd2ce4a = _0x80fe96();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x27671f + _0xbc8a62 >= _0x27671f && _0x27671f + _0xbc8a62 <= _0x93e64f) {
      _0x27671f += _0xbc8a62;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0x80fe96() private constant returns (uint) { return _0xd37359 / 1 days; }

  function _0x655dc0() internal {
    uint length = _0xa9e2d2.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x38d6a4[_0xa9e2d2[i]];

      if (_0xa9e2d2[i] != 0)
        delete _0x6145ef[_0xa9e2d2[i]];
    }

    delete _0xa9e2d2;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x9d3d8a;
  // pointer used to find a free slot in m_owners
  uint public _0x98733a;

  uint public _0x93e64f;
  uint public _0x27671f;
  uint public _0xd2ce4a;

  // list of owners
  uint[256] _0x7c7396;

  uint constant _0x49f2ca = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0xc3d3b1;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x6145ef;
  bytes32[] _0xa9e2d2;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x38d6a4;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0xfeaa9e, uint _0xef1491, uint _0xc15d73) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0x0eb722("initWallet(address[],uint256,uint256)"));
    address _0x039016 = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0xd1df8a = (2 + _0xfeaa9e.length);
    uint _0x09dbbf = (2 + _0xd1df8a) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0x5c1a6f(0x4,  sub(_0x7a8326, _0x09dbbf), _0x09dbbf)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0x039016, 0x0, add(_0x09dbbf, 0x4), 0x0, 0x0)
    }
  }

  // METHODS

  // gets called when no other function matches
  function() payable {
    // just being sent some cash?
    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x28f1c8(uint _0x868014) constant returns (address) {
    return address(_0x7c7396[_0x868014 + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0x02d7da(bytes32 _0xd23b90, address _0x49e0f7) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0xe47472(address _0x4342c2) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x9d3d8a;
  // pointer used to find a free slot in m_owners
  uint public _0x98733a;

  uint public _0x93e64f;
  uint public _0x27671f;
  uint public _0xd2ce4a;

  // list of owners
  uint[256] _0x7c7396;
}