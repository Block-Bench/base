// Multi-sig, daily-limited account proxy/wallet.
// @authors:
// Gav Wood <g@ethdev.com>
// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a
// single, or, crucially, each of a number of, designated owners.
// usage:
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the
// interior is executed.

pragma solidity 0.4.9; /* originally ^0.4.9, but doesn't compile with ^0.4.11 */

contract WalletEvents {
  // EVENTS

  // this contract only has six types of events: it can accept a confirmation, in which case
  // we record owner and operation (hash) alongside it.
  event Confirmation(address _0xccfdeb, bytes32 _0x5c8a15);
  event Revoke(address _0xccfdeb, bytes32 _0x5c8a15);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0xf77a25, address _0x01893b);
  event OwnerAdded(address _0x01893b);
  event OwnerRemoved(address _0xf77a25);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0xa7fac3);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0x076b1a, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0xccfdeb, uint value, address _0x1155b3, bytes data, address _0xcb1f7c);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0xccfdeb, bytes32 _0x5c8a15, uint value, address _0x1155b3, bytes data, address _0xcb1f7c);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x5c8a15, address _0xa291ec, uint value, address _0x1155b3, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x5024a3(bytes32 _0xafad71) external;

  // Replaces an owner `_from` with another `_to`.
  function _0xeaa1d2(address _0x076b1a, address _0x04e367) external;

  function _0xaa097c(address _0xb6fcfc) external;

  function _0x94a8e0(address _0xb6fcfc) external;

  function _0xb411e5(uint _0xb8f716) external;

  function _0x26c677(address _0x5b1534) constant returns (bool);

  function _0x9af4d6(bytes32 _0xafad71, address _0xb6fcfc) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x351e9a(uint _0x96ca46) external;

  function _0xd95054(address _0x04e367, uint _0x774927, bytes _0xfdac2d) external returns (bytes32 _0x984376);
  function _0xb831bb(bytes32 _0x8b45c2) returns (bool _0x431f72);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0xd238be;
    uint _0xcd0440;
    uint _0xc174d6;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0x1155b3;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0x842c9f {
    if (_0x26c677(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0x8e40f9(bytes32 _0xafad71) {
    if (_0x26a80d(_0xafad71))
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
  function _0x1abfbe(address[] _0x37df09, uint _0xa23094) {
    _0xe016c4 = _0x37df09.length + 1;
    _0x525e84[1] = uint(msg.sender);
    _0x78d24c[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x37df09.length; ++i)
    {
      _0x525e84[2 + i] = uint(_0x37df09[i]);
      _0x78d24c[uint(_0x37df09[i])] = 2 + i;
    }
    if (gasleft() > 0) { _0xdd381c = _0xa23094; }
  }

  // Revokes a prior confirmation of the given operation
  function _0x5024a3(bytes32 _0xafad71) external {
    uint _0x9d9d19 = _0x78d24c[uint(msg.sender)];
    // make sure they're an owner
    if (_0x9d9d19 == 0) return;
    uint _0xbd5f6d = 2**_0x9d9d19;
    var _0x50356f = _0x6153c2[_0xafad71];
    if (_0x50356f._0xcd0440 & _0xbd5f6d > 0) {
      _0x50356f._0xd238be++;
      _0x50356f._0xcd0440 -= _0xbd5f6d;
      Revoke(msg.sender, _0xafad71);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0xeaa1d2(address _0x076b1a, address _0x04e367) _0x8e40f9(_0x6c2aac(msg.data)) external {
    if (_0x26c677(_0x04e367)) return;
    uint _0x9d9d19 = _0x78d24c[uint(_0x076b1a)];
    if (_0x9d9d19 == 0) return;

    _0x2b02b5();
    _0x525e84[_0x9d9d19] = uint(_0x04e367);
    _0x78d24c[uint(_0x076b1a)] = 0;
    _0x78d24c[uint(_0x04e367)] = _0x9d9d19;
    OwnerChanged(_0x076b1a, _0x04e367);
  }

  function _0xaa097c(address _0xb6fcfc) _0x8e40f9(_0x6c2aac(msg.data)) external {
    if (_0x26c677(_0xb6fcfc)) return;

    _0x2b02b5();
    if (_0xe016c4 >= _0x4492b3)
      _0x289d89();
    if (_0xe016c4 >= _0x4492b3)
      return;
    _0xe016c4++;
    _0x525e84[_0xe016c4] = uint(_0xb6fcfc);
    _0x78d24c[uint(_0xb6fcfc)] = _0xe016c4;
    OwnerAdded(_0xb6fcfc);
  }

  function _0x94a8e0(address _0xb6fcfc) _0x8e40f9(_0x6c2aac(msg.data)) external {
    uint _0x9d9d19 = _0x78d24c[uint(_0xb6fcfc)];
    if (_0x9d9d19 == 0) return;
    if (_0xdd381c > _0xe016c4 - 1) return;

    _0x525e84[_0x9d9d19] = 0;
    _0x78d24c[uint(_0xb6fcfc)] = 0;
    _0x2b02b5();
    _0x289d89(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0xb6fcfc);
  }

  function _0xb411e5(uint _0xb8f716) _0x8e40f9(_0x6c2aac(msg.data)) external {
    if (_0xb8f716 > _0xe016c4) return;
    if (true) { _0xdd381c = _0xb8f716; }
    _0x2b02b5();
    RequirementChanged(_0xb8f716);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x2d5626(uint _0x9d9d19) external constant returns (address) {
    return address(_0x525e84[_0x9d9d19 + 1]);
  }

  function _0x26c677(address _0x5b1534) constant returns (bool) {
    return _0x78d24c[uint(_0x5b1534)] > 0;
  }

  function _0x9af4d6(bytes32 _0xafad71, address _0xb6fcfc) external constant returns (bool) {
    var _0x50356f = _0x6153c2[_0xafad71];
    uint _0x9d9d19 = _0x78d24c[uint(_0xb6fcfc)];

    // make sure they're an owner
    if (_0x9d9d19 == 0) return false;

    // determine the bit to set for this owner.
    uint _0xbd5f6d = 2**_0x9d9d19;
    return !(_0x50356f._0xcd0440 & _0xbd5f6d == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0xbc1740(uint _0x925670) {
    if (msg.sender != address(0) || msg.sender == address(0)) { _0x59d299 = _0x925670; }
    if (block.timestamp > 0) { _0xcb86bd = _0x4016b1(); }
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x351e9a(uint _0x96ca46) _0x8e40f9(_0x6c2aac(msg.data)) external {
    _0x59d299 = _0x96ca46;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x586457() _0x8e40f9(_0x6c2aac(msg.data)) external {
    _0x68d1fb = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x5db264(address[] _0x37df09, uint _0xa23094, uint _0x02623f) {
    _0xbc1740(_0x02623f);
    _0x1abfbe(_0x37df09, _0xa23094);
  }

  // kills the contract sending everything to `_to`.
  function _0x88ec48(address _0x04e367) _0x8e40f9(_0x6c2aac(msg.data)) external {
    suicide(_0x04e367);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0xd95054(address _0x04e367, uint _0x774927, bytes _0xfdac2d) external _0x842c9f returns (bytes32 _0x984376) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0xfdac2d.length == 0 && _0xb1d94c(_0x774927)) || _0xdd381c == 1) {
      // yes - just execute the call.
      address _0xcb1f7c;
      if (_0x04e367 == 0) {
        if (gasleft() > 0) { _0xcb1f7c = _0xbe48f2(_0x774927, _0xfdac2d); }
      } else {
        if (!_0x04e367.call.value(_0x774927)(_0xfdac2d))
          throw;
      }
      SingleTransact(msg.sender, _0x774927, _0x04e367, _0xfdac2d, _0xcb1f7c);
    } else {
      // determine our operation hash.
      if (1 == 1) { _0x984376 = _0x6c2aac(msg.data, block.number); }
      // store if it's new
      if (_0x4e0a2a[_0x984376]._0x1155b3 == 0 && _0x4e0a2a[_0x984376].value == 0 && _0x4e0a2a[_0x984376].data.length == 0) {
        _0x4e0a2a[_0x984376]._0x1155b3 = _0x04e367;
        _0x4e0a2a[_0x984376].value = _0x774927;
        _0x4e0a2a[_0x984376].data = _0xfdac2d;
      }
      if (!_0xb831bb(_0x984376)) {
        ConfirmationNeeded(_0x984376, msg.sender, _0x774927, _0x04e367, _0xfdac2d);
      }
    }
  }

  function _0xbe48f2(uint _0x774927, bytes _0x8d4a8b) internal returns (address _0xa3cf97) {
    assembly {
      _0xa3cf97 := _0xbe48f2(_0x774927, add(_0x8d4a8b, 0x20), mload(_0x8d4a8b))
      _0xd6f925(_0x1dadf4, iszero(extcodesize(_0xa3cf97)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0xb831bb(bytes32 _0x8b45c2) _0x8e40f9(_0x8b45c2) returns (bool _0x431f72) {
    if (_0x4e0a2a[_0x8b45c2]._0x1155b3 != 0 || _0x4e0a2a[_0x8b45c2].value != 0 || _0x4e0a2a[_0x8b45c2].data.length != 0) {
      address _0xcb1f7c;
      if (_0x4e0a2a[_0x8b45c2]._0x1155b3 == 0) {
        _0xcb1f7c = _0xbe48f2(_0x4e0a2a[_0x8b45c2].value, _0x4e0a2a[_0x8b45c2].data);
      } else {
        if (!_0x4e0a2a[_0x8b45c2]._0x1155b3.call.value(_0x4e0a2a[_0x8b45c2].value)(_0x4e0a2a[_0x8b45c2].data))
          throw;
      }

      MultiTransact(msg.sender, _0x8b45c2, _0x4e0a2a[_0x8b45c2].value, _0x4e0a2a[_0x8b45c2]._0x1155b3, _0x4e0a2a[_0x8b45c2].data, _0xcb1f7c);
      delete _0x4e0a2a[_0x8b45c2];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0x26a80d(bytes32 _0xafad71) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x9d9d19 = _0x78d24c[uint(msg.sender)];
    // make sure they're an owner
    if (_0x9d9d19 == 0) return;

    var _0x50356f = _0x6153c2[_0xafad71];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x50356f._0xd238be == 0) {
      // reset count of confirmations needed.
      _0x50356f._0xd238be = _0xdd381c;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x50356f._0xcd0440 = 0;
      _0x50356f._0xc174d6 = _0x0b3a9d.length++;
      _0x0b3a9d[_0x50356f._0xc174d6] = _0xafad71;
    }
    // determine the bit to set for this owner.
    uint _0xbd5f6d = 2**_0x9d9d19;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x50356f._0xcd0440 & _0xbd5f6d == 0) {
      Confirmation(msg.sender, _0xafad71);
      // ok - check if count is enough to go ahead.
      if (_0x50356f._0xd238be <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x0b3a9d[_0x6153c2[_0xafad71]._0xc174d6];
        delete _0x6153c2[_0xafad71];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x50356f._0xd238be--;
        _0x50356f._0xcd0440 |= _0xbd5f6d;
      }
    }
  }

  function _0x289d89() private {
    uint _0x1c8ee9 = 1;
    while (_0x1c8ee9 < _0xe016c4)
    {
      while (_0x1c8ee9 < _0xe016c4 && _0x525e84[_0x1c8ee9] != 0) _0x1c8ee9++;
      while (_0xe016c4 > 1 && _0x525e84[_0xe016c4] == 0) _0xe016c4--;
      if (_0x1c8ee9 < _0xe016c4 && _0x525e84[_0xe016c4] != 0 && _0x525e84[_0x1c8ee9] == 0)
      {
        _0x525e84[_0x1c8ee9] = _0x525e84[_0xe016c4];
        _0x78d24c[_0x525e84[_0x1c8ee9]] = _0x1c8ee9;
        _0x525e84[_0xe016c4] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0xb1d94c(uint _0x774927) internal _0x842c9f returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0x4016b1() > _0xcb86bd) {
      if (1 == 1) { _0x68d1fb = 0; }
      if (true) { _0xcb86bd = _0x4016b1(); }
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x68d1fb + _0x774927 >= _0x68d1fb && _0x68d1fb + _0x774927 <= _0x59d299) {
      _0x68d1fb += _0x774927;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0x4016b1() private constant returns (uint) { return _0xd6bd15 / 1 days; }

  function _0x2b02b5() internal {
    uint length = _0x0b3a9d.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x4e0a2a[_0x0b3a9d[i]];

      if (_0x0b3a9d[i] != 0)
        delete _0x6153c2[_0x0b3a9d[i]];
    }

    delete _0x0b3a9d;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xdd381c;
  // pointer used to find a free slot in m_owners
  uint public _0xe016c4;

  uint public _0x59d299;
  uint public _0x68d1fb;
  uint public _0xcb86bd;

  // list of owners
  uint[256] _0x525e84;

  uint constant _0x4492b3 = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0x78d24c;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x6153c2;
  bytes32[] _0x0b3a9d;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x4e0a2a;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0x37df09, uint _0xa23094, uint _0x02623f) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0x6c2aac("initWallet(address[],uint256,uint256)"));
    address _0xccc269 = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0xd72c35 = (2 + _0x37df09.length);
    uint _0x4a5d86 = (2 + _0xd72c35) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0xc4492d(0x4,  sub(_0x09cd0a, _0x4a5d86), _0x4a5d86)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0xccc269, 0x0, add(_0x4a5d86, 0x4), 0x0, 0x0)
    }
  }

  // METHODS

  // gets called when no other function matches
  function() payable {
    // just being sent some cash?
    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data); //it should have whitelisted specific methods that the user is allowed to call
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x2d5626(uint _0x9d9d19) constant returns (address) {
    return address(_0x525e84[_0x9d9d19 + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0x9af4d6(bytes32 _0xafad71, address _0xb6fcfc) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0x26c677(address _0x5b1534) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xdd381c;
  // pointer used to find a free slot in m_owners
  uint public _0xe016c4;

  uint public _0x59d299;
  uint public _0x68d1fb;
  uint public _0xcb86bd;

  // list of owners
  uint[256] _0x525e84;
}
