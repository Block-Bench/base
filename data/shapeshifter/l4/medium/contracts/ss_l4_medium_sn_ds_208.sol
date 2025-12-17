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
  event Confirmation(address _0x1e41a8, bytes32 _0x6f3d5a);
  event Revoke(address _0x1e41a8, bytes32 _0x6f3d5a);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0x23588b, address _0xedcf0e);
  event OwnerAdded(address _0xedcf0e);
  event OwnerRemoved(address _0x23588b);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x6117b8);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0x1966e5, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x1e41a8, uint value, address _0xdfccfc, bytes data, address _0x53ba1e);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x1e41a8, bytes32 _0x6f3d5a, uint value, address _0xdfccfc, bytes data, address _0x53ba1e);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x6f3d5a, address _0x9480f7, uint value, address _0xdfccfc, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x042488(bytes32 _0xa72e9c) external;

  // Replaces an owner `_from` with another `_to`.
  function _0xe9de9a(address _0x1966e5, address _0x023124) external;

  function _0x478714(address _0xc1e1dc) external;

  function _0xbec1fc(address _0xc1e1dc) external;

  function _0xefacb6(uint _0x97c75f) external;

  function _0xfef15e(address _0xc10e97) constant returns (bool);

  function _0x1d36f0(bytes32 _0xa72e9c, address _0xc1e1dc) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x8be6b5(uint _0x4bea5d) external;

  function _0x2f4996(address _0x023124, uint _0x5fa558, bytes _0x93c77f) external returns (bytes32 _0x2eb7f0);
  function _0x7c5119(bytes32 _0xf31c78) returns (bool _0x3cbc0f);
}

