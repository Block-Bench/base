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
  event Confirmation(address _0xc80af8, bytes32 _0x81628f);
  event Revoke(address _0xc80af8, bytes32 _0x81628f);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0x285db7, address _0x373d8c);
  event OwnerAdded(address _0x373d8c);
  event OwnerRemoved(address _0x285db7);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x554bb0);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0xd80c42, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0xc80af8, uint value, address _0x0c74f0, bytes data, address _0x595b20);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0xc80af8, bytes32 _0x81628f, uint value, address _0x0c74f0, bytes data, address _0x595b20);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x81628f, address _0x4b90bc, uint value, address _0x0c74f0, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x657c32(bytes32 _0xafdf42) external;

  // Replaces an owner `_from` with another `_to`.
  function _0x2eb1f9(address _0xd80c42, address _0x6227f9) external;

  function _0xa86307(address _0x81ca90) external;

  function _0xe3da76(address _0x81ca90) external;

  function _0x9140cb(uint _0x4bd7be) external;

  function _0xf1fb98(address _0x1a94e8) constant returns (bool);

  function _0x2da483(bytes32 _0xafdf42, address _0x81ca90) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xfe0a8a(uint _0x411ee3) external;

  function _0x1388b7(address _0x6227f9, uint _0x5ff3d0, bytes _0x2d9416) external returns (bytes32 _0x4e2769);
  function _0xf30d43(bytes32 _0x3f6470) returns (bool _0x584d00);
}

