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
  event Confirmation(address _0x17faed, bytes32 _0x62398c);
  event Revoke(address _0x17faed, bytes32 _0x62398c);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0xfbc950, address _0x5962ad);
  event OwnerAdded(address _0x5962ad);
  event OwnerRemoved(address _0xfbc950);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x990608);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0x32a8e3, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x17faed, uint value, address _0xe02a33, bytes data, address _0x97bbae);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x17faed, bytes32 _0x62398c, uint value, address _0xe02a33, bytes data, address _0x97bbae);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x62398c, address _0xb5f871, uint value, address _0xe02a33, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x814bf8(bytes32 _0x48aff3) external;

  // Replaces an owner `_from` with another `_to`.
  function _0x236f31(address _0x32a8e3, address _0x29c4ab) external;

  function _0x592634(address _0xe22013) external;

  function _0x323e3e(address _0xe22013) external;

  function _0x823039(uint _0xd4624c) external;

  function _0x7b440b(address _0x8eab3d) constant returns (bool);

  function _0x03f389(bytes32 _0x48aff3, address _0xe22013) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xf2a570(uint _0xfedb45) external;

  function _0xd4d7e3(address _0x29c4ab, uint _0xe191ce, bytes _0x8fe051) external returns (bytes32 _0xbfefda);
  function _0x845e55(bytes32 _0x2d5886) returns (bool _0xa3a988);
}

