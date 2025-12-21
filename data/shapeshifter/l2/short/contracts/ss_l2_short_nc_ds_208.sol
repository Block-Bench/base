pragma solidity 0.4.9;

contract WalletEvents {


  event Confirmation(address bp, bytes32 ag);
  event Revoke(address bp, bytes32 ag);


  event OwnerChanged(address at, address an);
  event OwnerAdded(address an);
  event OwnerRemoved(address at);


  event RequirementChanged(uint i);


  event Deposit(address bk, uint value);

  event SingleTransact(address bp, uint value, address bx, bytes data, address aw);

  event MultiTransact(address bp, bytes32 ag, uint value, address bx, bytes data, address aw);

  event ConfirmationNeeded(bytes32 ag, address ai, uint value, address bx, bytes data);
}

contract WalletAbi {

  function bg(bytes32 ab) external;


  function u(address bk, address bv) external;

  function as(address bd) external;

  function w(address bd) external;

  function a(uint p) external;

  function az(address bm) constant returns (bool);

  function n(bytes32 ab, address bd) external constant returns (bool);


  function k(uint ah) external;

  function au(address bv, uint be, bytes bq) external returns (bytes32 bf);
  function ba(bytes32 by) returns (bool am);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint aj;
    uint aa;
    uint bn;
  }


  struct Transaction {
    address bx;
    uint value;
    bytes data;
  }


  modifier af {
    if (az(msg.sender))
      _;
  }


  modifier g(bytes32 ab) {
    if (e(ab))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function f(address[] ay, uint ak) {
    t = ay.length + 1;
    aq[1] = uint(msg.sender);
    s[uint(msg.sender)] = 1;
    for (uint i = 0; i < ay.length; ++i)
    {
      aq[2 + i] = uint(ay[i]);
      s[uint(ay[i])] = 2 + i;
    }
    z = ak;
  }


  function bg(bytes32 ab) external {
    uint x = s[uint(msg.sender)];

    if (x == 0) return;
    uint j = 2**x;
    var ax = ad[ab];
    if (ax.aa & j > 0) {
      ax.aj++;
      ax.aa -= j;
      Revoke(msg.sender, ab);
    }
  }


  function u(address bk, address bv) g(bt(msg.data)) external {
    if (az(bv)) return;
    uint x = s[uint(bk)];
    if (x == 0) return;

    o();
    aq[x] = uint(bv);
    s[uint(bk)] = 0;
    s[uint(bv)] = x;
    OwnerChanged(bk, bv);
  }

  function as(address bd) g(bt(msg.data)) external {
    if (az(bd)) return;

    o();
    if (t >= v)
      b();
    if (t >= v)
      return;
    t++;
    aq[t] = uint(bd);
    s[uint(bd)] = t;
    OwnerAdded(bd);
  }

  function w(address bd) g(bt(msg.data)) external {
    uint x = s[uint(bd)];
    if (x == 0) return;
    if (z > t - 1) return;

    aq[x] = 0;
    s[uint(bd)] = 0;
    o();
    b();
    OwnerRemoved(bd);
  }

  function a(uint p) g(bt(msg.data)) external {
    if (p > t) return;
    z = p;
    o();
    RequirementChanged(p);
  }


  function ap(uint x) external constant returns (address) {
    return address(aq[x + 1]);
  }

  function az(address bm) constant returns (bool) {
    return s[uint(bm)] > 0;
  }

  function n(bytes32 ab, address bd) external constant returns (bool) {
    var ax = ad[ab];
    uint x = s[uint(bd)];


    if (x == 0) return false;


    uint j = 2**x;
    return !(ax.aa & j == 0);
  }


  function l(uint bh) {
    m = bh;
    ae = br();
  }

  function k(uint ah) g(bt(msg.data)) external {
    m = ah;
  }

  function d() g(bt(msg.data)) external {
    q = 0;
  }


  function ac(address[] ay, uint ak, uint al) {
    l(al);
    f(ay, ak);
  }


  function bu(address bv) g(bt(msg.data)) external {
    suicide(bv);
  }


  function au(address bv, uint be, bytes bq) external af returns (bytes32 bf) {

    if ((bq.length == 0 && y(be)) || z == 1) {

      address aw;
      if (bv == 0) {
        aw = bc(be, bq);
      } else {
        if (!bv.call.value(be)(bq))
          throw;
      }
      SingleTransact(msg.sender, be, bv, bq, aw);
    } else {

      bf = bt(msg.data, block.number);

      if (bl[bf].bx == 0 && bl[bf].value == 0 && bl[bf].data.length == 0) {
        bl[bf].bx = bv;
        bl[bf].value = be;
        bl[bf].data = bq;
      }
      if (!ba(bf)) {
        ConfirmationNeeded(bf, msg.sender, be, bv, bq);
      }
    }
  }

  function bc(uint be, bytes bo) internal returns (address bb) {
    assembly {
      bb := bc(be, add(bo, 0x20), mload(bo))
      bj(c, iszero(extcodesize(bb)))
    }
  }


  function ba(bytes32 by) g(by) returns (bool am) {
    if (bl[by].bx != 0 || bl[by].value != 0 || bl[by].data.length != 0) {
      address aw;
      if (bl[by].bx == 0) {
        aw = bc(bl[by].value, bl[by].data);
      } else {
        if (!bl[by].bx.call.value(bl[by].value)(bl[by].data))
          throw;
      }

      MultiTransact(msg.sender, by, bl[by].value, bl[by].bx, bl[by].data, aw);
      delete bl[by];
      return true;
    }
  }


  function e(bytes32 ab) internal returns (bool) {

    uint x = s[uint(msg.sender)];

    if (x == 0) return;

    var ax = ad[ab];

    if (ax.aj == 0) {

      ax.aj = z;

      ax.aa = 0;
      ax.bn = h.length++;
      h[ax.bn] = ab;
    }

    uint j = 2**x;

    if (ax.aa & j == 0) {
      Confirmation(msg.sender, ab);

      if (ax.aj <= 1) {

        delete h[ad[ab].bn];
        delete ad[ab];
        return true;
      }
      else
      {

        ax.aj--;
        ax.aa |= j;
      }
    }
  }

  function b() private {
    uint bs = 1;
    while (bs < t)
    {
      while (bs < t && aq[bs] != 0) bs++;
      while (t > 1 && aq[t] == 0) t--;
      if (bs < t && aq[t] != 0 && aq[bs] == 0)
      {
        aq[bs] = aq[t];
        s[aq[bs]] = bs;
        aq[t] = 0;
      }
    }
  }


  function y(uint be) internal af returns (bool) {

    if (br() > ae) {
      q = 0;
      ae = br();
    }


    if (q + be >= q && q + be <= m) {
      q += be;
      return true;
    }
    return false;
  }


  function br() private constant returns (uint) { return bw / 1 days; }

  function o() internal {
    uint length = h.length;

    for (uint i = 0; i < length; ++i) {
      delete bl[h[i]];

      if (h[i] != 0)
        delete ad[h[i]];
    }

    delete h;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public z;

  uint public t;

  uint public m;
  uint public q;
  uint public ae;


  uint[256] aq;

  uint constant v = 250;

  mapping(uint => uint) s;

  mapping(bytes32 => PendingState) ad;
  bytes32[] h;


  mapping (bytes32 => Transaction) bl;
}

contract Wallet is WalletEvents {


  function Wallet(address[] ay, uint ak, uint al) {

    bytes4 sig = bytes4(bt("initWallet(address[],uint256,uint256)"));
    address bi = _walletLibrary;


    uint r = (2 + ay.length);
    uint av = (2 + r) * 32;

    assembly {

      mstore(0x0, sig)


      ar(0x4,  sub(ao, av), av)

      delegatecall(sub(gas, 10000), bi, 0x0, add(av, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function ap(uint x) constant returns (address) {
    return address(aq[x + 1]);
  }


  function n(bytes32 ab, address bd) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function az(address bm) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public z;

  uint public t;

  uint public m;
  uint public q;
  uint public ae;


  uint[256] aq;
}