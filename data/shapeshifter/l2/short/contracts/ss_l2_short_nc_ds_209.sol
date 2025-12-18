pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address be, bytes32 ad);
  event Revoke(address be, bytes32 ad);


  event OwnerChanged(address am, address an);
  event OwnerAdded(address an);
  event OwnerRemoved(address am);


  event RequirementChanged(uint i);


  event Deposit(address bg, uint value);

  event SingleTransact(address be, uint value, address bs, bytes data, address at);

  event MultiTransact(address be, bytes32 ad, uint value, address bs, bytes data, address at);

  event ConfirmationNeeded(bytes32 ad, address al, uint value, address bs, bytes data);
}

contract WalletAbi {

  function bd(bytes32 y) external;


  function s(address bg, address bq) external;

  function aq(address az) external;

  function u(address az) external;

  function b(uint o) external;

  function aw(address bi) constant returns (bool);

  function q(bytes32 y, address az) external constant returns (bool);


  function k(uint ac) external;

  function ar(address bq, uint bb, bytes bl) external returns (bytes32 ba);
  function av(bytes32 br) returns (bool ag);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint ae;
    uint z;
    uint bf;
  }


  struct Transaction {
    address bs;
    uint value;
    bytes data;
  }


  modifier ak {
    if (aw(msg.sender))
      _;
  }


  modifier f(bytes32 y) {
    if (d(y))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function g(address[] au, uint ai) a {
    t = au.length + 1;
    ap[1] = uint(msg.sender);
    n[uint(msg.sender)] = 1;
    for (uint i = 0; i < au.length; ++i)
    {
      ap[2 + i] = uint(au[i]);
      n[uint(au[i])] = 2 + i;
    }
    w = ai;
  }


  function bd(bytes32 y) external {
    uint x = n[uint(msg.sender)];

    if (x == 0) return;
    uint j = 2**x;
    var as = af[y];
    if (as.z & j > 0) {
      as.ae++;
      as.z -= j;
      Revoke(msg.sender, y);
    }
  }


  function s(address bg, address bq) f(bm(msg.data)) external {
    if (aw(bq)) return;
    uint x = n[uint(bg)];
    if (x == 0) return;

    r();
    ap[x] = uint(bq);
    n[uint(bg)] = 0;
    n[uint(bq)] = x;
    OwnerChanged(bg, bq);
  }

  function aq(address az) f(bm(msg.data)) external {
    if (aw(az)) return;

    r();
    if (t >= v)
      c();
    if (t >= v)
      return;
    t++;
    ap[t] = uint(az);
    n[uint(az)] = t;
    OwnerAdded(az);
  }

  function u(address az) f(bm(msg.data)) external {
    uint x = n[uint(az)];
    if (x == 0) return;
    if (w > t - 1) return;

    ap[x] = 0;
    n[uint(az)] = 0;
    r();
    c();
    OwnerRemoved(az);
  }

  function b(uint o) f(bm(msg.data)) external {
    if (o > t) return;
    w = o;
    r();
    RequirementChanged(o);
  }


  function ao(uint x) external constant returns (address) {
    return address(ap[x + 1]);
  }

  function aw(address bi) constant returns (bool) {
    return n[uint(bi)] > 0;
  }

  function q(bytes32 y, address az) external constant returns (bool) {
    var as = af[y];
    uint x = n[uint(az)];


    if (x == 0) return false;


    uint j = 2**x;
    return !(as.z & j == 0);
  }


  function l(uint bc) a {
    m = bc;
    aj = bj();
  }

  function k(uint ac) f(bm(msg.data)) external {
    m = ac;
  }

  function e() f(bm(msg.data)) external {
    p = 0;
  }


  modifier a { if (t > 0) throw; _; }


  function aa(address[] au, uint ai, uint ah) a {
    l(ah);
    g(au, ai);
  }


  function bn(address bq) f(bm(msg.data)) external {
    suicide(bq);
  }


  function ar(address bq, uint bb, bytes bl) external ak returns (bytes32 ba) {

    if ((bl.length == 0 && ab(bb)) || w == 1) {

      address at;
      if (bq == 0) {
        at = ay(bb, bl);
      } else {
        if (!bq.call.value(bb)(bl))
          throw;
      }
      SingleTransact(msg.sender, bb, bq, bl, at);
    } else {

      ba = bm(msg.data, block.number);

      if (bk[ba].bs == 0 && bk[ba].value == 0 && bk[ba].data.length == 0) {
        bk[ba].bs = bq;
        bk[ba].value = bb;
        bk[ba].data = bl;
      }
      if (!av(ba)) {
        ConfirmationNeeded(ba, msg.sender, bb, bq, bl);
      }
    }
  }

  function ay(uint bb, bytes bh) internal returns (address ax) {
  }


  function av(bytes32 br) f(br) returns (bool ag) {
    if (bk[br].bs != 0 || bk[br].value != 0 || bk[br].data.length != 0) {
      address at;
      if (bk[br].bs == 0) {
        at = ay(bk[br].value, bk[br].data);
      } else {
        if (!bk[br].bs.call.value(bk[br].value)(bk[br].data))
          throw;
      }

      MultiTransact(msg.sender, br, bk[br].value, bk[br].bs, bk[br].data, at);
      delete bk[br];
      return true;
    }
  }


  function d(bytes32 y) internal returns (bool) {

    uint x = n[uint(msg.sender)];

    if (x == 0) return;

    var as = af[y];

    if (as.ae == 0) {

      as.ae = w;

      as.z = 0;
      as.bf = h.length++;
      h[as.bf] = y;
    }

    uint j = 2**x;

    if (as.z & j == 0) {
      Confirmation(msg.sender, y);

      if (as.ae <= 1) {

        delete h[af[y].bf];
        delete af[y];
        return true;
      }
      else
      {

        as.ae--;
        as.z |= j;
      }
    }
  }

  function c() private {
    uint bo = 1;
    while (bo < t)
    {
      while (bo < t && ap[bo] != 0) bo++;
      while (t > 1 && ap[t] == 0) t--;
      if (bo < t && ap[t] != 0 && ap[bo] == 0)
      {
        ap[bo] = ap[t];
        n[ap[bo]] = bo;
        ap[t] = 0;
      }
    }
  }


  function ab(uint bb) internal ak returns (bool) {

    if (bj() > aj) {
      p = 0;
      aj = bj();
    }


    if (p + bb >= p && p + bb <= m) {
      p += bb;
      return true;
    }
    return false;
  }


  function bj() private constant returns (uint) { return bp / 1 days; }

  function r() internal {
    uint length = h.length;

    for (uint i = 0; i < length; ++i) {
      delete bk[h[i]];

      if (h[i] != 0)
        delete af[h[i]];
    }

    delete h;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public w;

  uint public t;

  uint public m;
  uint public p;
  uint public aj;


  uint[256] ap;

  uint constant v = 250;

  mapping(uint => uint) n;

  mapping(bytes32 => PendingState) af;
  bytes32[] h;


  mapping (bytes32 => Transaction) bk;
}