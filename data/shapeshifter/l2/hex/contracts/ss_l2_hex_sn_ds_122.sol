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
  event Confirmation(address _0x500063, bytes32 _0x692e47);
  event Revoke(address _0x500063, bytes32 _0x692e47);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0x7503ad, address _0xa2d9ca);
  event OwnerAdded(address _0xa2d9ca);
  event OwnerRemoved(address _0x7503ad);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x4db060);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0xc037dc, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x500063, uint value, address _0xbb9768, bytes data, address _0x246904);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x500063, bytes32 _0x692e47, uint value, address _0xbb9768, bytes data, address _0x246904);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x692e47, address _0xee1e62, uint value, address _0xbb9768, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0xb99710(bytes32 _0x07c5d5) external;

  // Replaces an owner `_from` with another `_to`.
  function _0xcea008(address _0xc037dc, address _0xc11701) external;

  function _0x4377a3(address _0x5f2a66) external;

  function _0xce335a(address _0x5f2a66) external;

  function _0x0f1f89(uint _0x3aec15) external;

  function _0x427c31(address _0xa0e1af) constant returns (bool);

  function _0x1a67f2(bytes32 _0x07c5d5, address _0x5f2a66) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x6adeb5(uint _0xf50d44) external;

  function _0x562213(address _0xc11701, uint _0x45228c, bytes _0x418c6e) external returns (bytes32 _0xf6a9dc);
  function _0x7e45b7(bytes32 _0xe588f9) returns (bool _0x605425);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x9baa14;
    uint _0x811b66;
    uint _0x33d0c0;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0xbb9768;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0xf74d41 {
    if (_0x427c31(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0xe8021a(bytes32 _0x07c5d5) {
    if (_0x86eb0c(_0x07c5d5))
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
  function _0xd581b4(address[] _0xc57f47, uint _0xa02123) {
    _0x7c2353 = _0xc57f47.length + 1;
    _0x1cf41e[1] = uint(msg.sender);
    _0x99a387[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xc57f47.length; ++i)
    {
      _0x1cf41e[2 + i] = uint(_0xc57f47[i]);
      _0x99a387[uint(_0xc57f47[i])] = 2 + i;
    }
    _0xd4233c = _0xa02123;
  }

  // Revokes a prior confirmation of the given operation
  function _0xb99710(bytes32 _0x07c5d5) external {
    uint _0x069c0c = _0x99a387[uint(msg.sender)];
    // make sure they're an owner
    if (_0x069c0c == 0) return;
    uint _0xb8afe9 = 2**_0x069c0c;
    var _0x421031 = _0x640d4d[_0x07c5d5];
    if (_0x421031._0x811b66 & _0xb8afe9 > 0) {
      _0x421031._0x9baa14++;
      _0x421031._0x811b66 -= _0xb8afe9;
      Revoke(msg.sender, _0x07c5d5);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0xcea008(address _0xc037dc, address _0xc11701) _0xe8021a(_0x8f3b21(msg.data)) external {
    if (_0x427c31(_0xc11701)) return;
    uint _0x069c0c = _0x99a387[uint(_0xc037dc)];
    if (_0x069c0c == 0) return;

    _0x99d2f2();
    _0x1cf41e[_0x069c0c] = uint(_0xc11701);
    _0x99a387[uint(_0xc037dc)] = 0;
    _0x99a387[uint(_0xc11701)] = _0x069c0c;
    OwnerChanged(_0xc037dc, _0xc11701);
  }

  function _0x4377a3(address _0x5f2a66) _0xe8021a(_0x8f3b21(msg.data)) external {
    if (_0x427c31(_0x5f2a66)) return;

    _0x99d2f2();
    if (_0x7c2353 >= _0xad53c0)
      _0x39b647();
    if (_0x7c2353 >= _0xad53c0)
      return;
    _0x7c2353++;
    _0x1cf41e[_0x7c2353] = uint(_0x5f2a66);
    _0x99a387[uint(_0x5f2a66)] = _0x7c2353;
    OwnerAdded(_0x5f2a66);
  }

  function _0xce335a(address _0x5f2a66) _0xe8021a(_0x8f3b21(msg.data)) external {
    uint _0x069c0c = _0x99a387[uint(_0x5f2a66)];
    if (_0x069c0c == 0) return;
    if (_0xd4233c > _0x7c2353 - 1) return;

    _0x1cf41e[_0x069c0c] = 0;
    _0x99a387[uint(_0x5f2a66)] = 0;
    _0x99d2f2();
    _0x39b647(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0x5f2a66);
  }

  function _0x0f1f89(uint _0x3aec15) _0xe8021a(_0x8f3b21(msg.data)) external {
    if (_0x3aec15 > _0x7c2353) return;
    _0xd4233c = _0x3aec15;
    _0x99d2f2();
    RequirementChanged(_0x3aec15);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0xe04d83(uint _0x069c0c) external constant returns (address) {
    return address(_0x1cf41e[_0x069c0c + 1]);
  }

  function _0x427c31(address _0xa0e1af) constant returns (bool) {
    return _0x99a387[uint(_0xa0e1af)] > 0;
  }

  function _0x1a67f2(bytes32 _0x07c5d5, address _0x5f2a66) external constant returns (bool) {
    var _0x421031 = _0x640d4d[_0x07c5d5];
    uint _0x069c0c = _0x99a387[uint(_0x5f2a66)];

    // make sure they're an owner
    if (_0x069c0c == 0) return false;

    // determine the bit to set for this owner.
    uint _0xb8afe9 = 2**_0x069c0c;
    return !(_0x421031._0x811b66 & _0xb8afe9 == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0xb331b3(uint _0xb6530d) {
    _0x319bef = _0xb6530d;
    _0xbfdfd6 = _0x45018f();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x6adeb5(uint _0xf50d44) _0xe8021a(_0x8f3b21(msg.data)) external {
    _0x319bef = _0xf50d44;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0xaa2d89() _0xe8021a(_0x8f3b21(msg.data)) external {
    _0x45b7e3 = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x47abc9(address[] _0xc57f47, uint _0xa02123, uint _0x0654fd) {
    _0xb331b3(_0x0654fd);
    _0xd581b4(_0xc57f47, _0xa02123);
  }

  // kills the contract sending everything to `_to`.
  function _0xa17aaf(address _0xc11701) _0xe8021a(_0x8f3b21(msg.data)) external {
    suicide(_0xc11701);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0x562213(address _0xc11701, uint _0x45228c, bytes _0x418c6e) external _0xf74d41 returns (bytes32 _0xf6a9dc) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x418c6e.length == 0 && _0x320710(_0x45228c)) || _0xd4233c == 1) {
      // yes - just execute the call.
      address _0x246904;
      if (_0xc11701 == 0) {
        _0x246904 = _0x1cfbb0(_0x45228c, _0x418c6e);
      } else {
        if (!_0xc11701.call.value(_0x45228c)(_0x418c6e))
          throw;
      }
      SingleTransact(msg.sender, _0x45228c, _0xc11701, _0x418c6e, _0x246904);
    } else {
      // determine our operation hash.
      _0xf6a9dc = _0x8f3b21(msg.data, block.number);
      // store if it's new
      if (_0x55555a[_0xf6a9dc]._0xbb9768 == 0 && _0x55555a[_0xf6a9dc].value == 0 && _0x55555a[_0xf6a9dc].data.length == 0) {
        _0x55555a[_0xf6a9dc]._0xbb9768 = _0xc11701;
        _0x55555a[_0xf6a9dc].value = _0x45228c;
        _0x55555a[_0xf6a9dc].data = _0x418c6e;
      }
      if (!_0x7e45b7(_0xf6a9dc)) {
        ConfirmationNeeded(_0xf6a9dc, msg.sender, _0x45228c, _0xc11701, _0x418c6e);
      }
    }
  }

  function _0x1cfbb0(uint _0x45228c, bytes _0xc0cd2c) internal returns (address _0x476ebd) {
    assembly {
      _0x476ebd := _0x1cfbb0(_0x45228c, add(_0xc0cd2c, 0x20), mload(_0xc0cd2c))
      _0x3d907a(_0x277fa1, iszero(extcodesize(_0x476ebd)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0x7e45b7(bytes32 _0xe588f9) _0xe8021a(_0xe588f9) returns (bool _0x605425) {
    if (_0x55555a[_0xe588f9]._0xbb9768 != 0 || _0x55555a[_0xe588f9].value != 0 || _0x55555a[_0xe588f9].data.length != 0) {
      address _0x246904;
      if (_0x55555a[_0xe588f9]._0xbb9768 == 0) {
        _0x246904 = _0x1cfbb0(_0x55555a[_0xe588f9].value, _0x55555a[_0xe588f9].data);
      } else {
        if (!_0x55555a[_0xe588f9]._0xbb9768.call.value(_0x55555a[_0xe588f9].value)(_0x55555a[_0xe588f9].data))
          throw;
      }

      MultiTransact(msg.sender, _0xe588f9, _0x55555a[_0xe588f9].value, _0x55555a[_0xe588f9]._0xbb9768, _0x55555a[_0xe588f9].data, _0x246904);
      delete _0x55555a[_0xe588f9];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0x86eb0c(bytes32 _0x07c5d5) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x069c0c = _0x99a387[uint(msg.sender)];
    // make sure they're an owner
    if (_0x069c0c == 0) return;

    var _0x421031 = _0x640d4d[_0x07c5d5];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x421031._0x9baa14 == 0) {
      // reset count of confirmations needed.
      _0x421031._0x9baa14 = _0xd4233c;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x421031._0x811b66 = 0;
      _0x421031._0x33d0c0 = _0x2dfe8a.length++;
      _0x2dfe8a[_0x421031._0x33d0c0] = _0x07c5d5;
    }
    // determine the bit to set for this owner.
    uint _0xb8afe9 = 2**_0x069c0c;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x421031._0x811b66 & _0xb8afe9 == 0) {
      Confirmation(msg.sender, _0x07c5d5);
      // ok - check if count is enough to go ahead.
      if (_0x421031._0x9baa14 <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x2dfe8a[_0x640d4d[_0x07c5d5]._0x33d0c0];
        delete _0x640d4d[_0x07c5d5];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x421031._0x9baa14--;
        _0x421031._0x811b66 |= _0xb8afe9;
      }
    }
  }

  function _0x39b647() private {
    uint _0x5bee69 = 1;
    while (_0x5bee69 < _0x7c2353)
    {
      while (_0x5bee69 < _0x7c2353 && _0x1cf41e[_0x5bee69] != 0) _0x5bee69++;
      while (_0x7c2353 > 1 && _0x1cf41e[_0x7c2353] == 0) _0x7c2353--;
      if (_0x5bee69 < _0x7c2353 && _0x1cf41e[_0x7c2353] != 0 && _0x1cf41e[_0x5bee69] == 0)
      {
        _0x1cf41e[_0x5bee69] = _0x1cf41e[_0x7c2353];
        _0x99a387[_0x1cf41e[_0x5bee69]] = _0x5bee69;
        _0x1cf41e[_0x7c2353] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0x320710(uint _0x45228c) internal _0xf74d41 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0x45018f() > _0xbfdfd6) {
      _0x45b7e3 = 0;
      _0xbfdfd6 = _0x45018f();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x45b7e3 + _0x45228c >= _0x45b7e3 && _0x45b7e3 + _0x45228c <= _0x319bef) {
      _0x45b7e3 += _0x45228c;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0x45018f() private constant returns (uint) { return _0x93750e / 1 days; }

  function _0x99d2f2() internal {
    uint length = _0x2dfe8a.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x55555a[_0x2dfe8a[i]];

      if (_0x2dfe8a[i] != 0)
        delete _0x640d4d[_0x2dfe8a[i]];
    }

    delete _0x2dfe8a;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xd4233c;
  // pointer used to find a free slot in m_owners
  uint public _0x7c2353;

  uint public _0x319bef;
  uint public _0x45b7e3;
  uint public _0xbfdfd6;

  // list of owners
  uint[256] _0x1cf41e;

  uint constant _0xad53c0 = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0x99a387;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x640d4d;
  bytes32[] _0x2dfe8a;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x55555a;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0xc57f47, uint _0xa02123, uint _0x0654fd) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0x8f3b21("initWallet(address[],uint256,uint256)"));
    address _0xccd751 = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0x13eb80 = (2 + _0xc57f47.length);
    uint _0x90d2a9 = (2 + _0x13eb80) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0x1ed418(0x4,  sub(_0xb635d4, _0x90d2a9), _0x90d2a9)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0xccd751, 0x0, add(_0x90d2a9, 0x4), 0x0, 0x0)
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
  function _0xe04d83(uint _0x069c0c) constant returns (address) {
    return address(_0x1cf41e[_0x069c0c + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0x1a67f2(bytes32 _0x07c5d5, address _0x5f2a66) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0x427c31(address _0xa0e1af) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xd4233c;
  // pointer used to find a free slot in m_owners
  uint public _0x7c2353;

  uint public _0x319bef;
  uint public _0x45b7e3;
  uint public _0xbfdfd6;

  // list of owners
  uint[256] _0x1cf41e;
}