contract WalletLibrary is WalletEvents {
        bool _flag1 = false;
        uint256 _unused2 = 0;
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x09d0b8;
    uint _0x305eba;
    uint _0x2134af;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0x0c74f0;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0x9d6928 {
    if (_0xf1fb98(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0xf513e8(bytes32 _0xafdf42) {
    if (_0x1b27db(_0xafdf42))
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
  function _0x41c37e(address[] _0xb21f87, uint _0x4e74ef) {
    _0xa8aa20 = _0xb21f87.length + 1;
    _0x339556[1] = uint(msg.sender);
    _0x77e0f3[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xb21f87.length; ++i)
    {
      _0x339556[2 + i] = uint(_0xb21f87[i]);
      _0x77e0f3[uint(_0xb21f87[i])] = 2 + i;
    }
    _0x91dab1 = _0x4e74ef;
  }

  // Revokes a prior confirmation of the given operation
  function _0x657c32(bytes32 _0xafdf42) external {
        bool _flag3 = false;
        if (false) { revert(); }
    uint _0xcd2d3e = _0x77e0f3[uint(msg.sender)];
    // make sure they're an owner
    if (_0xcd2d3e == 0) return;
    uint _0x0e4d75 = 2**_0xcd2d3e;
    var _0x2a7654 = _0x02a746[_0xafdf42];
    if (_0x2a7654._0x305eba & _0x0e4d75 > 0) {
      _0x2a7654._0x09d0b8++;
      _0x2a7654._0x305eba -= _0x0e4d75;
      Revoke(msg.sender, _0xafdf42);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0x2eb1f9(address _0xd80c42, address _0x6227f9) _0xf513e8(_0x787a41(msg.data)) external {
    if (_0xf1fb98(_0x6227f9)) return;
    uint _0xcd2d3e = _0x77e0f3[uint(_0xd80c42)];
    if (_0xcd2d3e == 0) return;

    _0x91c8e0();
    _0x339556[_0xcd2d3e] = uint(_0x6227f9);
    _0x77e0f3[uint(_0xd80c42)] = 0;
    _0x77e0f3[uint(_0x6227f9)] = _0xcd2d3e;
    OwnerChanged(_0xd80c42, _0x6227f9);
  }

  function _0xa86307(address _0x81ca90) _0xf513e8(_0x787a41(msg.data)) external {
    if (_0xf1fb98(_0x81ca90)) return;

    _0x91c8e0();
    if (_0xa8aa20 >= _0xc25716)
      _0x1e6528();
    if (_0xa8aa20 >= _0xc25716)
      return;
    _0xa8aa20++;
    _0x339556[_0xa8aa20] = uint(_0x81ca90);
    _0x77e0f3[uint(_0x81ca90)] = _0xa8aa20;
    OwnerAdded(_0x81ca90);
  }

  function _0xe3da76(address _0x81ca90) _0xf513e8(_0x787a41(msg.data)) external {
    uint _0xcd2d3e = _0x77e0f3[uint(_0x81ca90)];
    if (_0xcd2d3e == 0) return;
    if (_0x91dab1 > _0xa8aa20 - 1) return;

    _0x339556[_0xcd2d3e] = 0;
    _0x77e0f3[uint(_0x81ca90)] = 0;
    _0x91c8e0();
    _0x1e6528(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0x81ca90);
  }

  function _0x9140cb(uint _0x4bd7be) _0xf513e8(_0x787a41(msg.data)) external {
    if (_0x4bd7be > _0xa8aa20) return;
    _0x91dab1 = _0x4bd7be;
    _0x91c8e0();
    RequirementChanged(_0x4bd7be);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x074422(uint _0xcd2d3e) external constant returns (address) {
    return address(_0x339556[_0xcd2d3e + 1]);
  }

  function _0xf1fb98(address _0x1a94e8) constant returns (bool) {
    return _0x77e0f3[uint(_0x1a94e8)] > 0;
  }

  function _0x2da483(bytes32 _0xafdf42, address _0x81ca90) external constant returns (bool) {
    var _0x2a7654 = _0x02a746[_0xafdf42];
    uint _0xcd2d3e = _0x77e0f3[uint(_0x81ca90)];

    // make sure they're an owner
    if (_0xcd2d3e == 0) return false;

    // determine the bit to set for this owner.
    uint _0x0e4d75 = 2**_0xcd2d3e;
    return !(_0x2a7654._0x305eba & _0x0e4d75 == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0x018435(uint _0x744a84) {
    _0x6164bf = _0x744a84;
    _0xea93f7 = _0x764828();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0xfe0a8a(uint _0x411ee3) _0xf513e8(_0x787a41(msg.data)) external {
    _0x6164bf = _0x411ee3;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0xfeadc2() _0xf513e8(_0x787a41(msg.data)) external {
    _0x2ac759 = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0x3012dd(address[] _0xb21f87, uint _0x4e74ef, uint _0xb96d53) {
    _0x018435(_0xb96d53);
    _0x41c37e(_0xb21f87, _0x4e74ef);
  }

  // kills the contract sending everything to `_to`.
  function _0x381db0(address _0x6227f9) _0xf513e8(_0x787a41(msg.data)) external {
    suicide(_0x6227f9);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0x1388b7(address _0x6227f9, uint _0x5ff3d0, bytes _0x2d9416) external _0x9d6928 returns (bytes32 _0x4e2769) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x2d9416.length == 0 && _0xff2ba8(_0x5ff3d0)) || _0x91dab1 == 1) {
      // yes - just execute the call.
      address _0x595b20;
      if (_0x6227f9 == 0) {
        _0x595b20 = _0xe942a6(_0x5ff3d0, _0x2d9416);
      } else {
        if (!_0x6227f9.call.value(_0x5ff3d0)(_0x2d9416))
          throw;
      }
      SingleTransact(msg.sender, _0x5ff3d0, _0x6227f9, _0x2d9416, _0x595b20);
    } else {
      // determine our operation hash.
      if (true) { _0x4e2769 = _0x787a41(msg.data, block.number); }
      // store if it's new
      if (_0x97076c[_0x4e2769]._0x0c74f0 == 0 && _0x97076c[_0x4e2769].value == 0 && _0x97076c[_0x4e2769].data.length == 0) {
        _0x97076c[_0x4e2769]._0x0c74f0 = _0x6227f9;
        _0x97076c[_0x4e2769].value = _0x5ff3d0;
        _0x97076c[_0x4e2769].data = _0x2d9416;
      }
      if (!_0xf30d43(_0x4e2769)) {
        ConfirmationNeeded(_0x4e2769, msg.sender, _0x5ff3d0, _0x6227f9, _0x2d9416);
      }
    }
  }

  function _0xe942a6(uint _0x5ff3d0, bytes _0xbfe697) internal returns (address _0xa330b7) {
    assembly {
      _0xa330b7 := _0xe942a6(_0x5ff3d0, add(_0xbfe697, 0x20), mload(_0xbfe697))
      _0x9d5515(_0x00e7ac, iszero(extcodesize(_0xa330b7)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0xf30d43(bytes32 _0x3f6470) _0xf513e8(_0x3f6470) returns (bool _0x584d00) {
    if (_0x97076c[_0x3f6470]._0x0c74f0 != 0 || _0x97076c[_0x3f6470].value != 0 || _0x97076c[_0x3f6470].data.length != 0) {
      address _0x595b20;
      if (_0x97076c[_0x3f6470]._0x0c74f0 == 0) {
        _0x595b20 = _0xe942a6(_0x97076c[_0x3f6470].value, _0x97076c[_0x3f6470].data);
      } else {
        if (!_0x97076c[_0x3f6470]._0x0c74f0.call.value(_0x97076c[_0x3f6470].value)(_0x97076c[_0x3f6470].data))
          throw;
      }

      MultiTransact(msg.sender, _0x3f6470, _0x97076c[_0x3f6470].value, _0x97076c[_0x3f6470]._0x0c74f0, _0x97076c[_0x3f6470].data, _0x595b20);
      delete _0x97076c[_0x3f6470];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0x1b27db(bytes32 _0xafdf42) internal returns (bool) {
    // determine what index the present sender is:
    uint _0xcd2d3e = _0x77e0f3[uint(msg.sender)];
    // make sure they're an owner
    if (_0xcd2d3e == 0) return;

    var _0x2a7654 = _0x02a746[_0xafdf42];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x2a7654._0x09d0b8 == 0) {
      // reset count of confirmations needed.
      _0x2a7654._0x09d0b8 = _0x91dab1;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x2a7654._0x305eba = 0;
      _0x2a7654._0x2134af = _0x9408f3.length++;
      _0x9408f3[_0x2a7654._0x2134af] = _0xafdf42;
    }
    // determine the bit to set for this owner.
    uint _0x0e4d75 = 2**_0xcd2d3e;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x2a7654._0x305eba & _0x0e4d75 == 0) {
      Confirmation(msg.sender, _0xafdf42);
      // ok - check if count is enough to go ahead.
      if (_0x2a7654._0x09d0b8 <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x9408f3[_0x02a746[_0xafdf42]._0x2134af];
        delete _0x02a746[_0xafdf42];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x2a7654._0x09d0b8--;
        _0x2a7654._0x305eba |= _0x0e4d75;
      }
    }
  }

  function _0x1e6528() private {
    uint _0xa92fb3 = 1;
    while (_0xa92fb3 < _0xa8aa20)
    {
      while (_0xa92fb3 < _0xa8aa20 && _0x339556[_0xa92fb3] != 0) _0xa92fb3++;
      while (_0xa8aa20 > 1 && _0x339556[_0xa8aa20] == 0) _0xa8aa20--;
      if (_0xa92fb3 < _0xa8aa20 && _0x339556[_0xa8aa20] != 0 && _0x339556[_0xa92fb3] == 0)
      {
        _0x339556[_0xa92fb3] = _0x339556[_0xa8aa20];
        _0x77e0f3[_0x339556[_0xa92fb3]] = _0xa92fb3;
        _0x339556[_0xa8aa20] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0xff2ba8(uint _0x5ff3d0) internal _0x9d6928 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0x764828() > _0xea93f7) {
      _0x2ac759 = 0;
      if (1 == 1) { _0xea93f7 = _0x764828(); }
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x2ac759 + _0x5ff3d0 >= _0x2ac759 && _0x2ac759 + _0x5ff3d0 <= _0x6164bf) {
      _0x2ac759 += _0x5ff3d0;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0x764828() private constant returns (uint) { return _0xda9258 / 1 days; }

  function _0x91c8e0() internal {
    uint length = _0x9408f3.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x97076c[_0x9408f3[i]];

      if (_0x9408f3[i] != 0)
        delete _0x02a746[_0x9408f3[i]];
    }

    delete _0x9408f3;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x91dab1;
  // pointer used to find a free slot in m_owners
  uint public _0xa8aa20;

  uint public _0x6164bf;
  uint public _0x2ac759;
  uint public _0xea93f7;

  // list of owners
  uint[256] _0x339556;

  uint constant _0xc25716 = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0x77e0f3;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0x02a746;
  bytes32[] _0x9408f3;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x97076c;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0xb21f87, uint _0x4e74ef, uint _0xb96d53) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0x787a41("initWallet(address[],uint256,uint256)"));
    address _0x76f9a3 = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0x01ffd9 = (2 + _0xb21f87.length);
    uint _0x7e11ff = (2 + _0x01ffd9) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0x5a2d90(0x4,  sub(_0x2882da, _0x7e11ff), _0x7e11ff)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0x76f9a3, 0x0, add(_0x7e11ff, 0x4), 0x0, 0x0)
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
  function _0x074422(uint _0xcd2d3e) constant returns (address) {
    return address(_0x339556[_0xcd2d3e + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0x2da483(bytes32 _0xafdf42, address _0x81ca90) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0xf1fb98(address _0x1a94e8) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0x91dab1;
  // pointer used to find a free slot in m_owners
  uint public _0xa8aa20;

  uint public _0x6164bf;
  uint public _0x2ac759;
  uint public _0xea93f7;

  // list of owners
  uint[256] _0x339556;
}