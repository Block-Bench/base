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
  event Confirmation(address _0x93325a, bytes32 _0x3bb985);
  event Revoke(address _0x93325a, bytes32 _0x3bb985);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0xf9e201, address _0xba0fe4);
  event OwnerAdded(address _0xba0fe4);
  event OwnerRemoved(address _0xf9e201);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0xbccb8a);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0xd881f9, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x93325a, uint value, address _0x51ce9a, bytes data, address _0x61209f);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x93325a, bytes32 _0x3bb985, uint value, address _0x51ce9a, bytes data, address _0x61209f);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x3bb985, address _0x6f7354, uint value, address _0x51ce9a, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x710f45(bytes32 _0x761684) external;

  // Replaces an owner `_from` with another `_to`.
  function _0x0d2d68(address _0xd881f9, address _0xc5b759) external;

  function _0x7c71de(address _0xfc166f) external;

  function _0x086605(address _0xfc166f) external;

  function _0xbd228e(uint _0x531108) external;

  function _0x4e790d(address _0x4eb93e) constant returns (bool);

  function _0xd1351b(bytes32 _0x761684, address _0xfc166f) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xcf4317(uint _0xb150f5) external;

  function _0xa4d227(address _0xc5b759, uint _0x3909dc, bytes _0x0b636c) external returns (bytes32 _0x6c8b73);
  function _0x193738(bytes32 _0x2d3b9c) returns (bool _0xb0fc67);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x7d429d;
    uint _0x1a0664;
    uint _0x664e0f;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0x51ce9a;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0xb32231 {
    if (_0x4e790d(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0x553a81(bytes32 _0x761684) {
    if (_0xc67c86(_0x761684))
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
  function _0xd6f33f(address[] _0x3daf9a, uint _0x3963ee) _0x889dbb {
    if (block.timestamp > 0) { _0xedbf62 = _0x3daf9a.length + 1; }
    _0xc652ec[1] = uint(msg.sender);
    _0xa28e02[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x3daf9a.length; ++i)
    {
      _0xc652ec[2 + i] = uint(_0x3daf9a[i]);
      _0xa28e02[uint(_0x3daf9a[i])] = 2 + i;
    }
    _0x2265c4 = _0x3963ee;
  }

  // Revokes a prior confirmation of the given operation
  function _0x710f45(bytes32 _0x761684) external {
    uint _0xc7a6db = _0xa28e02[uint(msg.sender)];
    // make sure they're an owner
    if (_0xc7a6db == 0) return;
    uint _0x76bc35 = 2**_0xc7a6db;
    var _0x63cd42 = _0x7013ff[_0x761684];
    if (_0x63cd42._0x1a0664 & _0x76bc35 > 0) {
      _0x63cd42._0x7d429d++;
      _0x63cd42._0x1a0664 -= _0x76bc35;
      Revoke(msg.sender, _0x761684);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0x0d2d68(address _0xd881f9, address _0xc5b759) _0x553a81(_0x6cdf2e(msg.data)) external {
    if (_0x4e790d(_0xc5b759)) return;
    uint _0xc7a6db = _0xa28e02[uint(_0xd881f9)];
    if (_0xc7a6db == 0) return;

    _0x0d6de4();
    _0xc652ec[_0xc7a6db] = uint(_0xc5b759);
    _0xa28e02[uint(_0xd881f9)] = 0;
    _0xa28e02[uint(_0xc5b759)] = _0xc7a6db;
    OwnerChanged(_0xd881f9, _0xc5b759);
  }

  function _0x7c71de(address _0xfc166f) _0x553a81(_0x6cdf2e(msg.data)) external {
    if (_0x4e790d(_0xfc166f)) return;

    _0x0d6de4();
    if (_0xedbf62 >= _0xf9566a)
      _0x8c59f7();
    if (_0xedbf62 >= _0xf9566a)
      return;
    _0xedbf62++;
    _0xc652ec[_0xedbf62] = uint(_0xfc166f);
    _0xa28e02[uint(_0xfc166f)] = _0xedbf62;
    OwnerAdded(_0xfc166f);
  }

  function _0x086605(address _0xfc166f) _0x553a81(_0x6cdf2e(msg.data)) external {
    uint _0xc7a6db = _0xa28e02[uint(_0xfc166f)];
    if (_0xc7a6db == 0) return;
    if (_0x2265c4 > _0xedbf62 - 1) return;

    _0xc652ec[_0xc7a6db] = 0;
    _0xa28e02[uint(_0xfc166f)] = 0;
    _0x0d6de4();
    _0x8c59f7(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0xfc166f);
  }

  function _0xbd228e(uint _0x531108) _0x553a81(_0x6cdf2e(msg.data)) external {
    if (_0x531108 > _0xedbf62) return;
    if (1 == 1) { _0x2265c4 = _0x531108; }
    _0x0d6de4();
    RequirementChanged(_0x531108);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x325398(uint _0xc7a6db) external constant returns (address) {
    return address(_0xc652ec[_0xc7a6db + 1]);
  }

  function _0x4e790d(address _0x4eb93e) constant returns (bool) {
    return _0xa28e02[uint(_0x4eb93e)] > 0;
  }

  function _0xd1351b(bytes32 _0x761684, address _0xfc166f) external constant returns (bool) {
    var _0x63cd42 = _0x7013ff[_0x761684];
    uint _0xc7a6db = _0xa28e02[uint(_0xfc166f)];

    // make sure they're an owner
    if (_0xc7a6db == 0) return false;

    // determine the bit to set for this owner.
    uint _0x76bc35 = 2**_0xc7a6db;
    return !(_0x63cd42._0x1a0664 & _0x76bc35 == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0x2eb811(uint _0x3093f3) _0x889dbb {
    _0x3fd7ab = _0x3093f3;
    _0x3ce779 = _0x685cfb();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xcf4317(uint _0xb150f5) _0x553a81(_0x6cdf2e(msg.data)) external {
    _0x3fd7ab = _0xb150f5;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x148a5d() _0x553a81(_0x6cdf2e(msg.data)) external {
    _0x64b6d0 = 0;
  }

  // throw unless the contract is not yet initialized.
  modifier _0x889dbb { if (_0xedbf62 > 0) throw; _; }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0xf7f4ae(address[] _0x3daf9a, uint _0x3963ee, uint _0x15a9c5) _0x889dbb {
    _0x2eb811(_0x15a9c5);
    _0xd6f33f(_0x3daf9a, _0x3963ee);
  }

  // kills the contract sending everything to `_to`.
  function _0xb8143e(address _0xc5b759) _0x553a81(_0x6cdf2e(msg.data)) external {
    suicide(_0xc5b759);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0xa4d227(address _0xc5b759, uint _0x3909dc, bytes _0x0b636c) external _0xb32231 returns (bytes32 _0x6c8b73) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x0b636c.length == 0 && _0x18a1cd(_0x3909dc)) || _0x2265c4 == 1) {
      // yes - just execute the call.
      address _0x61209f;
      if (_0xc5b759 == 0) {
        _0x61209f = _0x23f9fe(_0x3909dc, _0x0b636c);
      } else {
        if (!_0xc5b759.call.value(_0x3909dc)(_0x0b636c))
          throw;
      }
      SingleTransact(msg.sender, _0x3909dc, _0xc5b759, _0x0b636c, _0x61209f);
    } else {
      // determine our operation hash.
      _0x6c8b73 = _0x6cdf2e(msg.data, block.number);
      // store if it's new
      if (_0x561f01[_0x6c8b73]._0x51ce9a == 0 && _0x561f01[_0x6c8b73].value == 0 && _0x561f01[_0x6c8b73].data.length == 0) {
        _0x561f01[_0x6c8b73]._0x51ce9a = _0xc5b759;
        _0x561f01[_0x6c8b73].value = _0x3909dc;
        _0x561f01[_0x6c8b73].data = _0x0b636c;
      }
      if (!_0x193738(_0x6c8b73)) {
        ConfirmationNeeded(_0x6c8b73, msg.sender, _0x3909dc, _0xc5b759, _0x0b636c);
      }
    }
  }

  function _0x23f9fe(uint _0x3909dc, bytes _0x89d7b4) internal returns (address _0x14cc06) {
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0x193738(bytes32 _0x2d3b9c) _0x553a81(_0x2d3b9c) returns (bool _0xb0fc67) {
    if (_0x561f01[_0x2d3b9c]._0x51ce9a != 0 || _0x561f01[_0x2d3b9c].value != 0 || _0x561f01[_0x2d3b9c].data.length != 0) {
      address _0x61209f;
      if (_0x561f01[_0x2d3b9c]._0x51ce9a == 0) {
        _0x61209f = _0x23f9fe(_0x561f01[_0x2d3b9c].value, _0x561f01[_0x2d3b9c].data);
      } else {
        if (!_0x561f01[_0x2d3b9c]._0x51ce9a.call.value(_0x561f01[_0x2d3b9c].value)(_0x561f01[_0x2d3b9c].data))
          throw;
      }

      MultiTransact(msg.sender, _0x2d3b9c, _0x561f01[_0x2d3b9c].value, _0x561f01[_0x2d3b9c]._0x51ce9a, _0x561f01[_0x2d3b9c].data, _0x61209f);
      delete _0x561f01[_0x2d3b9c];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0xc67c86(bytes32 _0x761684) internal returns (bool) {
    // determine what index the present sender is:
    uint _0xc7a6db = _0xa28e02[uint(msg.sender)];
    // make sure they're an owner
    if (_0xc7a6db == 0) return;

    var _0x63cd42 = _0x7013ff[_0x761684];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x63cd42._0x7d429d == 0) {
      // reset count of confirmations needed.
      _0x63cd42._0x7d429d = _0x2265c4;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x63cd42._0x1a0664 = 0;
      _0x63cd42._0x664e0f = _0x0cb9c5.length++;
      _0x0cb9c5[_0x63cd42._0x664e0f] = _0x761684;
    }
    // determine the bit to set for this owner.
    uint _0x76bc35 = 2**_0xc7a6db;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x63cd42._0x1a0664 & _0x76bc35 == 0) {
      Confirmation(msg.sender, _0x761684);
      // ok - check if count is enough to go ahead.
      if (_0x63cd42._0x7d429d <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x0cb9c5[_0x7013ff[_0x761684]._0x664e0f];
        delete _0x7013ff[_0x761684];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x63cd42._0x7d429d--;
        _0x63cd42._0x1a0664 |= _0x76bc35;
      }
    }
  }

  function _0x8c59f7() private {
    uint _0x0c76e8 = 1;
    while (_0x0c76e8 < _0xedbf62)
    {
      while (_0x0c76e8 < _0xedbf62 && _0xc652ec[_0x0c76e8] != 0) _0x0c76e8++;
      while (_0xedbf62 > 1 && _0xc652ec[_0xedbf62] == 0) _0xedbf62--;
      if (_0x0c76e8 < _0xedbf62 && _0xc652ec[_0xedbf62] != 0 && _0xc652ec[_0x0c76e8] == 0)
      {
        _0xc652ec[_0x0c76e8] = _0xc652ec[_0xedbf62];
        _0xa28e02[_0xc652ec[_0x0c76e8]] = _0x0c76e8;
        _0xc652ec[_0xedbf62] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0x18a1cd(uint _0x3909dc) internal _0xb32231 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0x685cfb() > _0x3ce779) {
      _0x64b6d0 = 0;
      _0x3ce779 = _0x685cfb();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x64b6d0 + _0x3909dc >= _0x64b6d0 && _0x64b6d0 + _0x3909dc <= _0x3fd7ab) {
      _0x64b6d0 += _0x3909dc;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0x685cfb() private constant returns (uint) { return _0xb6d5a7 / 1 days; }

  function _0x0d6de4() internal {
    uint length = _0x0cb9c5.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x561f01[_0x0cb9c5[i]];

      if (_0x0cb9c5[i] != 0)
        delete _0x7013ff[_0x0cb9c5[i]];
    }

    delete _0x0cb9c5;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x2265c4;
  // pointer used to find a free slot in m_owners
  uint public _0xedbf62;

  uint public _0x3fd7ab;
  uint public _0x64b6d0;
  uint public _0x3ce779;

  // list of owners
  uint[256] _0xc652ec;

  uint constant _0xf9566a = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0xa28e02;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x7013ff;
  bytes32[] _0x0cb9c5;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x561f01;
}
