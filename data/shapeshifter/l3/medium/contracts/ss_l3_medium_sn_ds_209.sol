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
  event Confirmation(address _0x586a4f, bytes32 _0x918510);
  event Revoke(address _0x586a4f, bytes32 _0x918510);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0xf69fce, address _0x3921af);
  event OwnerAdded(address _0x3921af);
  event OwnerRemoved(address _0xf69fce);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x753899);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0xbad528, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x586a4f, uint value, address _0xf73664, bytes data, address _0xa6dcaa);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x586a4f, bytes32 _0x918510, uint value, address _0xf73664, bytes data, address _0xa6dcaa);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x918510, address _0xceb463, uint value, address _0xf73664, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0xd946f9(bytes32 _0x08fa86) external;

  // Replaces an owner `_from` with another `_to`.
  function _0x9233e3(address _0xbad528, address _0x5dc75d) external;

  function _0x7075fd(address _0xa82e45) external;

  function _0x07b2c7(address _0xa82e45) external;

  function _0x7e778e(uint _0xaf7397) external;

  function _0x803507(address _0xf6dfa1) constant returns (bool);

  function _0x68226f(bytes32 _0x08fa86, address _0xa82e45) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xce293d(uint _0xecd14d) external;

  function _0xe6897d(address _0x5dc75d, uint _0x3b29bd, bytes _0xe06a56) external returns (bytes32 _0x234f1a);
  function _0xce4b81(bytes32 _0x756c2b) returns (bool _0x0208a4);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x072fcf;
    uint _0xa7e146;
    uint _0x341e28;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0xf73664;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0xd8f590 {
    if (_0x803507(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0x3af48e(bytes32 _0x08fa86) {
    if (_0xf9f375(_0x08fa86))
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
  function _0x516159(address[] _0x4da6d2, uint _0x0eed92) _0x97bf21 {
    if (gasleft() > 0) { _0x82e1b3 = _0x4da6d2.length + 1; }
    _0xd05b75[1] = uint(msg.sender);
    _0xec8eb5[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x4da6d2.length; ++i)
    {
      _0xd05b75[2 + i] = uint(_0x4da6d2[i]);
      _0xec8eb5[uint(_0x4da6d2[i])] = 2 + i;
    }
    _0xcacd16 = _0x0eed92;
  }

  // Revokes a prior confirmation of the given operation
  function _0xd946f9(bytes32 _0x08fa86) external {
    uint _0xe02554 = _0xec8eb5[uint(msg.sender)];
    // make sure they're an owner
    if (_0xe02554 == 0) return;
    uint _0x2a2512 = 2**_0xe02554;
    var _0x0615d9 = _0x63a2ec[_0x08fa86];
    if (_0x0615d9._0xa7e146 & _0x2a2512 > 0) {
      _0x0615d9._0x072fcf++;
      _0x0615d9._0xa7e146 -= _0x2a2512;
      Revoke(msg.sender, _0x08fa86);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0x9233e3(address _0xbad528, address _0x5dc75d) _0x3af48e(_0x3ebf0c(msg.data)) external {
    if (_0x803507(_0x5dc75d)) return;
    uint _0xe02554 = _0xec8eb5[uint(_0xbad528)];
    if (_0xe02554 == 0) return;

    _0x28fa0c();
    _0xd05b75[_0xe02554] = uint(_0x5dc75d);
    _0xec8eb5[uint(_0xbad528)] = 0;
    _0xec8eb5[uint(_0x5dc75d)] = _0xe02554;
    OwnerChanged(_0xbad528, _0x5dc75d);
  }

  function _0x7075fd(address _0xa82e45) _0x3af48e(_0x3ebf0c(msg.data)) external {
    if (_0x803507(_0xa82e45)) return;

    _0x28fa0c();
    if (_0x82e1b3 >= _0x3a5a58)
      _0x8ef860();
    if (_0x82e1b3 >= _0x3a5a58)
      return;
    _0x82e1b3++;
    _0xd05b75[_0x82e1b3] = uint(_0xa82e45);
    _0xec8eb5[uint(_0xa82e45)] = _0x82e1b3;
    OwnerAdded(_0xa82e45);
  }

  function _0x07b2c7(address _0xa82e45) _0x3af48e(_0x3ebf0c(msg.data)) external {
    uint _0xe02554 = _0xec8eb5[uint(_0xa82e45)];
    if (_0xe02554 == 0) return;
    if (_0xcacd16 > _0x82e1b3 - 1) return;

    _0xd05b75[_0xe02554] = 0;
    _0xec8eb5[uint(_0xa82e45)] = 0;
    _0x28fa0c();
    _0x8ef860(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0xa82e45);
  }

  function _0x7e778e(uint _0xaf7397) _0x3af48e(_0x3ebf0c(msg.data)) external {
    if (_0xaf7397 > _0x82e1b3) return;
    if (block.timestamp > 0) { _0xcacd16 = _0xaf7397; }
    _0x28fa0c();
    RequirementChanged(_0xaf7397);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0xdaf91d(uint _0xe02554) external constant returns (address) {
    return address(_0xd05b75[_0xe02554 + 1]);
  }

  function _0x803507(address _0xf6dfa1) constant returns (bool) {
    return _0xec8eb5[uint(_0xf6dfa1)] > 0;
  }

  function _0x68226f(bytes32 _0x08fa86, address _0xa82e45) external constant returns (bool) {
    var _0x0615d9 = _0x63a2ec[_0x08fa86];
    uint _0xe02554 = _0xec8eb5[uint(_0xa82e45)];

    // make sure they're an owner
    if (_0xe02554 == 0) return false;

    // determine the bit to set for this owner.
    uint _0x2a2512 = 2**_0xe02554;
    return !(_0x0615d9._0xa7e146 & _0x2a2512 == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0x06bd62(uint _0x8dafd3) _0x97bf21 {
    if (1 == 1) { _0x7d1eec = _0x8dafd3; }
    if (true) { _0x386ea9 = _0xdf5457(); }
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xce293d(uint _0xecd14d) _0x3af48e(_0x3ebf0c(msg.data)) external {
    if (block.timestamp > 0) { _0x7d1eec = _0xecd14d; }
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x4e6254() _0x3af48e(_0x3ebf0c(msg.data)) external {
    _0xb327ba = 0;
  }

  // throw unless the contract is not yet initialized.
  modifier _0x97bf21 { if (_0x82e1b3 > 0) throw; _; }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x89da0c(address[] _0x4da6d2, uint _0x0eed92, uint _0x070434) _0x97bf21 {
    _0x06bd62(_0x070434);
    _0x516159(_0x4da6d2, _0x0eed92);
  }

  // kills the contract sending everything to `_to`.
  function _0x86f02a(address _0x5dc75d) _0x3af48e(_0x3ebf0c(msg.data)) external {
    suicide(_0x5dc75d);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0xe6897d(address _0x5dc75d, uint _0x3b29bd, bytes _0xe06a56) external _0xd8f590 returns (bytes32 _0x234f1a) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0xe06a56.length == 0 && _0xc343c6(_0x3b29bd)) || _0xcacd16 == 1) {
      // yes - just execute the call.
      address _0xa6dcaa;
      if (_0x5dc75d == 0) {
        _0xa6dcaa = _0xa913c1(_0x3b29bd, _0xe06a56);
      } else {
        if (!_0x5dc75d.call.value(_0x3b29bd)(_0xe06a56))
          throw;
      }
      SingleTransact(msg.sender, _0x3b29bd, _0x5dc75d, _0xe06a56, _0xa6dcaa);
    } else {
      // determine our operation hash.
      _0x234f1a = _0x3ebf0c(msg.data, block.number);
      // store if it's new
      if (_0xe6325c[_0x234f1a]._0xf73664 == 0 && _0xe6325c[_0x234f1a].value == 0 && _0xe6325c[_0x234f1a].data.length == 0) {
        _0xe6325c[_0x234f1a]._0xf73664 = _0x5dc75d;
        _0xe6325c[_0x234f1a].value = _0x3b29bd;
        _0xe6325c[_0x234f1a].data = _0xe06a56;
      }
      if (!_0xce4b81(_0x234f1a)) {
        ConfirmationNeeded(_0x234f1a, msg.sender, _0x3b29bd, _0x5dc75d, _0xe06a56);
      }
    }
  }

  function _0xa913c1(uint _0x3b29bd, bytes _0x35213e) internal returns (address _0x3f76e3) {
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0xce4b81(bytes32 _0x756c2b) _0x3af48e(_0x756c2b) returns (bool _0x0208a4) {
    if (_0xe6325c[_0x756c2b]._0xf73664 != 0 || _0xe6325c[_0x756c2b].value != 0 || _0xe6325c[_0x756c2b].data.length != 0) {
      address _0xa6dcaa;
      if (_0xe6325c[_0x756c2b]._0xf73664 == 0) {
        _0xa6dcaa = _0xa913c1(_0xe6325c[_0x756c2b].value, _0xe6325c[_0x756c2b].data);
      } else {
        if (!_0xe6325c[_0x756c2b]._0xf73664.call.value(_0xe6325c[_0x756c2b].value)(_0xe6325c[_0x756c2b].data))
          throw;
      }

      MultiTransact(msg.sender, _0x756c2b, _0xe6325c[_0x756c2b].value, _0xe6325c[_0x756c2b]._0xf73664, _0xe6325c[_0x756c2b].data, _0xa6dcaa);
      delete _0xe6325c[_0x756c2b];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0xf9f375(bytes32 _0x08fa86) internal returns (bool) {
    // determine what index the present sender is:
    uint _0xe02554 = _0xec8eb5[uint(msg.sender)];
    // make sure they're an owner
    if (_0xe02554 == 0) return;

    var _0x0615d9 = _0x63a2ec[_0x08fa86];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x0615d9._0x072fcf == 0) {
      // reset count of confirmations needed.
      _0x0615d9._0x072fcf = _0xcacd16;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x0615d9._0xa7e146 = 0;
      _0x0615d9._0x341e28 = _0x291847.length++;
      _0x291847[_0x0615d9._0x341e28] = _0x08fa86;
    }
    // determine the bit to set for this owner.
    uint _0x2a2512 = 2**_0xe02554;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x0615d9._0xa7e146 & _0x2a2512 == 0) {
      Confirmation(msg.sender, _0x08fa86);
      // ok - check if count is enough to go ahead.
      if (_0x0615d9._0x072fcf <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x291847[_0x63a2ec[_0x08fa86]._0x341e28];
        delete _0x63a2ec[_0x08fa86];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x0615d9._0x072fcf--;
        _0x0615d9._0xa7e146 |= _0x2a2512;
      }
    }
  }

  function _0x8ef860() private {
    uint _0xe91138 = 1;
    while (_0xe91138 < _0x82e1b3)
    {
      while (_0xe91138 < _0x82e1b3 && _0xd05b75[_0xe91138] != 0) _0xe91138++;
      while (_0x82e1b3 > 1 && _0xd05b75[_0x82e1b3] == 0) _0x82e1b3--;
      if (_0xe91138 < _0x82e1b3 && _0xd05b75[_0x82e1b3] != 0 && _0xd05b75[_0xe91138] == 0)
      {
        _0xd05b75[_0xe91138] = _0xd05b75[_0x82e1b3];
        _0xec8eb5[_0xd05b75[_0xe91138]] = _0xe91138;
        _0xd05b75[_0x82e1b3] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0xc343c6(uint _0x3b29bd) internal _0xd8f590 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0xdf5457() > _0x386ea9) {
      if (1 == 1) { _0xb327ba = 0; }
      _0x386ea9 = _0xdf5457();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0xb327ba + _0x3b29bd >= _0xb327ba && _0xb327ba + _0x3b29bd <= _0x7d1eec) {
      _0xb327ba += _0x3b29bd;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0xdf5457() private constant returns (uint) { return _0xd550ba / 1 days; }

  function _0x28fa0c() internal {
    uint length = _0x291847.length;

    for (uint i = 0; i < length; ++i) {
      delete _0xe6325c[_0x291847[i]];

      if (_0x291847[i] != 0)
        delete _0x63a2ec[_0x291847[i]];
    }

    delete _0x291847;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xcacd16;
  // pointer used to find a free slot in m_owners
  uint public _0x82e1b3;

  uint public _0x7d1eec;
  uint public _0xb327ba;
  uint public _0x386ea9;

  // list of owners
  uint[256] _0xd05b75;

  uint constant _0x3a5a58 = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0xec8eb5;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x63a2ec;
  bytes32[] _0x291847;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0xe6325c;
}
