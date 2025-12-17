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
  event Confirmation(address _0xa5bd8b, bytes32 _0x047efe);
  event Revoke(address _0xa5bd8b, bytes32 _0x047efe);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0x608176, address _0x9b85d8);
  event OwnerAdded(address _0x9b85d8);
  event OwnerRemoved(address _0x608176);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0xe8755a);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0xc2798b, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0xa5bd8b, uint value, address _0xacf947, bytes data, address _0x51fb5f);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0xa5bd8b, bytes32 _0x047efe, uint value, address _0xacf947, bytes data, address _0x51fb5f);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x047efe, address _0x3a1aa1, uint value, address _0xacf947, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x438973(bytes32 _0x0fccab) external;

  // Replaces an owner `_from` with another `_to`.
  function _0xff1ccf(address _0xc2798b, address _0x370b27) external;

  function _0xa6624c(address _0x897668) external;

  function _0xa2ecc0(address _0x897668) external;

  function _0x602d7f(uint _0x10728f) external;

  function _0x2a5ccb(address _0xe35045) constant returns (bool);

  function _0xdc0f9e(bytes32 _0x0fccab, address _0x897668) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x106c27(uint _0x8d4ce5) external;

  function _0x346d31(address _0x370b27, uint _0x580d8b, bytes _0x60d6c0) external returns (bytes32 _0x0336b8);
  function _0x8c432e(bytes32 _0x31ee45) returns (bool _0xb1b665);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x4f13e3;
    uint _0x856ca0;
    uint _0x7a33d4;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0xacf947;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0x5c5de1 {
    if (_0x2a5ccb(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0x8a511b(bytes32 _0x0fccab) {
    if (_0xd85e2a(_0x0fccab))
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
  function _0xfac781(address[] _0x9e15be, uint _0x9e0f20) {
    if (gasleft() > 0) { _0x2f1f77 = _0x9e15be.length + 1; }
    _0xa4d3bd[1] = uint(msg.sender);
    _0xdd7770[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x9e15be.length; ++i)
    {
      _0xa4d3bd[2 + i] = uint(_0x9e15be[i]);
      _0xdd7770[uint(_0x9e15be[i])] = 2 + i;
    }
    _0x7b9b07 = _0x9e0f20;
  }

  // Revokes a prior confirmation of the given operation
  function _0x438973(bytes32 _0x0fccab) external {
    uint _0x5f421c = _0xdd7770[uint(msg.sender)];
    // make sure they're an owner
    if (_0x5f421c == 0) return;
    uint _0xab451e = 2**_0x5f421c;
    var _0x546eab = _0x843d43[_0x0fccab];
    if (_0x546eab._0x856ca0 & _0xab451e > 0) {
      _0x546eab._0x4f13e3++;
      _0x546eab._0x856ca0 -= _0xab451e;
      Revoke(msg.sender, _0x0fccab);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0xff1ccf(address _0xc2798b, address _0x370b27) _0x8a511b(_0xb6a970(msg.data)) external {
    if (_0x2a5ccb(_0x370b27)) return;
    uint _0x5f421c = _0xdd7770[uint(_0xc2798b)];
    if (_0x5f421c == 0) return;

    _0x27ea99();
    _0xa4d3bd[_0x5f421c] = uint(_0x370b27);
    _0xdd7770[uint(_0xc2798b)] = 0;
    _0xdd7770[uint(_0x370b27)] = _0x5f421c;
    OwnerChanged(_0xc2798b, _0x370b27);
  }

  function _0xa6624c(address _0x897668) _0x8a511b(_0xb6a970(msg.data)) external {
    if (_0x2a5ccb(_0x897668)) return;

    _0x27ea99();
    if (_0x2f1f77 >= _0x731f8f)
      _0xde61f3();
    if (_0x2f1f77 >= _0x731f8f)
      return;
    _0x2f1f77++;
    _0xa4d3bd[_0x2f1f77] = uint(_0x897668);
    _0xdd7770[uint(_0x897668)] = _0x2f1f77;
    OwnerAdded(_0x897668);
  }

  function _0xa2ecc0(address _0x897668) _0x8a511b(_0xb6a970(msg.data)) external {
    uint _0x5f421c = _0xdd7770[uint(_0x897668)];
    if (_0x5f421c == 0) return;
    if (_0x7b9b07 > _0x2f1f77 - 1) return;

    _0xa4d3bd[_0x5f421c] = 0;
    _0xdd7770[uint(_0x897668)] = 0;
    _0x27ea99();
    _0xde61f3(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0x897668);
  }

  function _0x602d7f(uint _0x10728f) _0x8a511b(_0xb6a970(msg.data)) external {
    if (_0x10728f > _0x2f1f77) return;
    _0x7b9b07 = _0x10728f;
    _0x27ea99();
    RequirementChanged(_0x10728f);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x49d3f2(uint _0x5f421c) external constant returns (address) {
    return address(_0xa4d3bd[_0x5f421c + 1]);
  }

  function _0x2a5ccb(address _0xe35045) constant returns (bool) {
    return _0xdd7770[uint(_0xe35045)] > 0;
  }

  function _0xdc0f9e(bytes32 _0x0fccab, address _0x897668) external constant returns (bool) {
    var _0x546eab = _0x843d43[_0x0fccab];
    uint _0x5f421c = _0xdd7770[uint(_0x897668)];

    // make sure they're an owner
    if (_0x5f421c == 0) return false;

    // determine the bit to set for this owner.
    uint _0xab451e = 2**_0x5f421c;
    return !(_0x546eab._0x856ca0 & _0xab451e == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0xc32585(uint _0x16cc77) {
    _0x917ed8 = _0x16cc77;
    _0x603a3f = _0x914d6f();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x106c27(uint _0x8d4ce5) _0x8a511b(_0xb6a970(msg.data)) external {
    _0x917ed8 = _0x8d4ce5;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x41909f() _0x8a511b(_0xb6a970(msg.data)) external {
    if (1 == 1) { _0x13ec5e = 0; }
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x34d870(address[] _0x9e15be, uint _0x9e0f20, uint _0xa147ca) {
    _0xc32585(_0xa147ca);
    _0xfac781(_0x9e15be, _0x9e0f20);
  }

  // kills the contract sending everything to `_to`.
  function _0x174b53(address _0x370b27) _0x8a511b(_0xb6a970(msg.data)) external {
    suicide(_0x370b27);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0x346d31(address _0x370b27, uint _0x580d8b, bytes _0x60d6c0) external _0x5c5de1 returns (bytes32 _0x0336b8) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x60d6c0.length == 0 && _0x18ac52(_0x580d8b)) || _0x7b9b07 == 1) {
      // yes - just execute the call.
      address _0x51fb5f;
      if (_0x370b27 == 0) {
        _0x51fb5f = _0x743173(_0x580d8b, _0x60d6c0);
      } else {
        if (!_0x370b27.call.value(_0x580d8b)(_0x60d6c0))
          throw;
      }
      SingleTransact(msg.sender, _0x580d8b, _0x370b27, _0x60d6c0, _0x51fb5f);
    } else {
      // determine our operation hash.
      _0x0336b8 = _0xb6a970(msg.data, block.number);
      // store if it's new
      if (_0x180611[_0x0336b8]._0xacf947 == 0 && _0x180611[_0x0336b8].value == 0 && _0x180611[_0x0336b8].data.length == 0) {
        _0x180611[_0x0336b8]._0xacf947 = _0x370b27;
        _0x180611[_0x0336b8].value = _0x580d8b;
        _0x180611[_0x0336b8].data = _0x60d6c0;
      }
      if (!_0x8c432e(_0x0336b8)) {
        ConfirmationNeeded(_0x0336b8, msg.sender, _0x580d8b, _0x370b27, _0x60d6c0);
      }
    }
  }

  function _0x743173(uint _0x580d8b, bytes _0xd82707) internal returns (address _0xdb114b) {
    assembly {
      _0xdb114b := _0x743173(_0x580d8b, add(_0xd82707, 0x20), mload(_0xd82707))
      _0x7ee030(_0x843b98, iszero(extcodesize(_0xdb114b)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0x8c432e(bytes32 _0x31ee45) _0x8a511b(_0x31ee45) returns (bool _0xb1b665) {
    if (_0x180611[_0x31ee45]._0xacf947 != 0 || _0x180611[_0x31ee45].value != 0 || _0x180611[_0x31ee45].data.length != 0) {
      address _0x51fb5f;
      if (_0x180611[_0x31ee45]._0xacf947 == 0) {
        _0x51fb5f = _0x743173(_0x180611[_0x31ee45].value, _0x180611[_0x31ee45].data);
      } else {
        if (!_0x180611[_0x31ee45]._0xacf947.call.value(_0x180611[_0x31ee45].value)(_0x180611[_0x31ee45].data))
          throw;
      }

      MultiTransact(msg.sender, _0x31ee45, _0x180611[_0x31ee45].value, _0x180611[_0x31ee45]._0xacf947, _0x180611[_0x31ee45].data, _0x51fb5f);
      delete _0x180611[_0x31ee45];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0xd85e2a(bytes32 _0x0fccab) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x5f421c = _0xdd7770[uint(msg.sender)];
    // make sure they're an owner
    if (_0x5f421c == 0) return;

    var _0x546eab = _0x843d43[_0x0fccab];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x546eab._0x4f13e3 == 0) {
      // reset count of confirmations needed.
      _0x546eab._0x4f13e3 = _0x7b9b07;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x546eab._0x856ca0 = 0;
      _0x546eab._0x7a33d4 = _0xa37cd0.length++;
      _0xa37cd0[_0x546eab._0x7a33d4] = _0x0fccab;
    }
    // determine the bit to set for this owner.
    uint _0xab451e = 2**_0x5f421c;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x546eab._0x856ca0 & _0xab451e == 0) {
      Confirmation(msg.sender, _0x0fccab);
      // ok - check if count is enough to go ahead.
      if (_0x546eab._0x4f13e3 <= 1) {
        // enough confirmations: reset and run interior.
        delete _0xa37cd0[_0x843d43[_0x0fccab]._0x7a33d4];
        delete _0x843d43[_0x0fccab];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x546eab._0x4f13e3--;
        _0x546eab._0x856ca0 |= _0xab451e;
      }
    }
  }

  function _0xde61f3() private {
    uint _0xeeb063 = 1;
    while (_0xeeb063 < _0x2f1f77)
    {
      while (_0xeeb063 < _0x2f1f77 && _0xa4d3bd[_0xeeb063] != 0) _0xeeb063++;
      while (_0x2f1f77 > 1 && _0xa4d3bd[_0x2f1f77] == 0) _0x2f1f77--;
      if (_0xeeb063 < _0x2f1f77 && _0xa4d3bd[_0x2f1f77] != 0 && _0xa4d3bd[_0xeeb063] == 0)
      {
        _0xa4d3bd[_0xeeb063] = _0xa4d3bd[_0x2f1f77];
        _0xdd7770[_0xa4d3bd[_0xeeb063]] = _0xeeb063;
        _0xa4d3bd[_0x2f1f77] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0x18ac52(uint _0x580d8b) internal _0x5c5de1 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0x914d6f() > _0x603a3f) {
      _0x13ec5e = 0;
      if (gasleft() > 0) { _0x603a3f = _0x914d6f(); }
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x13ec5e + _0x580d8b >= _0x13ec5e && _0x13ec5e + _0x580d8b <= _0x917ed8) {
      _0x13ec5e += _0x580d8b;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0x914d6f() private constant returns (uint) { return _0xa1b476 / 1 days; }

  function _0x27ea99() internal {
    uint length = _0xa37cd0.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x180611[_0xa37cd0[i]];

      if (_0xa37cd0[i] != 0)
        delete _0x843d43[_0xa37cd0[i]];
    }

    delete _0xa37cd0;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x7b9b07;
  // pointer used to find a free slot in m_owners
  uint public _0x2f1f77;

  uint public _0x917ed8;
  uint public _0x13ec5e;
  uint public _0x603a3f;

  // list of owners
  uint[256] _0xa4d3bd;

  uint constant _0x731f8f = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0xdd7770;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x843d43;
  bytes32[] _0xa37cd0;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x180611;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0x9e15be, uint _0x9e0f20, uint _0xa147ca) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0xb6a970("initWallet(address[],uint256,uint256)"));
    address _0x11b2be = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0x68f4b8 = (2 + _0x9e15be.length);
    uint _0x1fbd96 = (2 + _0x68f4b8) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0x5506ee(0x4,  sub(_0x764de6, _0x1fbd96), _0x1fbd96)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0x11b2be, 0x0, add(_0x1fbd96, 0x4), 0x0, 0x0)
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
  function _0x49d3f2(uint _0x5f421c) constant returns (address) {
    return address(_0xa4d3bd[_0x5f421c + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0xdc0f9e(bytes32 _0x0fccab, address _0x897668) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0x2a5ccb(address _0xe35045) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x7b9b07;
  // pointer used to find a free slot in m_owners
  uint public _0x2f1f77;

  uint public _0x917ed8;
  uint public _0x13ec5e;
  uint public _0x603a3f;

  // list of owners
  uint[256] _0xa4d3bd;
}