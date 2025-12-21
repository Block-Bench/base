pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address bf, bytes32 ai);
  event Revoke(address bf, bytes32 ai);


  event OwnerChanged(address an, address ao);
  event OwnerAdded(address ao);
  event OwnerRemoved(address an);


  event RequirementChanged(uint g);


  event Deposit(address bj, uint value);

  event SingleTransact(address bf, uint value, address bs, bytes data, address aw);

  event MultiTransact(address bf, bytes32 ai, uint value, address bs, bytes data, address aw);

  event ConfirmationNeeded(bytes32 ai, address ac, uint value, address bs, bytes data);
}

contract WalletAbi {

  function ay(bytes32 w) external;


  function u(address bj, address bp) external;

  function aq(address bc) external;

  function s(address bc) external;

  function b(uint m) external;

  function at(address bg) constant returns (bool);

  function q(bytes32 w, address bc) external constant returns (bool);


  function j(uint al) external;

  function av(address bp, uint ax, bytes bh) external returns (bytes32 ba);
  function au(bytes32 br) returns (bool aj);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint ae;
    uint x;
    uint bi;
  }


  struct Transaction {
    address bs;
    uint value;
    bytes data;
  }


  modifier ad {
    if (at(msg.sender))
      _;
  }


  modifier i(bytes32 w) {
    if (d(w))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function f(address[] as, uint af) a {
    t = as.length + 1;
    ap[1] = uint(msg.sender);
    n[uint(msg.sender)] = 1;
    for (uint i = 0; i < as.length; ++i)
    {
      ap[2 + i] = uint(as[i]);
      n[uint(as[i])] = 2 + i;
    }
    aa = af;
  }


  function ay(bytes32 w) external {
    uint y = n[uint(msg.sender)];

    if (y == 0) return;
    uint k = 2**y;
    var ar = ag[w];
    if (ar.x & k > 0) {
      ar.ae++;
      ar.x -= k;
      Revoke(msg.sender, w);
    }
  }


  function u(address bj, address bp) i(bo(msg.data)) external {
    if (at(bp)) return;
    uint y = n[uint(bj)];
    if (y == 0) return;

    r();
    ap[y] = uint(bp);
    n[uint(bj)] = 0;
    n[uint(bp)] = y;
    OwnerChanged(bj, bp);
  }

  function aq(address bc) i(bo(msg.data)) external {
    if (at(bc)) return;

    r();
    if (t >= v)
      c();
    if (t >= v)
      return;
    t++;
    ap[t] = uint(bc);
    n[uint(bc)] = t;
    OwnerAdded(bc);
  }

  function s(address bc) i(bo(msg.data)) external {
    uint y = n[uint(bc)];
    if (y == 0) return;
    if (aa > t - 1) return;

    ap[y] = 0;
    n[uint(bc)] = 0;
    r();
    c();
    OwnerRemoved(bc);
  }

  function b(uint m) i(bo(msg.data)) external {
    if (m > t) return;
    aa = m;
    r();
    RequirementChanged(m);
  }


  function am(uint y) external constant returns (address) {
    return address(ap[y + 1]);
  }

  function at(address bg) constant returns (bool) {
    return n[uint(bg)] > 0;
  }

  function q(bytes32 w, address bc) external constant returns (bool) {
    var ar = ag[w];
    uint y = n[uint(bc)];


    if (y == 0) return false;


    uint k = 2**y;
    return !(ar.x & k == 0);
  }


  function l(uint bd) a {
    p = bd;
    ak = bk();
  }

  function j(uint al) i(bo(msg.data)) external {
    p = al;
  }

  function e() i(bo(msg.data)) external {
    o = 0;
  }


  modifier a { if (t > 0) throw; _; }


  function ab(address[] as, uint af, uint ah) a {
    l(ah);
    f(as, af);
  }


  function bm(address bp) i(bo(msg.data)) external {
    suicide(bp);
  }


  function av(address bp, uint ax, bytes bh) external ad returns (bytes32 ba) {

    if ((bh.length == 0 && z(ax)) || aa == 1) {

      address aw;
      if (bp == 0) {
        aw = bb(ax, bh);
      } else {
        if (!bp.call.value(ax)(bh))
          throw;
      }
      SingleTransact(msg.sender, ax, bp, bh, aw);
    } else {

      ba = bo(msg.data, block.number);

      if (be[ba].bs == 0 && be[ba].value == 0 && be[ba].data.length == 0) {
        be[ba].bs = bp;
        be[ba].value = ax;
        be[ba].data = bh;
      }
      if (!au(ba)) {
        ConfirmationNeeded(ba, msg.sender, ax, bp, bh);
      }
    }
  }

  function bb(uint ax, bytes bl) internal returns (address az) {
  }


  function au(bytes32 br) i(br) returns (bool aj) {
    if (be[br].bs != 0 || be[br].value != 0 || be[br].data.length != 0) {
      address aw;
      if (be[br].bs == 0) {
        aw = bb(be[br].value, be[br].data);
      } else {
        if (!be[br].bs.call.value(be[br].value)(be[br].data))
          throw;
      }

      MultiTransact(msg.sender, br, be[br].value, be[br].bs, be[br].data, aw);
      delete be[br];
      return true;
    }
  }


  function d(bytes32 w) internal returns (bool) {

    uint y = n[uint(msg.sender)];

    if (y == 0) return;

    var ar = ag[w];

    if (ar.ae == 0) {

      ar.ae = aa;

      ar.x = 0;
      ar.bi = h.length++;
      h[ar.bi] = w;
    }

    uint k = 2**y;

    if (ar.x & k == 0) {
      Confirmation(msg.sender, w);

      if (ar.ae <= 1) {

        delete h[ag[w].bi];
        delete ag[w];
        return true;
      }
      else
      {

        ar.ae--;
        ar.x |= k;
      }
    }
  }

  function c() private {
    uint bn = 1;
    while (bn < t)
    {
      while (bn < t && ap[bn] != 0) bn++;
      while (t > 1 && ap[t] == 0) t--;
      if (bn < t && ap[t] != 0 && ap[bn] == 0)
      {
        ap[bn] = ap[t];
        n[ap[bn]] = bn;
        ap[t] = 0;
      }
    }
  }


  function z(uint ax) internal ad returns (bool) {

    if (bk() > ak) {
      o = 0;
      ak = bk();
    }


    if (o + ax >= o && o + ax <= p) {
      o += ax;
      return true;
    }
    return false;
  }


  function bk() private constant returns (uint) { return bq / 1 days; }

  function r() internal {
    uint length = h.length;

    for (uint i = 0; i < length; ++i) {
      delete be[h[i]];

      if (h[i] != 0)
        delete ag[h[i]];
    }

    delete h;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public aa;

  uint public t;

  uint public p;
  uint public o;
  uint public ak;


  uint[256] ap;

  uint constant v = 250;

  mapping(uint => uint) n;

  mapping(bytes32 => PendingState) ag;
  bytes32[] h;


  mapping (bytes32 => Transaction) be;
}