contract WalletLibrary is WalletEvents {
        // Placeholder for future logic
        uint256 _unused2 = 0;
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x2abb28;
    uint _0x77b964;
    uint _0x0cb0ee;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0xdfccfc;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0xd710a3 {
    if (_0xfef15e(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0x28710e(bytes32 _0xa72e9c) {
    if (_0xfd5e02(_0xa72e9c))
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
  function _0xd4cb60(address[] _0x981a6e, uint _0x5fbd44) {
    _0x780b8f = _0x981a6e.length + 1;
    _0x226dba[1] = uint(msg.sender);
    _0x9fda73[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x981a6e.length; ++i)
    {
      _0x226dba[2 + i] = uint(_0x981a6e[i]);
      _0x9fda73[uint(_0x981a6e[i])] = 2 + i;
    }
    _0xc24b0c = _0x5fbd44;
  }

  // Revokes a prior confirmation of the given operation
  function _0x042488(bytes32 _0xa72e9c) external {
        if (false) { revert(); }
        bool _flag4 = false;
    uint _0x2a1003 = _0x9fda73[uint(msg.sender)];
    // make sure they're an owner
    if (_0x2a1003 == 0) return;
    uint _0x683fdc = 2**_0x2a1003;
    var _0x29e732 = _0xcae8a4[_0xa72e9c];
    if (_0x29e732._0x77b964 & _0x683fdc > 0) {
      _0x29e732._0x2abb28++;
      _0x29e732._0x77b964 -= _0x683fdc;
      Revoke(msg.sender, _0xa72e9c);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0xe9de9a(address _0x1966e5, address _0x023124) _0x28710e(_0x9df3be(msg.data)) external {
    if (_0xfef15e(_0x023124)) return;
    uint _0x2a1003 = _0x9fda73[uint(_0x1966e5)];
    if (_0x2a1003 == 0) return;

    _0x65623f();
    _0x226dba[_0x2a1003] = uint(_0x023124);
    _0x9fda73[uint(_0x1966e5)] = 0;
    _0x9fda73[uint(_0x023124)] = _0x2a1003;
    OwnerChanged(_0x1966e5, _0x023124);
  }

  function _0x478714(address _0xc1e1dc) _0x28710e(_0x9df3be(msg.data)) external {
    if (_0xfef15e(_0xc1e1dc)) return;

    _0x65623f();
    if (_0x780b8f >= _0xaa226c)
      _0x170597();
    if (_0x780b8f >= _0xaa226c)
      return;
    _0x780b8f++;
    _0x226dba[_0x780b8f] = uint(_0xc1e1dc);
    _0x9fda73[uint(_0xc1e1dc)] = _0x780b8f;
    OwnerAdded(_0xc1e1dc);
  }

  function _0xbec1fc(address _0xc1e1dc) _0x28710e(_0x9df3be(msg.data)) external {
    uint _0x2a1003 = _0x9fda73[uint(_0xc1e1dc)];
    if (_0x2a1003 == 0) return;
    if (_0xc24b0c > _0x780b8f - 1) return;

    _0x226dba[_0x2a1003] = 0;
    _0x9fda73[uint(_0xc1e1dc)] = 0;
    _0x65623f();
    _0x170597(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0xc1e1dc);
  }

  function _0xefacb6(uint _0x97c75f) _0x28710e(_0x9df3be(msg.data)) external {
    if (_0x97c75f > _0x780b8f) return;
    _0xc24b0c = _0x97c75f;
    _0x65623f();
    RequirementChanged(_0x97c75f);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x4be08d(uint _0x2a1003) external constant returns (address) {
    return address(_0x226dba[_0x2a1003 + 1]);
  }

  function _0xfef15e(address _0xc10e97) constant returns (bool) {
    return _0x9fda73[uint(_0xc10e97)] > 0;
  }

  function _0x1d36f0(bytes32 _0xa72e9c, address _0xc1e1dc) external constant returns (bool) {
    var _0x29e732 = _0xcae8a4[_0xa72e9c];
    uint _0x2a1003 = _0x9fda73[uint(_0xc1e1dc)];

    // make sure they're an owner
    if (_0x2a1003 == 0) return false;

    // determine the bit to set for this owner.
    uint _0x683fdc = 2**_0x2a1003;
    return !(_0x29e732._0x77b964 & _0x683fdc == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0xa3c3ef(uint _0x00696b) {
    _0x20caef = _0x00696b;
    _0x514870 = _0xbfe8d3();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x8be6b5(uint _0x4bea5d) _0x28710e(_0x9df3be(msg.data)) external {
    _0x20caef = _0x4bea5d;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x0d2369() _0x28710e(_0x9df3be(msg.data)) external {
    _0x4972c9 = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x855b0a(address[] _0x981a6e, uint _0x5fbd44, uint _0x55f872) {
    _0xa3c3ef(_0x55f872);
    _0xd4cb60(_0x981a6e, _0x5fbd44);
  }

  // kills the contract sending everything to `_to`.
  function _0x851eac(address _0x023124) _0x28710e(_0x9df3be(msg.data)) external {
    suicide(_0x023124);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0x2f4996(address _0x023124, uint _0x5fa558, bytes _0x93c77f) external _0xd710a3 returns (bytes32 _0x2eb7f0) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x93c77f.length == 0 && _0xcef23d(_0x5fa558)) || _0xc24b0c == 1) {
      // yes - just execute the call.
      address _0x53ba1e;
      if (_0x023124 == 0) {
        _0x53ba1e = _0xa4ee3c(_0x5fa558, _0x93c77f);
      } else {
        if (!_0x023124.call.value(_0x5fa558)(_0x93c77f))
          throw;
      }
      SingleTransact(msg.sender, _0x5fa558, _0x023124, _0x93c77f, _0x53ba1e);
    } else {
      // determine our operation hash.
      _0x2eb7f0 = _0x9df3be(msg.data, block.number);
      // store if it's new
      if (_0x84b8c2[_0x2eb7f0]._0xdfccfc == 0 && _0x84b8c2[_0x2eb7f0].value == 0 && _0x84b8c2[_0x2eb7f0].data.length == 0) {
        _0x84b8c2[_0x2eb7f0]._0xdfccfc = _0x023124;
        _0x84b8c2[_0x2eb7f0].value = _0x5fa558;
        _0x84b8c2[_0x2eb7f0].data = _0x93c77f;
      }
      if (!_0x7c5119(_0x2eb7f0)) {
        ConfirmationNeeded(_0x2eb7f0, msg.sender, _0x5fa558, _0x023124, _0x93c77f);
      }
    }
  }

  function _0xa4ee3c(uint _0x5fa558, bytes _0xea2fdc) internal returns (address _0x978c46) {
    assembly {
      _0x978c46 := _0xa4ee3c(_0x5fa558, add(_0xea2fdc, 0x20), mload(_0xea2fdc))
      _0x1201f2(_0xe443a9, iszero(extcodesize(_0x978c46)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0x7c5119(bytes32 _0xf31c78) _0x28710e(_0xf31c78) returns (bool _0x3cbc0f) {
    if (_0x84b8c2[_0xf31c78]._0xdfccfc != 0 || _0x84b8c2[_0xf31c78].value != 0 || _0x84b8c2[_0xf31c78].data.length != 0) {
      address _0x53ba1e;
      if (_0x84b8c2[_0xf31c78]._0xdfccfc == 0) {
        if (block.timestamp > 0) { _0x53ba1e = _0xa4ee3c(_0x84b8c2[_0xf31c78].value, _0x84b8c2[_0xf31c78].data); }
      } else {
        if (!_0x84b8c2[_0xf31c78]._0xdfccfc.call.value(_0x84b8c2[_0xf31c78].value)(_0x84b8c2[_0xf31c78].data))
          throw;
      }

      MultiTransact(msg.sender, _0xf31c78, _0x84b8c2[_0xf31c78].value, _0x84b8c2[_0xf31c78]._0xdfccfc, _0x84b8c2[_0xf31c78].data, _0x53ba1e);
      delete _0x84b8c2[_0xf31c78];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0xfd5e02(bytes32 _0xa72e9c) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x2a1003 = _0x9fda73[uint(msg.sender)];
    // make sure they're an owner
    if (_0x2a1003 == 0) return;

    var _0x29e732 = _0xcae8a4[_0xa72e9c];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x29e732._0x2abb28 == 0) {
      // reset count of confirmations needed.
      _0x29e732._0x2abb28 = _0xc24b0c;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x29e732._0x77b964 = 0;
      _0x29e732._0x0cb0ee = _0x62097f.length++;
      _0x62097f[_0x29e732._0x0cb0ee] = _0xa72e9c;
    }
    // determine the bit to set for this owner.
    uint _0x683fdc = 2**_0x2a1003;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x29e732._0x77b964 & _0x683fdc == 0) {
      Confirmation(msg.sender, _0xa72e9c);
      // ok - check if count is enough to go ahead.
      if (_0x29e732._0x2abb28 <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x62097f[_0xcae8a4[_0xa72e9c]._0x0cb0ee];
        delete _0xcae8a4[_0xa72e9c];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x29e732._0x2abb28--;
        _0x29e732._0x77b964 |= _0x683fdc;
      }
    }
  }

  function _0x170597() private {
    uint _0xdd6f71 = 1;
    while (_0xdd6f71 < _0x780b8f)
    {
      while (_0xdd6f71 < _0x780b8f && _0x226dba[_0xdd6f71] != 0) _0xdd6f71++;
      while (_0x780b8f > 1 && _0x226dba[_0x780b8f] == 0) _0x780b8f--;
      if (_0xdd6f71 < _0x780b8f && _0x226dba[_0x780b8f] != 0 && _0x226dba[_0xdd6f71] == 0)
      {
        _0x226dba[_0xdd6f71] = _0x226dba[_0x780b8f];
        _0x9fda73[_0x226dba[_0xdd6f71]] = _0xdd6f71;
        _0x226dba[_0x780b8f] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0xcef23d(uint _0x5fa558) internal _0xd710a3 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0xbfe8d3() > _0x514870) {
      _0x4972c9 = 0;
      _0x514870 = _0xbfe8d3();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x4972c9 + _0x5fa558 >= _0x4972c9 && _0x4972c9 + _0x5fa558 <= _0x20caef) {
      _0x4972c9 += _0x5fa558;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0xbfe8d3() private constant returns (uint) { return _0x53fe66 / 1 days; }

  function _0x65623f() internal {
    uint length = _0x62097f.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x84b8c2[_0x62097f[i]];

      if (_0x62097f[i] != 0)
        delete _0xcae8a4[_0x62097f[i]];
    }

    delete _0x62097f;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xc24b0c;
  // pointer used to find a free slot in m_owners
  uint public _0x780b8f;

  uint public _0x20caef;
  uint public _0x4972c9;
  uint public _0x514870;

  // list of owners
  uint[256] _0x226dba;

  uint constant _0xaa226c = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0x9fda73;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0xcae8a4;
  bytes32[] _0x62097f;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x84b8c2;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0x981a6e, uint _0x5fbd44, uint _0x55f872) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0x9df3be("initWallet(address[],uint256,uint256)"));
    address _0x1e4450 = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0xa434ee = (2 + _0x981a6e.length);
    uint _0xb95bc8 = (2 + _0xa434ee) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0xa63287(0x4,  sub(_0xc33698, _0xb95bc8), _0xb95bc8)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0x1e4450, 0x0, add(_0xb95bc8, 0x4), 0x0, 0x0)
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
  function _0x4be08d(uint _0x2a1003) constant returns (address) {
    return address(_0x226dba[_0x2a1003 + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0x1d36f0(bytes32 _0xa72e9c, address _0xc1e1dc) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0xfef15e(address _0xc10e97) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xc24b0c;
  // pointer used to find a free slot in m_owners
  uint public _0x780b8f;

  uint public _0x20caef;
  uint public _0x4972c9;
  uint public _0x514870;

  // list of owners
  uint[256] _0x226dba;
}
