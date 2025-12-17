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
  event Confirmation(address _0x5a0a09, bytes32 _0x58a123);
  event Revoke(address _0x5a0a09, bytes32 _0x58a123);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0x60afcd, address _0x33acbb);
  event OwnerAdded(address _0x33acbb);
  event OwnerRemoved(address _0x60afcd);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x39795a);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0x769fd3, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x5a0a09, uint value, address _0xc8be29, bytes data, address _0x419b55);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x5a0a09, bytes32 _0x58a123, uint value, address _0xc8be29, bytes data, address _0x419b55);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x58a123, address _0xb9d371, uint value, address _0xc8be29, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0xd5f218(bytes32 _0xa86eb3) external;

  // Replaces an owner `_from` with another `_to`.
  function _0xa73ecd(address _0x769fd3, address _0x530af7) external;

  function _0x237eae(address _0x27cb68) external;

  function _0x6d3947(address _0x27cb68) external;

  function _0x34915d(uint _0xa0bead) external;

  function _0xe9416e(address _0x99b6df) constant returns (bool);

  function _0x63ea73(bytes32 _0xa86eb3, address _0x27cb68) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x62cffa(uint _0x2f8894) external;

  function _0xf0369a(address _0x530af7, uint _0x83edf0, bytes _0x95604d) external returns (bytes32 _0x986f2b);
  function _0x9785a2(bytes32 _0x22039e) returns (bool _0x412b46);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x36b8ed;
    uint _0xcd2bef;
    uint _0xe46796;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0xc8be29;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0x8f9d71 {
    if (_0xe9416e(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0xc7a510(bytes32 _0xa86eb3) {
    if (_0x1b6e52(_0xa86eb3))
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
  function _0x98817b(address[] _0x92c707, uint _0xcbf674) {
    _0x50c1e0 = _0x92c707.length + 1;
    _0xcd5cb9[1] = uint(msg.sender);
    _0x9f697f[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0x92c707.length; ++i)
    {
      _0xcd5cb9[2 + i] = uint(_0x92c707[i]);
      _0x9f697f[uint(_0x92c707[i])] = 2 + i;
    }
    _0xd4fa38 = _0xcbf674;
  }

  // Revokes a prior confirmation of the given operation
  function _0xd5f218(bytes32 _0xa86eb3) external {
    uint _0x1f5316 = _0x9f697f[uint(msg.sender)];
    // make sure they're an owner
    if (_0x1f5316 == 0) return;
    uint _0x89d366 = 2**_0x1f5316;
    var _0x2dba46 = _0xae83ce[_0xa86eb3];
    if (_0x2dba46._0xcd2bef & _0x89d366 > 0) {
      _0x2dba46._0x36b8ed++;
      _0x2dba46._0xcd2bef -= _0x89d366;
      Revoke(msg.sender, _0xa86eb3);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0xa73ecd(address _0x769fd3, address _0x530af7) _0xc7a510(_0xac6695(msg.data)) external {
    if (_0xe9416e(_0x530af7)) return;
    uint _0x1f5316 = _0x9f697f[uint(_0x769fd3)];
    if (_0x1f5316 == 0) return;

    _0x5a3867();
    _0xcd5cb9[_0x1f5316] = uint(_0x530af7);
    _0x9f697f[uint(_0x769fd3)] = 0;
    _0x9f697f[uint(_0x530af7)] = _0x1f5316;
    OwnerChanged(_0x769fd3, _0x530af7);
  }

  function _0x237eae(address _0x27cb68) _0xc7a510(_0xac6695(msg.data)) external {
    if (_0xe9416e(_0x27cb68)) return;

    _0x5a3867();
    if (_0x50c1e0 >= _0x3d093f)
      _0xa6ca01();
    if (_0x50c1e0 >= _0x3d093f)
      return;
    _0x50c1e0++;
    _0xcd5cb9[_0x50c1e0] = uint(_0x27cb68);
    _0x9f697f[uint(_0x27cb68)] = _0x50c1e0;
    OwnerAdded(_0x27cb68);
  }

  function _0x6d3947(address _0x27cb68) _0xc7a510(_0xac6695(msg.data)) external {
    uint _0x1f5316 = _0x9f697f[uint(_0x27cb68)];
    if (_0x1f5316 == 0) return;
    if (_0xd4fa38 > _0x50c1e0 - 1) return;

    _0xcd5cb9[_0x1f5316] = 0;
    _0x9f697f[uint(_0x27cb68)] = 0;
    _0x5a3867();
    _0xa6ca01(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0x27cb68);
  }

  function _0x34915d(uint _0xa0bead) _0xc7a510(_0xac6695(msg.data)) external {
    if (_0xa0bead > _0x50c1e0) return;
    _0xd4fa38 = _0xa0bead;
    _0x5a3867();
    RequirementChanged(_0xa0bead);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x19a199(uint _0x1f5316) external constant returns (address) {
    return address(_0xcd5cb9[_0x1f5316 + 1]);
  }

  function _0xe9416e(address _0x99b6df) constant returns (bool) {
    return _0x9f697f[uint(_0x99b6df)] > 0;
  }

  function _0x63ea73(bytes32 _0xa86eb3, address _0x27cb68) external constant returns (bool) {
    var _0x2dba46 = _0xae83ce[_0xa86eb3];
    uint _0x1f5316 = _0x9f697f[uint(_0x27cb68)];

    // make sure they're an owner
    if (_0x1f5316 == 0) return false;

    // determine the bit to set for this owner.
    uint _0x89d366 = 2**_0x1f5316;
    return !(_0x2dba46._0xcd2bef & _0x89d366 == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0xc46cc7(uint _0x4d6d06) {
    _0xcd2280 = _0x4d6d06;
    _0x1fa60d = _0xc13f4f();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x62cffa(uint _0x2f8894) _0xc7a510(_0xac6695(msg.data)) external {
    _0xcd2280 = _0x2f8894;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x7977f2() _0xc7a510(_0xac6695(msg.data)) external {
    _0x4bc5ec = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0xc3b56f(address[] _0x92c707, uint _0xcbf674, uint _0xa18741) {
    _0xc46cc7(_0xa18741);
    _0x98817b(_0x92c707, _0xcbf674);
  }

  // kills the contract sending everything to `_to`.
  function _0x035784(address _0x530af7) _0xc7a510(_0xac6695(msg.data)) external {
    suicide(_0x530af7);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0xf0369a(address _0x530af7, uint _0x83edf0, bytes _0x95604d) external _0x8f9d71 returns (bytes32 _0x986f2b) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x95604d.length == 0 && _0x36ed29(_0x83edf0)) || _0xd4fa38 == 1) {
      // yes - just execute the call.
      address _0x419b55;
      if (_0x530af7 == 0) {
        _0x419b55 = _0x510a77(_0x83edf0, _0x95604d);
      } else {
        if (!_0x530af7.call.value(_0x83edf0)(_0x95604d))
          throw;
      }
      SingleTransact(msg.sender, _0x83edf0, _0x530af7, _0x95604d, _0x419b55);
    } else {
      // determine our operation hash.
      _0x986f2b = _0xac6695(msg.data, block.number);
      // store if it's new
      if (_0x2c009e[_0x986f2b]._0xc8be29 == 0 && _0x2c009e[_0x986f2b].value == 0 && _0x2c009e[_0x986f2b].data.length == 0) {
        _0x2c009e[_0x986f2b]._0xc8be29 = _0x530af7;
        _0x2c009e[_0x986f2b].value = _0x83edf0;
        _0x2c009e[_0x986f2b].data = _0x95604d;
      }
      if (!_0x9785a2(_0x986f2b)) {
        ConfirmationNeeded(_0x986f2b, msg.sender, _0x83edf0, _0x530af7, _0x95604d);
      }
    }
  }

  function _0x510a77(uint _0x83edf0, bytes _0x632f17) internal returns (address _0xae12b1) {
    assembly {
      _0xae12b1 := _0x510a77(_0x83edf0, add(_0x632f17, 0x20), mload(_0x632f17))
      _0xa2c091(_0xe322d5, iszero(extcodesize(_0xae12b1)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0x9785a2(bytes32 _0x22039e) _0xc7a510(_0x22039e) returns (bool _0x412b46) {
    if (_0x2c009e[_0x22039e]._0xc8be29 != 0 || _0x2c009e[_0x22039e].value != 0 || _0x2c009e[_0x22039e].data.length != 0) {
      address _0x419b55;
      if (_0x2c009e[_0x22039e]._0xc8be29 == 0) {
        _0x419b55 = _0x510a77(_0x2c009e[_0x22039e].value, _0x2c009e[_0x22039e].data);
      } else {
        if (!_0x2c009e[_0x22039e]._0xc8be29.call.value(_0x2c009e[_0x22039e].value)(_0x2c009e[_0x22039e].data))
          throw;
      }

      MultiTransact(msg.sender, _0x22039e, _0x2c009e[_0x22039e].value, _0x2c009e[_0x22039e]._0xc8be29, _0x2c009e[_0x22039e].data, _0x419b55);
      delete _0x2c009e[_0x22039e];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0x1b6e52(bytes32 _0xa86eb3) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x1f5316 = _0x9f697f[uint(msg.sender)];
    // make sure they're an owner
    if (_0x1f5316 == 0) return;

    var _0x2dba46 = _0xae83ce[_0xa86eb3];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0x2dba46._0x36b8ed == 0) {
      // reset count of confirmations needed.
      _0x2dba46._0x36b8ed = _0xd4fa38;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0x2dba46._0xcd2bef = 0;
      _0x2dba46._0xe46796 = _0x894458.length++;
      _0x894458[_0x2dba46._0xe46796] = _0xa86eb3;
    }
    // determine the bit to set for this owner.
    uint _0x89d366 = 2**_0x1f5316;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0x2dba46._0xcd2bef & _0x89d366 == 0) {
      Confirmation(msg.sender, _0xa86eb3);
      // ok - check if count is enough to go ahead.
      if (_0x2dba46._0x36b8ed <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x894458[_0xae83ce[_0xa86eb3]._0xe46796];
        delete _0xae83ce[_0xa86eb3];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0x2dba46._0x36b8ed--;
        _0x2dba46._0xcd2bef |= _0x89d366;
      }
    }
  }

  function _0xa6ca01() private {
    uint _0x4f8ba2 = 1;
    while (_0x4f8ba2 < _0x50c1e0)
    {
      while (_0x4f8ba2 < _0x50c1e0 && _0xcd5cb9[_0x4f8ba2] != 0) _0x4f8ba2++;
      while (_0x50c1e0 > 1 && _0xcd5cb9[_0x50c1e0] == 0) _0x50c1e0--;
      if (_0x4f8ba2 < _0x50c1e0 && _0xcd5cb9[_0x50c1e0] != 0 && _0xcd5cb9[_0x4f8ba2] == 0)
      {
        _0xcd5cb9[_0x4f8ba2] = _0xcd5cb9[_0x50c1e0];
        _0x9f697f[_0xcd5cb9[_0x4f8ba2]] = _0x4f8ba2;
        _0xcd5cb9[_0x50c1e0] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0x36ed29(uint _0x83edf0) internal _0x8f9d71 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0xc13f4f() > _0x1fa60d) {
      _0x4bc5ec = 0;
      _0x1fa60d = _0xc13f4f();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x4bc5ec + _0x83edf0 >= _0x4bc5ec && _0x4bc5ec + _0x83edf0 <= _0xcd2280) {
      _0x4bc5ec += _0x83edf0;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0xc13f4f() private constant returns (uint) { return _0xc36a32 / 1 days; }

  function _0x5a3867() internal {
    uint length = _0x894458.length;

    for (uint i = 0; i < length; ++i) {
      delete _0x2c009e[_0x894458[i]];

      if (_0x894458[i] != 0)
        delete _0xae83ce[_0x894458[i]];
    }

    delete _0x894458;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xd4fa38;
  // pointer used to find a free slot in m_owners
  uint public _0x50c1e0;

  uint public _0xcd2280;
  uint public _0x4bc5ec;
  uint public _0x1fa60d;

  // list of owners
  uint[256] _0xcd5cb9;

  uint constant _0x3d093f = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0x9f697f;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0xae83ce;
  bytes32[] _0x894458;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0x2c009e;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0x92c707, uint _0xcbf674, uint _0xa18741) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0xac6695("initWallet(address[],uint256,uint256)"));
    address _0xaddd12 = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0x2dbdd0 = (2 + _0x92c707.length);
    uint _0xce76e2 = (2 + _0x2dbdd0) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0x092bc9(0x4,  sub(_0xe1cb03, _0xce76e2), _0xce76e2)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0xaddd12, 0x0, add(_0xce76e2, 0x4), 0x0, 0x0)
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
  function _0x19a199(uint _0x1f5316) constant returns (address) {
    return address(_0xcd5cb9[_0x1f5316 + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0x63ea73(bytes32 _0xa86eb3, address _0x27cb68) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0xe9416e(address _0x99b6df) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xd4fa38;
  // pointer used to find a free slot in m_owners
  uint public _0x50c1e0;

  uint public _0xcd2280;
  uint public _0x4bc5ec;
  uint public _0x1fa60d;

  // list of owners
  uint[256] _0xcd5cb9;
}
