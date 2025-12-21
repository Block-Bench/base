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
  event Confirmation(address bk, bytes32 af);
  event Revoke(address bk, bytes32 af);

  // some others are in the case of an owner changing.
  event OwnerChanged(address aq, address ap);
  event OwnerAdded(address ap);
  event OwnerRemoved(address aq);

  // the last one is emitted if the required signatures change
  event RequirementChanged(uint i);

  // Funds has arrived into the wallet (record how much).
  event Deposit(address bj, uint value);
  // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
  event SingleTransact(address bk, uint value, address br, bytes data, address au);
  // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
  event MultiTransact(address bk, bytes32 af, uint value, address br, bytes data, address au);
  // Confirmation still needed for a transaction.
  event ConfirmationNeeded(bytes32 af, address ai, uint value, address br, bytes data);
}

contract WalletAbi {
  // Revokes a prior confirmation of the given operation
  function bb(bytes32 aa) external;

  // Replaces an owner `_from` with another `_to`.
  function u(address bj, address bp) external;

  function am(address az) external;

  function t(address az) external;

  function b(uint l) external;

  function as(address bi) constant returns (bool);

  function r(bytes32 aa, address az) external constant returns (bool);

  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function j(uint ac) external;

  function aw(address bp, uint ax, bytes bg) external returns (bytes32 bd);
  function av(bytes32 bs) returns (bool ag);
}

