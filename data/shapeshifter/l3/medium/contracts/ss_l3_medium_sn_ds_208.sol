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
  event Confirmation(address _0x528652, bytes32 _0x882f42);
  event Revoke(address _0x528652, bytes32 _0x882f42);

  // some others are in the case of an owner changing.
  event OwnerChanged(address _0xe85d9d, address _0x801791);
  event OwnerAdded(address _0x801791);
  event OwnerRemoved(address _0xe85d9d);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint _0x4a9514);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address _0x4767c7, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address _0x528652, uint value, address _0x28faa4, bytes data, address _0x67d4ff);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address _0x528652, bytes32 _0x882f42, uint value, address _0x28faa4, bytes data, address _0x67d4ff);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 _0x882f42, address _0x773104, uint value, address _0x28faa4, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function _0x49adcb(bytes32 _0x7b868c) external;

  // Replaces an owner `_from` with another `_to`.
  function _0xab9fce(address _0x4767c7, address _0xbff32e) external;

  function _0x2ecbe4(address _0x160555) external;

  function _0x17f1e7(address _0x160555) external;

  function _0xdd250d(uint _0x67f296) external;

  function _0x168513(address _0x4572b5) constant returns (bool);

  function _0x35e7a9(bytes32 _0x7b868c, address _0x160555) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x7de53e(uint _0x15a8a9) external;

  function _0x04bfdd(address _0xbff32e, uint _0x65b882, bytes _0x091339) external returns (bytes32 _0x193bb8);
  function _0xc42bc4(bytes32 _0x6b7851) returns (bool _0xa7ef04);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint _0x4a5cb8;
    uint _0x574537;
    uint _0x7590b0;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address _0x28faa4;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier _0x605e69 {
    if (_0x168513(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier _0xc8c36c(bytes32 _0x7b868c) {
    if (_0xafeeb8(_0x7b868c))
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
  function _0x426066(address[] _0xde10ac, uint _0xaacb78) {
    if (msg.sender != address(0) || msg.sender == address(0)) { _0x7ba4f5 = _0xde10ac.length + 1; }
    _0xc63514[1] = uint(msg.sender);
    _0xa0bf68[uint(msg.sender)] = 1;
    for (uint i = 0; i < _0xde10ac.length; ++i)
    {
      _0xc63514[2 + i] = uint(_0xde10ac[i]);
      _0xa0bf68[uint(_0xde10ac[i])] = 2 + i;
    }
    _0xc80f96 = _0xaacb78;
  }

  // Revokes a prior confirmation of the given operation
  function _0x49adcb(bytes32 _0x7b868c) external {
    uint _0x91aade = _0xa0bf68[uint(msg.sender)];
    // make sure they're an owner
    if (_0x91aade == 0) return;
    uint _0x2ee8fc = 2**_0x91aade;
    var _0xf77f04 = _0xd3db0c[_0x7b868c];
    if (_0xf77f04._0x574537 & _0x2ee8fc > 0) {
      _0xf77f04._0x4a5cb8++;
      _0xf77f04._0x574537 -= _0x2ee8fc;
      Revoke(msg.sender, _0x7b868c);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function _0xab9fce(address _0x4767c7, address _0xbff32e) _0xc8c36c(_0x22c3db(msg.data)) external {
    if (_0x168513(_0xbff32e)) return;
    uint _0x91aade = _0xa0bf68[uint(_0x4767c7)];
    if (_0x91aade == 0) return;

    _0xba4a0b();
    _0xc63514[_0x91aade] = uint(_0xbff32e);
    _0xa0bf68[uint(_0x4767c7)] = 0;
    _0xa0bf68[uint(_0xbff32e)] = _0x91aade;
    OwnerChanged(_0x4767c7, _0xbff32e);
  }

  function _0x2ecbe4(address _0x160555) _0xc8c36c(_0x22c3db(msg.data)) external {
    if (_0x168513(_0x160555)) return;

    _0xba4a0b();
    if (_0x7ba4f5 >= _0x8d40b1)
      _0xbed6d5();
    if (_0x7ba4f5 >= _0x8d40b1)
      return;
    _0x7ba4f5++;
    _0xc63514[_0x7ba4f5] = uint(_0x160555);
    _0xa0bf68[uint(_0x160555)] = _0x7ba4f5;
    OwnerAdded(_0x160555);
  }

  function _0x17f1e7(address _0x160555) _0xc8c36c(_0x22c3db(msg.data)) external {
    uint _0x91aade = _0xa0bf68[uint(_0x160555)];
    if (_0x91aade == 0) return;
    if (_0xc80f96 > _0x7ba4f5 - 1) return;

    _0xc63514[_0x91aade] = 0;
    _0xa0bf68[uint(_0x160555)] = 0;
    _0xba4a0b();
    _0xbed6d5(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(_0x160555);
  }

  function _0xdd250d(uint _0x67f296) _0xc8c36c(_0x22c3db(msg.data)) external {
    if (_0x67f296 > _0x7ba4f5) return;
    _0xc80f96 = _0x67f296;
    _0xba4a0b();
    RequirementChanged(_0x67f296);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function _0x3ec177(uint _0x91aade) external constant returns (address) {
    return address(_0xc63514[_0x91aade + 1]);
  }

  function _0x168513(address _0x4572b5) constant returns (bool) {
    return _0xa0bf68[uint(_0x4572b5)] > 0;
  }

  function _0x35e7a9(bytes32 _0x7b868c, address _0x160555) external constant returns (bool) {
    var _0xf77f04 = _0xd3db0c[_0x7b868c];
    uint _0x91aade = _0xa0bf68[uint(_0x160555)];

    // make sure they're an owner
    if (_0x91aade == 0) return false;

    // determine the bit to set for this owner.
    uint _0x2ee8fc = 2**_0x91aade;
    return !(_0xf77f04._0x574537 & _0x2ee8fc == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function _0xfa940d(uint _0xc8ceac) {
    _0xda4a82 = _0xc8ceac;
    if (true) { _0x4a46b3 = _0xf137fe(); }
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function _0x7de53e(uint _0x15a8a9) _0xc8c36c(_0x22c3db(msg.data)) external {
    if (block.timestamp > 0) { _0xda4a82 = _0x15a8a9; }
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function _0x0f869c() _0xc8c36c(_0x22c3db(msg.data)) external {
    _0x70ecbe = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function _0xb354e0(address[] _0xde10ac, uint _0xaacb78, uint _0x37ce49) {
    _0xfa940d(_0x37ce49);
    _0x426066(_0xde10ac, _0xaacb78);
  }

  // kills the contract sending everything to `_to`.
  function _0x9fb68b(address _0xbff32e) _0xc8c36c(_0x22c3db(msg.data)) external {
    suicide(_0xbff32e);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function _0x04bfdd(address _0xbff32e, uint _0x65b882, bytes _0x091339) external _0x605e69 returns (bytes32 _0x193bb8) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((_0x091339.length == 0 && _0xe63705(_0x65b882)) || _0xc80f96 == 1) {
      // yes - just execute the call.
      address _0x67d4ff;
      if (_0xbff32e == 0) {
        _0x67d4ff = _0xda6e4c(_0x65b882, _0x091339);
      } else {
        if (!_0xbff32e.call.value(_0x65b882)(_0x091339))
          throw;
      }
      SingleTransact(msg.sender, _0x65b882, _0xbff32e, _0x091339, _0x67d4ff);
    } else {
      // determine our operation hash.
      _0x193bb8 = _0x22c3db(msg.data, block.number);
      // store if it's new
      if (_0xe076bc[_0x193bb8]._0x28faa4 == 0 && _0xe076bc[_0x193bb8].value == 0 && _0xe076bc[_0x193bb8].data.length == 0) {
        _0xe076bc[_0x193bb8]._0x28faa4 = _0xbff32e;
        _0xe076bc[_0x193bb8].value = _0x65b882;
        _0xe076bc[_0x193bb8].data = _0x091339;
      }
      if (!_0xc42bc4(_0x193bb8)) {
        ConfirmationNeeded(_0x193bb8, msg.sender, _0x65b882, _0xbff32e, _0x091339);
      }
    }
  }

  function _0xda6e4c(uint _0x65b882, bytes _0x919b42) internal returns (address _0x2ba76d) {
    assembly {
      _0x2ba76d := _0xda6e4c(_0x65b882, add(_0x919b42, 0x20), mload(_0x919b42))
      _0x1f5cc1(_0x3cc710, iszero(extcodesize(_0x2ba76d)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function _0xc42bc4(bytes32 _0x6b7851) _0xc8c36c(_0x6b7851) returns (bool _0xa7ef04) {
    if (_0xe076bc[_0x6b7851]._0x28faa4 != 0 || _0xe076bc[_0x6b7851].value != 0 || _0xe076bc[_0x6b7851].data.length != 0) {
      address _0x67d4ff;
      if (_0xe076bc[_0x6b7851]._0x28faa4 == 0) {
        _0x67d4ff = _0xda6e4c(_0xe076bc[_0x6b7851].value, _0xe076bc[_0x6b7851].data);
      } else {
        if (!_0xe076bc[_0x6b7851]._0x28faa4.call.value(_0xe076bc[_0x6b7851].value)(_0xe076bc[_0x6b7851].data))
          throw;
      }

      MultiTransact(msg.sender, _0x6b7851, _0xe076bc[_0x6b7851].value, _0xe076bc[_0x6b7851]._0x28faa4, _0xe076bc[_0x6b7851].data, _0x67d4ff);
      delete _0xe076bc[_0x6b7851];
      return true;
    }
  }

  // INTERNAL METHODS

  function _0xafeeb8(bytes32 _0x7b868c) internal returns (bool) {
    // determine what index the present sender is:
    uint _0x91aade = _0xa0bf68[uint(msg.sender)];
    // make sure they're an owner
    if (_0x91aade == 0) return;

    var _0xf77f04 = _0xd3db0c[_0x7b868c];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (_0xf77f04._0x4a5cb8 == 0) {
      // reset count of confirmations needed.
      _0xf77f04._0x4a5cb8 = _0xc80f96;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      _0xf77f04._0x574537 = 0;
      _0xf77f04._0x7590b0 = _0x319e3b.length++;
      _0x319e3b[_0xf77f04._0x7590b0] = _0x7b868c;
    }
    // determine the bit to set for this owner.
    uint _0x2ee8fc = 2**_0x91aade;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (_0xf77f04._0x574537 & _0x2ee8fc == 0) {
      Confirmation(msg.sender, _0x7b868c);
      // ok - check if count is enough to go ahead.
      if (_0xf77f04._0x4a5cb8 <= 1) {
        // enough confirmations: reset and run interior.
        delete _0x319e3b[_0xd3db0c[_0x7b868c]._0x7590b0];
        delete _0xd3db0c[_0x7b868c];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        _0xf77f04._0x4a5cb8--;
        _0xf77f04._0x574537 |= _0x2ee8fc;
      }
    }
  }

  function _0xbed6d5() private {
    uint _0x45d7c3 = 1;
    while (_0x45d7c3 < _0x7ba4f5)
    {
      while (_0x45d7c3 < _0x7ba4f5 && _0xc63514[_0x45d7c3] != 0) _0x45d7c3++;
      while (_0x7ba4f5 > 1 && _0xc63514[_0x7ba4f5] == 0) _0x7ba4f5--;
      if (_0x45d7c3 < _0x7ba4f5 && _0xc63514[_0x7ba4f5] != 0 && _0xc63514[_0x45d7c3] == 0)
      {
        _0xc63514[_0x45d7c3] = _0xc63514[_0x7ba4f5];
        _0xa0bf68[_0xc63514[_0x45d7c3]] = _0x45d7c3;
        _0xc63514[_0x7ba4f5] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function _0xe63705(uint _0x65b882) internal _0x605e69 returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (_0xf137fe() > _0x4a46b3) {
      _0x70ecbe = 0;
      _0x4a46b3 = _0xf137fe();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (_0x70ecbe + _0x65b882 >= _0x70ecbe && _0x70ecbe + _0x65b882 <= _0xda4a82) {
      _0x70ecbe += _0x65b882;
      return true;
    }
    return false;
  }

  // determines today's index.
  function _0xf137fe() private constant returns (uint) { return _0x737852 / 1 days; }

  function _0xba4a0b() internal {
    uint length = _0x319e3b.length;

    for (uint i = 0; i < length; ++i) {
      delete _0xe076bc[_0x319e3b[i]];

      if (_0x319e3b[i] != 0)
        delete _0xd3db0c[_0x319e3b[i]];
    }

    delete _0x319e3b;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xc80f96;
  // pointer used to find a free slot in m_owners
  uint public _0x7ba4f5;

  uint public _0xda4a82;
  uint public _0x70ecbe;
  uint public _0x4a46b3;

  // list of owners
  uint[256] _0xc63514;

  uint constant _0x8d40b1 = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) _0xa0bf68;
  // the ongoing operations.
  mapping(bytes32 => PendingState) _0xd3db0c;
  bytes32[] _0x319e3b;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) _0xe076bc;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] _0xde10ac, uint _0xaacb78, uint _0x37ce49) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(_0x22c3db("initWallet(address[],uint256,uint256)"));
    address _0xd1a9c4 = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint _0x37db0e = (2 + _0xde10ac.length);
    uint _0xdfbc7f = (2 + _0x37db0e) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      _0xf844cd(0x4,  sub(_0x7a5236, _0xdfbc7f), _0xdfbc7f)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), _0xd1a9c4, 0x0, add(_0xdfbc7f, 0x4), 0x0, 0x0)
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
  function _0x3ec177(uint _0x91aade) constant returns (address) {
    return address(_0xc63514[_0x91aade + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function _0x35e7a9(bytes32 _0x7b868c, address _0x160555) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function _0x168513(address _0x4572b5) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public _0xc80f96;
  // pointer used to find a free slot in m_owners
  uint public _0x7ba4f5;

  uint public _0xda4a82;
  uint public _0x70ecbe;
  uint public _0x4a46b3;

  // list of owners
  uint[256] _0xc63514;
}