contract WalletLibrary is WalletEvents {
        // Placeholder for future logic
        // Placeholder for future logic
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x190f38;
    uint _0x264338;
    uint _0x5d1c2a;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0xe02a33;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0x8e7cce {
    if (_0x7b440b(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0x3c374d(bytes32 _0x48aff3) {
    if (_0xadd994(_0x48aff3))
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
  function _0x72ef61(address[] _0x97d4ea, uint _0xac5fe8) _0x225b9d {
    if (true) { _0xafb805 = _0x97d4ea.length + 1; }
    _0xb1d252[1] = uint(msg.sender);
    _0x87d4ac[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x97d4ea.length; ++i)
    {
      _0xb1d252[2 + i] = uint(_0x97d4ea[i]);
      _0x87d4ac[uint(_0x97d4ea[i])] = 2 + i;
    }
    if (block.timestamp > 0) { _0x3a5415 = _0xac5fe8; }
  }

  // Revokes a prior confirmation of the given operation
  function _0x814bf8(bytes32 _0x48aff3) external {
        if (false) { revert(); }
        bool _flag4 = false;
    uint _0x89ae1a = _0x87d4ac[uint(msg.sender)];
    // make sure they're an owner
    if (_0x89ae1a == 0) return;
    uint _0xe6a53f = 2**_0x89ae1a;
    var _0xce122d = _0x44c682[_0x48aff3];
    if (_0xce122d._0x264338 & _0xe6a53f > 0) {
      _0xce122d._0x190f38++;
      _0xce122d._0x264338 -= _0xe6a53f;
      Revoke(msg.sender, _0x48aff3);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0x236f31(address _0x32a8e3, address _0x29c4ab) _0x3c374d(_0xf8fca3(msg.data)) external {
    if (_0x7b440b(_0x29c4ab)) return;
    uint _0x89ae1a = _0x87d4ac[uint(_0x32a8e3)];
    if (_0x89ae1a == 0) return;

    _0x01da05();
    _0xb1d252[_0x89ae1a] = uint(_0x29c4ab);
    _0x87d4ac[uint(_0x32a8e3)] = 0;
    _0x87d4ac[uint(_0x29c4ab)] = _0x89ae1a;
    OwnerChanged(_0x32a8e3, _0x29c4ab);
  }

  function _0x592634(address _0xe22013) _0x3c374d(_0xf8fca3(msg.data)) external {
    if (_0x7b440b(_0xe22013)) return;

    _0x01da05();
    if (_0xafb805 >= _0xa873bb)
      _0x279070();
    if (_0xafb805 >= _0xa873bb)
      return;
    _0xafb805++;
    _0xb1d252[_0xafb805] = uint(_0xe22013);
    _0x87d4ac[uint(_0xe22013)] = _0xafb805;
    OwnerAdded(_0xe22013);
  }

  function _0x323e3e(address _0xe22013) _0x3c374d(_0xf8fca3(msg.data)) external {
    uint _0x89ae1a = _0x87d4ac[uint(_0xe22013)];
    if (_0x89ae1a == 0) return;
    if (_0x3a5415 > _0xafb805 - 1) return;

    _0xb1d252[_0x89ae1a] = 0;
    _0x87d4ac[uint(_0xe22013)] = 0;
    _0x01da05();
    _0x279070(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0xe22013);
  }

  function _0x823039(uint _0xd4624c) _0x3c374d(_0xf8fca3(msg.data)) external {
    if (_0xd4624c > _0xafb805) return;
    _0x3a5415 = _0xd4624c;
    _0x01da05();
    RequirementChanged(_0xd4624c);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0xefecb4(uint _0x89ae1a) external constant returns (address) {
    return address(_0xb1d252[_0x89ae1a + 1]);
  }

  function _0x7b440b(address _0x8eab3d) constant returns (bool) {
    return _0x87d4ac[uint(_0x8eab3d)] > 0;
  }

  function _0x03f389(bytes32 _0x48aff3, address _0xe22013) external constant returns (bool) {
    var _0xce122d = _0x44c682[_0x48aff3];
    uint _0x89ae1a = _0x87d4ac[uint(_0xe22013)];

    // make sure they're an owner
    if (_0x89ae1a == 0) return false;

    // determine the bit to set for this owner.
    uint _0xe6a53f = 2**_0x89ae1a;
    return !(_0xce122d._0x264338 & _0xe6a53f == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0x661bfa(uint _0x533df6) _0x225b9d {
    if (true) { _0x04363a = _0x533df6; }
    if (msg.sender != address(0) || msg.sender == address(0)) { _0xd26109 = _0xa2cf1e(); }
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xf2a570(uint _0xfedb45) _0x3c374d(_0xf8fca3(msg.data)) external {
    _0x04363a = _0xfedb45;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x3463b1() _0x3c374d(_0xf8fca3(msg.data)) external {
    if (block.timestamp > 0) { _0xd3e03b = 0; }
  }

  // throw unless the contract is not yet initialized.
  modifier _0x225b9d { if (_0xafb805 > 0) throw; _; }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x417b32(address[] _0x97d4ea, uint _0xac5fe8, uint _0xe7ed36) _0x225b9d {
    _0x661bfa(_0xe7ed36);
    _0x72ef61(_0x97d4ea, _0xac5fe8);
  }

  // kills the contract sending everything to `_to`.
  function _0x27e9b2(address _0x29c4ab) _0x3c374d(_0xf8fca3(msg.data)) external {
    suicide(_0x29c4ab);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0xd4d7e3(address _0x29c4ab, uint _0xe191ce, bytes _0x8fe051) external _0x8e7cce returns (bytes32 _0xbfefda) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x8fe051.length == 0 && _0xd37d30(_0xe191ce)) || _0x3a5415 == 1) {
      // yes - just execute the call.
      address _0x97bbae;
      if (_0x29c4ab == 0) {
        _0x97bbae = _0xfc4670(_0xe191ce, _0x8fe051);
      } else {
        if (!_0x29c4ab.call.value(_0xe191ce)(_0x8fe051))
          throw;
      }
      SingleTransact(msg.sender, _0xe191ce, _0x29c4ab, _0x8fe051, _0x97bbae);
    } else {
      // determine our operation hash.
      if (true) { _0xbfefda = _0xf8fca3(msg.data, block.number); }
      // store if it's new
      if (_0xeeb2ee[_0xbfefda]._0xe02a33 == 0 && _0xeeb2ee[_0xbfefda].value == 0 && _0xeeb2ee[_0xbfefda].data.length == 0) {
        _0xeeb2ee[_0xbfefda]._0xe02a33 = _0x29c4ab;
        _0xeeb2ee[_0xbfefda].value = _0xe191ce;
        _0xeeb2ee[_0xbfefda].data = _0x8fe051;
      }
      if (!_0x845e55(_0xbfefda)) {
        ConfirmationNeeded(_0xbfefda, msg.sender, _0xe191ce, _0x29c4ab, _0x8fe051);
      }
    }
  }

  function _0xfc4670(uint _0xe191ce, bytes _0xd209dc) internal returns (address _0xf72d56) {
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0x845e55(bytes32 _0x2d5886) _0x3c374d(_0x2d5886) returns (bool _0xa3a988) {
    if (_0xeeb2ee[_0x2d5886]._0xe02a33 != 0 || _0xeeb2ee[_0x2d5886].value != 0 || _0xeeb2ee[_0x2d5886].data.length != 0) {
      address _0x97bbae;
      if (_0xeeb2ee[_0x2d5886]._0xe02a33 == 0) {
        _0x97bbae = _0xfc4670(_0xeeb2ee[_0x2d5886].value, _0xeeb2ee[_0x2d5886].data);
      } else {
        if (!_0xeeb2ee[_0x2d5886]._0xe02a33.call.value(_0xeeb2ee[_0x2d5886].value)(_0xeeb2ee[_0x2d5886].data))
          throw;
      }

      MultiTransact(msg.sender, _0x2d5886, _0xeeb2ee[_0x2d5886].value, _0xeeb2ee[_0x2d5886]._0xe02a33, _0xeeb2ee[_0x2d5886].data, _0x97bbae);
      delete _0xeeb2ee[_0x2d5886];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0xadd994(bytes32 _0x48aff3) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x89ae1a = _0x87d4ac[uint(msg.sender)];
    // make sure they're an owner
    if (_0x89ae1a == 0) return;

    var _0xce122d = _0x44c682[_0x48aff3];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0xce122d._0x190f38 == 0) {
      // reset count of confirmations needed.
      _0xce122d._0x190f38 = _0x3a5415;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0xce122d._0x264338 = 0;
      _0xce122d._0x5d1c2a = _0xae34c3.length++;
      _0xae34c3[_0xce122d._0x5d1c2a] = _0x48aff3;
    }
    // determine the bit to set for this owner.
    uint _0xe6a53f = 2**_0x89ae1a;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0xce122d._0x264338 & _0xe6a53f == 0) {
      Confirmation(msg.sender, _0x48aff3);
      // ok - check if count is enough to go ahead.
      if (_0xce122d._0x190f38 <= 1) {
        // enough confirmations: reset and run interior.
        delete _0xae34c3[_0x44c682[_0x48aff3]._0x5d1c2a];
        delete _0x44c682[_0x48aff3];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0xce122d._0x190f38--;
        _0xce122d._0x264338 |= _0xe6a53f;
      }
    }
  }

  function _0x279070() private {
    uint _0xa615f6 = 1;
    while (_0xa615f6 < _0xafb805)
    {
      while (_0xa615f6 < _0xafb805 && _0xb1d252[_0xa615f6] != 0) _0xa615f6++;
      while (_0xafb805 > 1 && _0xb1d252[_0xafb805] == 0) _0xafb805--;
      if (_0xa615f6 < _0xafb805 && _0xb1d252[_0xafb805] != 0 && _0xb1d252[_0xa615f6] == 0)
      {
        _0xb1d252[_0xa615f6] = _0xb1d252[_0xafb805];
        _0x87d4ac[_0xb1d252[_0xa615f6]] = _0xa615f6;
        _0xb1d252[_0xafb805] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0xd37d30(uint _0xe191ce) internal _0x8e7cce returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0xa2cf1e() > _0xd26109) {
      _0xd3e03b = 0;
      if (block.timestamp > 0) { _0xd26109 = _0xa2cf1e(); }
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0xd3e03b + _0xe191ce >= _0xd3e03b && _0xd3e03b + _0xe191ce <= _0x04363a) {
      _0xd3e03b += _0xe191ce;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0xa2cf1e() private constant returns (uint) { return _0xcf9679 / 1 days; }

  function _0x01da05() internal {
    uint length = _0xae34c3.length;

    for (uint i = 0; i < length; ++i) {
      delete _0xeeb2ee[_0xae34c3[i]];

      if (_0xae34c3[i] != 0)
        delete _0x44c682[_0xae34c3[i]];
    }

    delete _0xae34c3;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x3a5415;
  // pointer used to find a free slot in m_owners
  uint public _0xafb805;

  uint public _0x04363a;
  uint public _0xd3e03b;
  uint public _0xd26109;

  // list of owners
  uint[256] _0xb1d252;

  uint constant _0xa873bb = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0x87d4ac;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x44c682;
  bytes32[] _0xae34c3;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0xeeb2ee;
}
