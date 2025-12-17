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
  event Confirmation(address _0x7894e2, bytes32 _0x95ffe7);
  event Revoke(address _0x7894e2, bytes32 _0x95ffe7);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0x5a7e3b, address _0x7d3a4c);
  event OwnerAdded(address _0x7d3a4c);
  event OwnerRemoved(address _0x5a7e3b);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0xec7967);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0xe22f35, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x7894e2, uint value, address _0x0aa9da, bytes data, address _0x9d7432);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x7894e2, bytes32 _0x95ffe7, uint value, address _0x0aa9da, bytes data, address _0x9d7432);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x95ffe7, address _0xa1dc80, uint value, address _0x0aa9da, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x959824(bytes32 _0x3caa2e) external;

  // Replaces an owner `_from` with another `_to`.
  function _0xba7cd3(address _0xe22f35, address _0x5ce1ae) external;

  function _0xc77c19(address _0xd34872) external;

  function _0xd00c45(address _0xd34872) external;

  function _0x1a7377(uint _0xd545ba) external;

  function _0x676f36(address _0x5e79b0) constant returns (bool);

  function _0x58a6bc(bytes32 _0x3caa2e, address _0xd34872) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x51323d(uint _0xf369b3) external;

  function _0x65e8c9(address _0x5ce1ae, uint _0xd3182e, bytes _0x59ab38) external returns (bytes32 _0x77aa1a);
  function _0xa48465(bytes32 _0xe28a15) returns (bool _0xc0088e);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x697e9e;
    uint _0x3d2cc6;
    uint _0x5accab;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0x0aa9da;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0xd2fbf8 {
    if (_0x676f36(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0x70b42d(bytes32 _0x3caa2e) {
    if (_0xc4203f(_0x3caa2e))
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
  function _0x1d8e9d(address[] _0xbbee45, uint _0x09989e) _0x0c4066 {
    _0x879787 = _0xbbee45.length + 1;
    _0x1a4567[1] = uint(msg.sender);
    _0xf34a92[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xbbee45.length; ++i)
    {
      _0x1a4567[2 + i] = uint(_0xbbee45[i]);
      _0xf34a92[uint(_0xbbee45[i])] = 2 + i;
    }
    _0x90d42a = _0x09989e;
  }

  // Revokes a prior confirmation of the given operation
  function _0x959824(bytes32 _0x3caa2e) external {
    uint _0x23cb7c = _0xf34a92[uint(msg.sender)];
    // make sure they're an owner
    if (_0x23cb7c == 0) return;
    uint _0x5bb877 = 2**_0x23cb7c;
    var _0xeb1f37 = _0xdf56f4[_0x3caa2e];
    if (_0xeb1f37._0x3d2cc6 & _0x5bb877 > 0) {
      _0xeb1f37._0x697e9e++;
      _0xeb1f37._0x3d2cc6 -= _0x5bb877;
      Revoke(msg.sender, _0x3caa2e);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0xba7cd3(address _0xe22f35, address _0x5ce1ae) _0x70b42d(_0xd2161e(msg.data)) external {
    if (_0x676f36(_0x5ce1ae)) return;
    uint _0x23cb7c = _0xf34a92[uint(_0xe22f35)];
    if (_0x23cb7c == 0) return;

    _0x5241a7();
    _0x1a4567[_0x23cb7c] = uint(_0x5ce1ae);
    _0xf34a92[uint(_0xe22f35)] = 0;
    _0xf34a92[uint(_0x5ce1ae)] = _0x23cb7c;
    OwnerChanged(_0xe22f35, _0x5ce1ae);
  }

  function _0xc77c19(address _0xd34872) _0x70b42d(_0xd2161e(msg.data)) external {
    if (_0x676f36(_0xd34872)) return;

    _0x5241a7();
    if (_0x879787 >= _0x282ac5)
      _0x4064c9();
    if (_0x879787 >= _0x282ac5)
      return;
    _0x879787++;
    _0x1a4567[_0x879787] = uint(_0xd34872);
    _0xf34a92[uint(_0xd34872)] = _0x879787;
    OwnerAdded(_0xd34872);
  }

  function _0xd00c45(address _0xd34872) _0x70b42d(_0xd2161e(msg.data)) external {
    uint _0x23cb7c = _0xf34a92[uint(_0xd34872)];
    if (_0x23cb7c == 0) return;
    if (_0x90d42a > _0x879787 - 1) return;

    _0x1a4567[_0x23cb7c] = 0;
    _0xf34a92[uint(_0xd34872)] = 0;
    _0x5241a7();
    _0x4064c9(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0xd34872);
  }

  function _0x1a7377(uint _0xd545ba) _0x70b42d(_0xd2161e(msg.data)) external {
    if (_0xd545ba > _0x879787) return;
    _0x90d42a = _0xd545ba;
    _0x5241a7();
    RequirementChanged(_0xd545ba);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x5d9f78(uint _0x23cb7c) external constant returns (address) {
    return address(_0x1a4567[_0x23cb7c + 1]);
  }

  function _0x676f36(address _0x5e79b0) constant returns (bool) {
    return _0xf34a92[uint(_0x5e79b0)] > 0;
  }

  function _0x58a6bc(bytes32 _0x3caa2e, address _0xd34872) external constant returns (bool) {
    var _0xeb1f37 = _0xdf56f4[_0x3caa2e];
    uint _0x23cb7c = _0xf34a92[uint(_0xd34872)];

    // make sure they're an owner
    if (_0x23cb7c == 0) return false;

    // determine the bit to set for this owner.
    uint _0x5bb877 = 2**_0x23cb7c;
    return !(_0xeb1f37._0x3d2cc6 & _0x5bb877 == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0x71cd34(uint _0x187e8d) _0x0c4066 {
    _0x2bec24 = _0x187e8d;
    _0x58f01d = _0x17615c();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x51323d(uint _0xf369b3) _0x70b42d(_0xd2161e(msg.data)) external {
    _0x2bec24 = _0xf369b3;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x85f625() _0x70b42d(_0xd2161e(msg.data)) external {
    _0x3a89fe = 0;
  }

  // throw unless the contract is not yet initialized.
  modifier _0x0c4066 { if (_0x879787 > 0) throw; _; }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x11a54e(address[] _0xbbee45, uint _0x09989e, uint _0x6d53bc) _0x0c4066 {
    _0x71cd34(_0x6d53bc);
    _0x1d8e9d(_0xbbee45, _0x09989e);
  }

  // kills the contract sending everything to `_to`.
  function _0xc62155(address _0x5ce1ae) _0x70b42d(_0xd2161e(msg.data)) external {
    suicide(_0x5ce1ae);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0x65e8c9(address _0x5ce1ae, uint _0xd3182e, bytes _0x59ab38) external _0xd2fbf8 returns (bytes32 _0x77aa1a) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x59ab38.length == 0 && _0x754ea7(_0xd3182e)) || _0x90d42a == 1) {
      // yes - just execute the call.
      address _0x9d7432;
      if (_0x5ce1ae == 0) {
        _0x9d7432 = _0x53c288(_0xd3182e, _0x59ab38);
      } else {
        if (!_0x5ce1ae.call.value(_0xd3182e)(_0x59ab38))
          throw;
      }
      SingleTransact(msg.sender, _0xd3182e, _0x5ce1ae, _0x59ab38, _0x9d7432);
    } else {
      // determine our operation hash.
      _0x77aa1a = _0xd2161e(msg.data, block.number);
      // store if it's new
      if (_0x14d58b[_0x77aa1a]._0x0aa9da == 0 && _0x14d58b[_0x77aa1a].value == 0 && _0x14d58b[_0x77aa1a].data.length == 0) {
        _0x14d58b[_0x77aa1a]._0x0aa9da = _0x5ce1ae;
        _0x14d58b[_0x77aa1a].value = _0xd3182e;
        _0x14d58b[_0x77aa1a].data = _0x59ab38;
      }
      if (!_0xa48465(_0x77aa1a)) {
        ConfirmationNeeded(_0x77aa1a, msg.sender, _0xd3182e, _0x5ce1ae, _0x59ab38);
      }
    }
  }

  function _0x53c288(uint _0xd3182e, bytes _0x64d710) internal returns (address _0xf007db) {
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0xa48465(bytes32 _0xe28a15) _0x70b42d(_0xe28a15) returns (bool _0xc0088e) {
    if (_0x14d58b[_0xe28a15]._0x0aa9da != 0 || _0x14d58b[_0xe28a15].value != 0 || _0x14d58b[_0xe28a15].data.length != 0) {
      address _0x9d7432;
      if (_0x14d58b[_0xe28a15]._0x0aa9da == 0) {
        _0x9d7432 = _0x53c288(_0x14d58b[_0xe28a15].value, _0x14d58b[_0xe28a15].data);
      } else {
        if (!_0x14d58b[_0xe28a15]._0x0aa9da.call.value(_0x14d58b[_0xe28a15].value)(_0x14d58b[_0xe28a15].data))
          throw;
      }

      MultiTransact(msg.sender, _0xe28a15, _0x14d58b[_0xe28a15].value, _0x14d58b[_0xe28a15]._0x0aa9da, _0x14d58b[_0xe28a15].data, _0x9d7432);
      delete _0x14d58b[_0xe28a15];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0xc4203f(bytes32 _0x3caa2e) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x23cb7c = _0xf34a92[uint(msg.sender)];
    // make sure they're an owner
    if (_0x23cb7c == 0) return;

    var _0xeb1f37 = _0xdf56f4[_0x3caa2e];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0xeb1f37._0x697e9e == 0) {
      // reset count of confirmations needed.
      _0xeb1f37._0x697e9e = _0x90d42a;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0xeb1f37._0x3d2cc6 = 0;
      _0xeb1f37._0x5accab = _0xb8485d.length++;
      _0xb8485d[_0xeb1f37._0x5accab] = _0x3caa2e;
    }
    // determine the bit to set for this owner.
    uint _0x5bb877 = 2**_0x23cb7c;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0xeb1f37._0x3d2cc6 & _0x5bb877 == 0) {
      Confirmation(msg.sender, _0x3caa2e);
      // ok - check if count is enough to go ahead.
      if (_0xeb1f37._0x697e9e <= 1) {
        // enough confirmations: reset and run interior.
        delete _0xb8485d[_0xdf56f4[_0x3caa2e]._0x5accab];
        delete _0xdf56f4[_0x3caa2e];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0xeb1f37._0x697e9e--;
        _0xeb1f37._0x3d2cc6 |= _0x5bb877;
      }
    }
  }

  function _0x4064c9() private {
    uint _0x57fc37 = 1;
    while (_0x57fc37 < _0x879787)
    {
      while (_0x57fc37 < _0x879787 && _0x1a4567[_0x57fc37] != 0) _0x57fc37++;
      while (_0x879787 > 1 && _0x1a4567[_0x879787] == 0) _0x879787--;
      if (_0x57fc37 < _0x879787 && _0x1a4567[_0x879787] != 0 && _0x1a4567[_0x57fc37] == 0)
      {
        _0x1a4567[_0x57fc37] = _0x1a4567[_0x879787];
        _0xf34a92[_0x1a4567[_0x57fc37]] = _0x57fc37;
        _0x1a4567[_0x879787] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0x754ea7(uint _0xd3182e) internal _0xd2fbf8 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0x17615c() > _0x58f01d) {
      _0x3a89fe = 0;
      _0x58f01d = _0x17615c();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x3a89fe + _0xd3182e >= _0x3a89fe && _0x3a89fe + _0xd3182e <= _0x2bec24) {
      _0x3a89fe += _0xd3182e;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0x17615c() private constant returns (uint) { return _0xc44f6c / 1 days; }

  function _0x5241a7() internal {
    uint length = _0xb8485d.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x14d58b[_0xb8485d[i]];

      if (_0xb8485d[i] != 0)
        delete _0xdf56f4[_0xb8485d[i]];
    }

    delete _0xb8485d;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x90d42a;
  // pointer used to find a free slot in m_owners
  uint public _0x879787;

  uint public _0x2bec24;
  uint public _0x3a89fe;
  uint public _0x58f01d;

  // list of owners
  uint[256] _0x1a4567;

  uint constant _0x282ac5 = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0xf34a92;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0xdf56f4;
  bytes32[] _0xb8485d;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x14d58b;
}
