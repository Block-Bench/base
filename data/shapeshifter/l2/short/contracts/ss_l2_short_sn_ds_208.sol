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
  event Confirmation(address bo, bytes32 af);
  event Revoke(address bo, bytes32 af);

  // some others are in the case of an owner changing.
  event OwnerChanged(address at, address ar);
  event OwnerAdded(address ar);
  event OwnerRemoved(address at);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint f);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address bm, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address bo, uint value, address by, bytes data, address ay);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address bo, bytes32 af, uint value, address by, bytes data, address ay);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 af, address am, uint value, address by, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function bh(bytes32 y) external;

  // Replaces an owner `_from` with another `_to`.
  function w(address bm, address bv) external;

  function an(address bf) external;

  function u(address bf) external;

  function a(uint o) external;

  function au(address bl) constant returns (bool);

  function s(bytes32 y, address bf) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function j(uint ak) external;

  function ax(address bv, uint bc, bytes br) external returns (bytes32 bd);
  function av(bytes32 bx) returns (bool ad);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint ag;
    uint x;
    uint bp;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address by;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier ai {
    if (au(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier i(bytes32 y) {
    if (e(y))
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
  function g(address[] aw, uint al) {
    t = aw.length + 1;
    aq[1] = uint(msg.sender);
    p[uint(msg.sender)] = 1;
    for (uint i = 0; i < aw.length; ++i)
    {
      aq[2 + i] = uint(aw[i]);
      p[uint(aw[i])] = 2 + i;
    }
    aa = al;
  }

  // Revokes a prior confirmation of the given operation
  function bh(bytes32 y) external {
    uint ab = p[uint(msg.sender)];
    // make sure they're an owner
    if (ab == 0) return;
    uint k = 2**ab;
    var az = ae[y];
    if (az.x & k > 0) {
      az.ag++;
      az.x -= k;
      Revoke(msg.sender, y);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function w(address bm, address bv) i(bs(msg.data)) external {
    if (au(bv)) return;
    uint ab = p[uint(bm)];
    if (ab == 0) return;

    q();
    aq[ab] = uint(bv);
    p[uint(bm)] = 0;
    p[uint(bv)] = ab;
    OwnerChanged(bm, bv);
  }

  function an(address bf) i(bs(msg.data)) external {
    if (au(bf)) return;

    q();
    if (t >= v)
      c();
    if (t >= v)
      return;
    t++;
    aq[t] = uint(bf);
    p[uint(bf)] = t;
    OwnerAdded(bf);
  }

  function u(address bf) i(bs(msg.data)) external {
    uint ab = p[uint(bf)];
    if (ab == 0) return;
    if (aa > t - 1) return;

    aq[ab] = 0;
    p[uint(bf)] = 0;
    q();
    c(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(bf);
  }

  function a(uint o) i(bs(msg.data)) external {
    if (o > t) return;
    aa = o;
    q();
    RequirementChanged(o);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function ao(uint ab) external constant returns (address) {
    return address(aq[ab + 1]);
  }

  function au(address bl) constant returns (bool) {
    return p[uint(bl)] > 0;
  }

  function s(bytes32 y, address bf) external constant returns (bool) {
    var az = ae[y];
    uint ab = p[uint(bf)];

    // make sure they're an owner
    if (ab == 0) return false;

    // determine the bit to set for this owner.
    uint k = 2**ab;
    return !(az.x & k == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function m(uint bg) {
    n = bg;
    aj = bn();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function j(uint ak) i(bs(msg.data)) external {
    n = ak;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function d() i(bs(msg.data)) external {
    r = 0;
  }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function z(address[] aw, uint al, uint ah) {
    m(ah);
    g(aw, al);
  }

  // kills the contract sending everything to `_to`.
  function bu(address bv) i(bs(msg.data)) external {
    suicide(bv);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function ax(address bv, uint bc, bytes br) external ai returns (bytes32 bd) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((br.length == 0 && ac(bc)) || aa == 1) {
      // yes - just execute the call.
      address ay;
      if (bv == 0) {
        ay = bb(bc, br);
      } else {
        if (!bv.call.value(bc)(br))
          throw;
      }
      SingleTransact(msg.sender, bc, bv, br, ay);
    } else {
      // determine our operation hash.
      bd = bs(msg.data, block.number);
      // store if it's new
      if (bq[bd].by == 0 && bq[bd].value == 0 && bq[bd].data.length == 0) {
        bq[bd].by = bv;
        bq[bd].value = bc;
        bq[bd].data = br;
      }
      if (!av(bd)) {
        ConfirmationNeeded(bd, msg.sender, bc, bv, br);
      }
    }
  }

  function bb(uint bc, bytes bj) internal returns (address bi) {
    assembly {
      bi := bb(bc, add(bj, 0x20), mload(bj))
      bk(b, iszero(extcodesize(bi)))
    }
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function av(bytes32 bx) i(bx) returns (bool ad) {
    if (bq[bx].by != 0 || bq[bx].value != 0 || bq[bx].data.length != 0) {
      address ay;
      if (bq[bx].by == 0) {
        ay = bb(bq[bx].value, bq[bx].data);
      } else {
        if (!bq[bx].by.call.value(bq[bx].value)(bq[bx].data))
          throw;
      }

      MultiTransact(msg.sender, bx, bq[bx].value, bq[bx].by, bq[bx].data, ay);
      delete bq[bx];
      return true;
    }
  }

  // INTERNAL METHODS

  function e(bytes32 y) internal returns (bool) {
    // determine what index the present sender is:
    uint ab = p[uint(msg.sender)];
    // make sure they're an owner
    if (ab == 0) return;

    var az = ae[y];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (az.ag == 0) {
      // reset count of confirmations needed.
      az.ag = aa;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      az.x = 0;
      az.bp = h.length++;
      h[az.bp] = y;
    }
    // determine the bit to set for this owner.
    uint k = 2**ab;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (az.x & k == 0) {
      Confirmation(msg.sender, y);
      // ok - check if count is enough to go ahead.
      if (az.ag <= 1) {
        // enough confirmations: reset and run interior.
        delete h[ae[y].bp];
        delete ae[y];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        az.ag--;
        az.x |= k;
      }
    }
  }

  function c() private {
    uint bt = 1;
    while (bt < t)
    {
      while (bt < t && aq[bt] != 0) bt++;
      while (t > 1 && aq[t] == 0) t--;
      if (bt < t && aq[t] != 0 && aq[bt] == 0)
      {
        aq[bt] = aq[t];
        p[aq[bt]] = bt;
        aq[t] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function ac(uint bc) internal ai returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (bn() > aj) {
      r = 0;
      aj = bn();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (r + bc >= r && r + bc <= n) {
      r += bc;
      return true;
    }
    return false;
  }

  // determines today's index.
  function bn() private constant returns (uint) { return bw / 1 days; }

  function q() internal {
    uint length = h.length;

    for (uint i = 0; i < length; ++i) {
      delete bq[h[i]];

      if (h[i] != 0)
        delete ae[h[i]];
    }

    delete h;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public aa;
  // pointer used to find a free slot in m_owners
  uint public t;

  uint public n;
  uint public r;
  uint public aj;

  // list of owners
  uint[256] aq;

  uint constant v = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) p;
  // the ongoing operations.
  mapping(bytes32 => PendingState) ae;
  bytes32[] h;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) bq;
}

contract Wallet is WalletEvents {

  // WALLET CONSTRUCTOR
  //   calls the `initWallet` method of the Library in this context
  function Wallet(address[] aw, uint al, uint ah) {
    // Signature of the Wallet Library's init function
    bytes4 sig = bytes4(bs("initWallet(address[],uint256,uint256)"));
    address be = _walletLibrary;

    // Compute the size of the call data : arrays has 2
    // 32bytes for offset and length, plus 32bytes per element ;
    // plus 2 32bytes for each uint
    uint l = (2 + aw.length);
    uint ba = (2 + l) * 32;

    assembly {
      // Add the signature first to memory
      mstore(0x0, sig)
      // Add the call data, which is at the end of the
      // code
      ap(0x4,  sub(as, ba), ba)
      // Delegate call to the library
      delegatecall(sub(gas, 10000), be, 0x0, add(ba, 0x4), 0x0, 0x0)
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
  function ao(uint ab) constant returns (address) {
    return address(aq[ab + 1]);
  }

  // As return statement unavailable in fallback, explicit the method here

  function s(bytes32 y, address bf) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function au(address bl) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public aa;
  // pointer used to find a free slot in m_owners
  uint public t;

  uint public n;
  uint public r;
  uint public aj;

  // list of owners
  uint[256] aq;
}
