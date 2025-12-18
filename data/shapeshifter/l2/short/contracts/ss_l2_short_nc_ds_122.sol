pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address bj, bytes32 ai);
  event Revoke(address bj, bytes32 ai);


  event OwnerChanged(address an, address aq);
  event OwnerAdded(address aq);
  event OwnerRemoved(address an);


  event RequirementChanged(uint f);


  event Deposit(address bq, uint value);

  event SingleTransact(address bj, uint value, address bx, bytes data, address ax);

  event MultiTransact(address bj, bytes32 ai, uint value, address bx, bytes data, address ax);

  event ConfirmationNeeded(bytes32 ai, address ak, uint value, address bx, bytes data);
}

contract WalletAbi {

  function bi(bytes32 ac) external;


  function v(address bq, address bv) external;

  function ao(address be) external;

  function t(address be) external;

  function a(uint p) external;

  function av(address bm) constant returns (bool);

  function q(bytes32 ac, address be) external constant returns (bool);


  function j(uint ad) external;

  function aw(address bv, uint bh, bytes bo) external returns (bytes32 bf);
  function az(bytes32 by) returns (bool aj);
}

contract WalletLibrary is WalletEvents {


  struct PendingState {
    uint al;
    uint y;
    uint bk;
  }


  struct Transaction {
    address bx;
    uint value;
    bytes data;
  }


  modifier ah {
    if (av(msg.sender))
      _;
  }


  modifier g(bytes32 ac) {
    if (d(ac))
      _;
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }


  function h(address[] ba, uint ae) {
    w = ba.length + 1;
    at[1] = uint(msg.sender);
    o[uint(msg.sender)] = 1;
    for (uint i = 0; i < ba.length; ++i)
    {
      at[2 + i] = uint(ba[i]);
      o[uint(ba[i])] = 2 + i;
    }
    x = ae;
  }


  function bi(bytes32 ac) external {
    uint z = o[uint(msg.sender)];

    if (z == 0) return;
    uint k = 2**z;
    var au = am[ac];
    if (au.y & k > 0) {
      au.al++;
      au.y -= k;
      Revoke(msg.sender, ac);
    }
  }


  function v(address bq, address bv) g(bu(msg.data)) external {
    if (av(bv)) return;
    uint z = o[uint(bq)];
    if (z == 0) return;

    r();
    at[z] = uint(bv);
    o[uint(bq)] = 0;
    o[uint(bv)] = z;
    OwnerChanged(bq, bv);
  }

  function ao(address be) g(bu(msg.data)) external {
    if (av(be)) return;

    r();
    if (w >= u)
      b();
    if (w >= u)
      return;
    w++;
    at[w] = uint(be);
    o[uint(be)] = w;
    OwnerAdded(be);
  }

  function t(address be) g(bu(msg.data)) external {
    uint z = o[uint(be)];
    if (z == 0) return;
    if (x > w - 1) return;

    at[z] = 0;
    o[uint(be)] = 0;
    r();
    b();
    OwnerRemoved(be);
  }

  function a(uint p) g(bu(msg.data)) external {
    if (p > w) return;
    x = p;
    r();
    RequirementChanged(p);
  }


  function ar(uint z) external constant returns (address) {
    return address(at[z + 1]);
  }

  function av(address bm) constant returns (bool) {
    return o[uint(bm)] > 0;
  }

  function q(bytes32 ac, address be) external constant returns (bool) {
    var au = am[ac];
    uint z = o[uint(be)];


    if (z == 0) return false;


    uint k = 2**z;
    return !(au.y & k == 0);
  }


  function l(uint bc) {
    m = bc;
    af = bp();
  }

  function j(uint ad) g(bu(msg.data)) external {
    m = ad;
  }

  function e() g(bu(msg.data)) external {
    s = 0;
  }


  function aa(address[] ba, uint ae, uint ag) {
    l(ag);
    h(ba, ae);
  }


  function bs(address bv) g(bu(msg.data)) external {
    suicide(bv);
  }


  function aw(address bv, uint bh, bytes bo) external ah returns (bytes32 bf) {

    if ((bo.length == 0 && ab(bh)) || x == 1) {

      address ax;
      if (bv == 0) {
        ax = bg(bh, bo);
      } else {
        if (!bv.call.value(bh)(bo))
          throw;
      }
      SingleTransact(msg.sender, bh, bv, bo, ax);
    } else {

      bf = bu(msg.data, block.number);

      if (bn[bf].bx == 0 && bn[bf].value == 0 && bn[bf].data.length == 0) {
        bn[bf].bx = bv;
        bn[bf].value = bh;
        bn[bf].data = bo;
      }
      if (!az(bf)) {
        ConfirmationNeeded(bf, msg.sender, bh, bv, bo);
      }
    }
  }

  function bg(uint bh, bytes br) internal returns (address bb) {
    assembly {
      bb := bg(bh, add(br, 0x20), mload(br))
      bl(c, iszero(extcodesize(bb)))
    }
  }


  function az(bytes32 by) g(by) returns (bool aj) {
    if (bn[by].bx != 0 || bn[by].value != 0 || bn[by].data.length != 0) {
      address ax;
      if (bn[by].bx == 0) {
        ax = bg(bn[by].value, bn[by].data);
      } else {
        if (!bn[by].bx.call.value(bn[by].value)(bn[by].data))
          throw;
      }

      MultiTransact(msg.sender, by, bn[by].value, bn[by].bx, bn[by].data, ax);
      delete bn[by];
      return true;
    }
  }


  function d(bytes32 ac) internal returns (bool) {

    uint z = o[uint(msg.sender)];

    if (z == 0) return;

    var au = am[ac];

    if (au.al == 0) {

      au.al = x;

      au.y = 0;
      au.bk = i.length++;
      i[au.bk] = ac;
    }

    uint k = 2**z;

    if (au.y & k == 0) {
      Confirmation(msg.sender, ac);

      if (au.al <= 1) {

        delete i[am[ac].bk];
        delete am[ac];
        return true;
      }
      else
      {

        au.al--;
        au.y |= k;
      }
    }
  }

  function b() private {
    uint bt = 1;
    while (bt < w)
    {
      while (bt < w && at[bt] != 0) bt++;
      while (w > 1 && at[w] == 0) w--;
      if (bt < w && at[w] != 0 && at[bt] == 0)
      {
        at[bt] = at[w];
        o[at[bt]] = bt;
        at[w] = 0;
      }
    }
  }


  function ab(uint bh) internal ah returns (bool) {

    if (bp() > af) {
      s = 0;
      af = bp();
    }


    if (s + bh >= s && s + bh <= m) {
      s += bh;
      return true;
    }
    return false;
  }


  function bp() private constant returns (uint) { return bw / 1 days; }

  function r() internal {
    uint length = i.length;

    for (uint i = 0; i < length; ++i) {
      delete bn[i[i]];

      if (i[i] != 0)
        delete am[i[i]];
    }

    delete i;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public x;

  uint public w;

  uint public m;
  uint public s;
  uint public af;


  uint[256] at;

  uint constant u = 250;

  mapping(uint => uint) o;

  mapping(bytes32 => PendingState) am;
  bytes32[] i;


  mapping (bytes32 => Transaction) bn;
}

contract Wallet is WalletEvents {


  function Wallet(address[] ba, uint ae, uint ag) {

    bytes4 sig = bytes4(bu("initWallet(address[],uint256,uint256)"));
    address bd = _walletLibrary;


    uint n = (2 + ba.length);
    uint ay = (2 + n) * 32;

    assembly {

      mstore(0x0, sig)


      as(0x4,  sub(ap, ay), ay)

      delegatecall(sub(gas, 10000), bd, 0x0, add(ay, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
    else if (msg.data.length > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function ar(uint z) constant returns (address) {
    return address(at[z + 1]);
  }


  function q(bytes32 ac, address be) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function av(address bm) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public x;

  uint public w;

  uint public m;
  uint public s;
  uint public af;


  uint[256] at;
}