contract WalletLibrary is WalletEvents {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint ah;
    uint w;
    uint bl;
  }

  // Transaction structure to remember details of transaction lest it need be saved for a later call.
  struct Transaction {
    address br;
    uint value;
    bytes data;
  }

  // MODIFIERS

  // simple single-sig function modifier.
  modifier aj {
    if (as(msg.sender))
      _;
  }
  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier f(bytes32 aa) {
    if (e(aa))
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
  function g(address[] ar, uint ad) a {
    s = ar.length + 1;
    ao[1] = uint(msg.sender);
    n[uint(msg.sender)] = 1;
    for (uint i = 0; i < ar.length; ++i)
    {
      ao[2 + i] = uint(ar[i]);
      n[uint(ar[i])] = 2 + i;
    }
    x = ad;
  }

  // Revokes a prior confirmation of the given operation
  function bb(bytes32 aa) external {
    uint y = n[uint(msg.sender)];
    // make sure they're an owner
    if (y == 0) return;
    uint k = 2**y;
    var at = ae[aa];
    if (at.w & k > 0) {
      at.ah++;
      at.w -= k;
      Revoke(msg.sender, aa);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function u(address bj, address bp) f(bn(msg.data)) external {
    if (as(bp)) return;
    uint y = n[uint(bj)];
    if (y == 0) return;

    q();
    ao[y] = uint(bp);
    n[uint(bj)] = 0;
    n[uint(bp)] = y;
    OwnerChanged(bj, bp);
  }

  function am(address az) f(bn(msg.data)) external {
    if (as(az)) return;

    q();
    if (s >= v)
      c();
    if (s >= v)
      return;
    s++;
    ao[s] = uint(az);
    n[uint(az)] = s;
    OwnerAdded(az);
  }

  function t(address az) f(bn(msg.data)) external {
    uint y = n[uint(az)];
    if (y == 0) return;
    if (x > s - 1) return;

    ao[y] = 0;
    n[uint(az)] = 0;
    q();
    c(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot
    OwnerRemoved(az);
  }

  function b(uint l) f(bn(msg.data)) external {
    if (l > s) return;
    x = l;
    q();
    RequirementChanged(l);
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function an(uint y) external constant returns (address) {
    return address(ao[y + 1]);
  }

  function as(address bi) constant returns (bool) {
    return n[uint(bi)] > 0;
  }

  function r(bytes32 aa, address az) external constant returns (bool) {
    var at = ae[aa];
    uint y = n[uint(az)];

    // make sure they're an owner
    if (y == 0) return false;

    // determine the bit to set for this owner.
    uint k = 2**y;
    return !(at.w & k == 0);
  }

  // constructor - stores initial daily limit and records the present day's index.
  function o(uint ba) a {
    m = ba;
    al = bh();
  }
  // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
  function j(uint ac) f(bn(msg.data)) external {
    m = ac;
  }
  // resets the amount already spent today. needs many of the owners to confirm.
  function d() f(bn(msg.data)) external {
    p = 0;
  }

  // throw unless the contract is not yet initialized.
  modifier a { if (s > 0) throw; _; }

  // constructor - just pass on the owner array to the multiowned and
  // the limit to daylimit
  function ab(address[] ar, uint ad, uint ak) a {
    o(ak);
    g(ar, ad);
  }

  // kills the contract sending everything to `_to`.
  function bo(address bp) f(bn(msg.data)) external {
    suicide(bp);
  }

  // Outside-visible transact entry point. Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process. We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
  // and _data arguments). They still get the option of using them if they want, anyways.
  function aw(address bp, uint ax, bytes bg) external aj returns (bytes32 bd) {
    // first, take the opportunity to check that we're under the daily limit.
    if ((bg.length == 0 && z(ax)) || x == 1) {
      // yes - just execute the call.
      address au;
      if (bp == 0) {
        au = ay(ax, bg);
      } else {
        if (!bp.call.value(ax)(bg))
          throw;
      }
      SingleTransact(msg.sender, ax, bp, bg, au);
    } else {
      // determine our operation hash.
      bd = bn(msg.data, block.number);
      // store if it's new
      if (be[bd].br == 0 && be[bd].value == 0 && be[bd].data.length == 0) {
        be[bd].br = bp;
        be[bd].value = ax;
        be[bd].data = bg;
      }
      if (!av(bd)) {
        ConfirmationNeeded(bd, msg.sender, ax, bp, bg);
      }
    }
  }

  function ay(uint ax, bytes bf) internal returns (address bc) {
  }

  // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
  // to determine the body of the transaction from the hash provided.
  function av(bytes32 bs) f(bs) returns (bool ag) {
    if (be[bs].br != 0 || be[bs].value != 0 || be[bs].data.length != 0) {
      address au;
      if (be[bs].br == 0) {
        au = ay(be[bs].value, be[bs].data);
      } else {
        if (!be[bs].br.call.value(be[bs].value)(be[bs].data))
          throw;
      }

      MultiTransact(msg.sender, bs, be[bs].value, be[bs].br, be[bs].data, au);
      delete be[bs];
      return true;
    }
  }

  // INTERNAL METHODS

  function e(bytes32 aa) internal returns (bool) {
    // determine what index the present sender is:
    uint y = n[uint(msg.sender)];
    // make sure they're an owner
    if (y == 0) return;

    var at = ae[aa];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (at.ah == 0) {
      // reset count of confirmations needed.
      at.ah = x;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      at.w = 0;
      at.bl = h.length++;
      h[at.bl] = aa;
    }
    // determine the bit to set for this owner.
    uint k = 2**y;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (at.w & k == 0) {
      Confirmation(msg.sender, aa);
      // ok - check if count is enough to go ahead.
      if (at.ah <= 1) {
        // enough confirmations: reset and run interior.
        delete h[ae[aa].bl];
        delete ae[aa];
        return true;
      }
      else
      {
        // not enough: record that this owner in particular confirmed.
        at.ah--;
        at.w |= k;
      }
    }
  }

  function c() private {
    uint bm = 1;
    while (bm < s)
    {
      while (bm < s && ao[bm] != 0) bm++;
      while (s > 1 && ao[s] == 0) s--;
      if (bm < s && ao[s] != 0 && ao[bm] == 0)
      {
        ao[bm] = ao[s];
        n[ao[bm]] = bm;
        ao[s] = 0;
      }
    }
  }

  // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
  // returns true. otherwise just returns false.
  function z(uint ax) internal aj returns (bool) {
    // reset the spend limit if we're on a different day to last time.
    if (bh() > al) {
      p = 0;
      al = bh();
    }
    // check to see if there's enough left - if so, subtract and return true.

    if (p + ax >= p && p + ax <= m) {
      p += ax;
      return true;
    }
    return false;
  }

  // determines today's index.
  function bh() private constant returns (uint) { return bq / 1 days; }

  function q() internal {
    uint length = h.length;

    for (uint i = 0; i < length; ++i) {
      delete be[h[i]];

      if (h[i] != 0)
        delete ae[h[i]];
    }

    delete h;
  }

  // FIELDS
  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;

  // the number of owners that must confirm the same operation before it is run.
  uint public x;
  // pointer used to find a free slot in m_owners
  uint public s;

  uint public m;
  uint public p;
  uint public al;

  // list of owners
  uint[256] ao;

  uint constant v = 250;
  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) n;
  // the ongoing operations.
  mapping(bytes32 => PendingState) ae;
  bytes32[] h;

  // pending transactions we have at present.
  mapping (bytes32 => Transaction) be;
}
