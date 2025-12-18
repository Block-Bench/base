pragma solidity ^0.4.23;


 contract Token {

     uint256 public as;


     function bs(address dc) public constant returns (uint256 balance);


     function transfer(address eg, uint256 dj) public returns (bool cm);


     function ai(address dw, address eg, uint256 dj) public returns (bool cm);


     function ck(address cd, uint256 dj) public returns (bool cm);


     function bp(address dc, address cd) public constant returns (uint256 bx);

     event Transfer(address indexed dw, address indexed eg, uint256 dj);
     event Approval(address indexed dc, address indexed cd, uint256 dj);
 }

 library ECTools {


     function ae(bytes32 bf, string ed) public pure returns (address) {
         require(bf != 0x00);


         bytes memory cz = "\x19Ethereum Signed Message:\n32";
         bytes32 ah = bm(abi.ag(cz, bf));

         if (bytes(ed).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = y(bj(ed, 2, 132));
         assembly {
             r := mload(add(sig, 32))
             s := mload(add(sig, 64))
             v := byte(0, mload(add(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return bv(ah, v, r, s);
     }


     function bb(bytes32 bf, string ed, address ds) public pure returns (bool) {
         require(ds != 0x0);

         return ds == ae(bf, ed);
     }


     function y(string ci) public pure returns (bytes) {
         uint eh = bytes(ci).length;
         require(eh % 2 == 0);

         bytes memory dy = bytes(new string(eh / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < eh; i += 2) {
             s = bj(ci, i, i + 1);
             r = bj(ci, i + 1, i + 2);
             uint p = q(s) * 16 + q(r);
             dy[k++] = u(p)[31];
         }
         return dy;
     }


     function q(string dp) public pure returns (uint) {
         bytes memory cr = bytes(dp);

         if ((cr[0] >= 48) && (cr[0] <= 57)) {
             return uint(cr[0]) - 48;
         } else if ((cr[0] >= 65) && (cr[0] <= 70)) {
             return uint(cr[0]) - 55;
         } else if ((cr[0] >= 97) && (cr[0] <= 102)) {
             return uint(cr[0]) - 87;
         } else {
             revert();
         }
     }


     function u(uint dm) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(add(b, 32), dm)}
     }


     function c(string ef) public pure returns (bytes32) {
         uint eh = bytes(ef).length;
         require(eh > 0);
         bytes memory cz = "\x19Ethereum Signed Message:\n";
         return bm(abi.ag(cz, al(eh), ef));
     }


     function al(uint dm) public pure returns (string ei) {
         uint eh = 0;
         uint m = dm + 0;
         while (m != 0) {
             eh++;
             m /= 10;
         }
         bytes memory b = new bytes(eh);
         uint i = eh - 1;
         while (dm != 0) {
             uint bn = dm % 10;
             dm = dm / 10;
             b[i--] = byte(48 + bn);
         }
         ei = string(b);
     }


     function bj(string dz, uint ay, uint by) public pure returns (string) {
         bytes memory cb = bytes(dz);
         require(ay <= by);
         require(ay >= 0);
         require(by <= cb.length);

         bytes memory dg = new bytes(by - ay);
         for (uint i = ay; i < by; i++) {
             dg[i - ay] = cb[i];
         }
         return string(dg);
     }
 }
 contract StandardToken is Token {

     function transfer(address eg, uint256 dj) public returns (bool cm) {


         require(cc[msg.sender] >= dj);
         cc[msg.sender] -= dj;
         cc[eg] += dj;
         emit Transfer(msg.sender, eg, dj);
         return true;
     }

     function ai(address dw, address eg, uint256 dj) public returns (bool cm) {


         require(cc[dw] >= dj && cp[dw][msg.sender] >= dj);
         cc[eg] += dj;
         cc[dw] -= dj;
         cp[dw][msg.sender] -= dj;
         emit Transfer(dw, eg, dj);
         return true;
     }

     function bs(address dc) public constant returns (uint256 balance) {
         return cc[dc];
     }

     function ck(address cd, uint256 dj) public returns (bool cm) {
         cp[msg.sender][cd] = dj;
         emit Approval(msg.sender, cd, dj);
         return true;
     }

     function bp(address dc, address cd) public constant returns (uint256 bx) {
       return cp[dc][cd];
     }

     mapping (address => uint256) cc;
     mapping (address => mapping (address => uint256)) cp;
 }

 contract HumanStandardToken is StandardToken {


     string public dx;
     uint8 public ce;
     string public cy;
     string public cj = 'H0.1';

     constructor(
         uint256 t,
         string bh,
         uint8 z,
         string ak
         ) public {
         cc[msg.sender] = t;
         as = t;
         dx = bh;
         ce = z;
         cy = ak;
     }


     function o(address cd, uint256 dj, bytes az) public returns (bool cm) {
         cp[msg.sender][cd] = dj;
         emit Approval(msg.sender, cd, dj);


         require(cd.call(bytes4(bytes32(bm("receiveApproval(address,uint256,address,bytes)"))), msg.sender, dj, this, az));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant VERSION = "0.0.1";

     uint256 public ax = 0;

     event DidLCOpen (
         bytes32 indexed bk,
         address indexed cx,
         address indexed cw,
         uint256 au,
         address dl,
         uint256 ac,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed bk,
         uint256 ar,
         uint256 v
     );

     event DidLCDeposit (
         bytes32 indexed bk,
         address indexed bi,
         uint256 cq,
         bool ct
     );

     event DidLCUpdateState (
         bytes32 indexed bk,
         uint256 cf,
         uint256 bt,
         uint256 au,
         uint256 ac,
         uint256 ar,
         uint256 v,
         bytes32 di,
         uint256 l
     );

     event DidLCClose (
         bytes32 indexed bk,
         uint256 cf,
         uint256 au,
         uint256 ac,
         uint256 ar,
         uint256 v
     );

     event DidVCInit (
         bytes32 indexed ee,
         bytes32 indexed eb,
         bytes dv,
         uint256 cf,
         address cx,
         address db,
         uint256 cg,
         uint256 ca
     );

     event DidVCSettle (
         bytes32 indexed ee,
         bytes32 indexed eb,
         uint256 bw,
         uint256 ba,
         uint256 bg,
         address bc,
         uint256 k
     );

     event DidVCClose(
         bytes32 indexed ee,
         bytes32 indexed eb,
         uint256 cg,
         uint256 ca
     );

     struct Channel {

         address[2] p;
         uint256[4] ao;
         uint256[4] ab;
         uint256[2] s;
         uint256 cf;
         uint256 aq;
         bytes32 VCrootHash;
         uint256 LCopenTimeout;
         uint256 l;
         bool dh;
         bool h;
         uint256 br;
         HumanStandardToken dl;
     }


     struct VirtualChannel {
         bool cs;
         bool f;
         uint256 cf;
         address bc;
         uint256 k;

         address cx;
         address db;
         address cw;
         uint256[2] ao;
         uint256[2] ab;
         uint256[2] ec;
         HumanStandardToken dl;
     }

     mapping(bytes32 => VirtualChannel) public n;
     mapping(bytes32 => Channel) public Channels;

     function ad(
         bytes32 dn,
         address cl,
         uint256 an,
         address da,
         uint256[2] bq
     )
         public
         payable
     {
         require(Channels[dn].p[0] == address(0), "Channel has already been created.");
         require(cl != 0x0, "No partyI address provided to LC creation");
         require(bq[0] >= 0 && bq[1] >= 0, "Balances cannot be negative");


         Channels[dn].p[0] = msg.sender;
         Channels[dn].p[1] = cl;

         if(bq[0] != 0) {
             require(msg.value == bq[0], "Eth balance does not match sent value");
             Channels[dn].ao[0] = msg.value;
         }
         if(bq[1] != 0) {
             Channels[dn].dl = HumanStandardToken(da);
             require(Channels[dn].dl.ai(msg.sender, this, bq[1]),"CreateChannel: token transfer failure");
             Channels[dn].ab[0] = bq[1];
         }

         Channels[dn].cf = 0;
         Channels[dn].aq = an;


         Channels[dn].LCopenTimeout = ej + an;
         Channels[dn].s = bq;

         emit DidLCOpen(dn, msg.sender, cl, bq[0], da, bq[1], Channels[dn].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 dn) public {
         require(msg.sender == Channels[dn].p[0] && Channels[dn].dh == false);
         require(ej > Channels[dn].LCopenTimeout);

         if(Channels[dn].s[0] != 0) {
             Channels[dn].p[0].transfer(Channels[dn].ao[0]);
         }
         if(Channels[dn].s[1] != 0) {
             require(Channels[dn].dl.transfer(Channels[dn].p[0], Channels[dn].ab[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(dn, 0, Channels[dn].ao[0], Channels[dn].ab[0], 0, 0);


         delete Channels[dn];
     }

     function aw(bytes32 dn, uint256[2] bq) public payable {

         require(Channels[dn].dh == false);
         require(msg.sender == Channels[dn].p[1]);

         if(bq[0] != 0) {
             require(msg.value == bq[0], "state balance does not match sent value");
             Channels[dn].ao[1] = msg.value;
         }
         if(bq[1] != 0) {
             require(Channels[dn].dl.ai(msg.sender, this, bq[1]),"joinChannel: token transfer failure");
             Channels[dn].ab[1] = bq[1];
         }

         Channels[dn].s[0]+=bq[0];
         Channels[dn].s[1]+=bq[1];

         Channels[dn].dh = true;
         ax++;

         emit DidLCJoin(dn, bq[0], bq[1]);
     }


     function cq(bytes32 dn, address bi, uint256 bz, bool ct) public payable {
         require(Channels[dn].dh == true, "Tried adding funds to a closed channel");
         require(bi == Channels[dn].p[0] || bi == Channels[dn].p[1]);


         if (Channels[dn].p[0] == bi) {
             if(ct) {
                 require(Channels[dn].dl.ai(msg.sender, this, bz),"deposit: token transfer failure");
                 Channels[dn].ab[2] += bz;
             } else {
                 require(msg.value == bz, "state balance does not match sent value");
                 Channels[dn].ao[2] += msg.value;
             }
         }

         if (Channels[dn].p[1] == bi) {
             if(ct) {
                 require(Channels[dn].dl.ai(msg.sender, this, bz),"deposit: token transfer failure");
                 Channels[dn].ab[3] += bz;
             } else {
                 require(msg.value == bz, "state balance does not match sent value");
                 Channels[dn].ao[3] += msg.value;
             }
         }

         emit DidLCDeposit(dn, bi, bz, ct);
     }


     function e(
         bytes32 dn,
         uint256 bu,
         uint256[4] bq,
         string dt,
         string dr
     )
         public
     {


         require(Channels[dn].dh == true);
         uint256 m = Channels[dn].s[0] + Channels[dn].ao[2] + Channels[dn].ao[3];
         uint256 i = Channels[dn].s[1] + Channels[dn].ab[2] + Channels[dn].ab[3];
         require(m == bq[0] + bq[1]);
         require(i == bq[2] + bq[3]);

         bytes32 dd = bm(
             abi.ag(
                 dn,
                 true,
                 bu,
                 uint256(0),
                 bytes32(0x0),
                 Channels[dn].p[0],
                 Channels[dn].p[1],
                 bq[0],
                 bq[1],
                 bq[2],
                 bq[3]
             )
         );

         require(Channels[dn].p[0] == ECTools.ae(dd, dt));
         require(Channels[dn].p[1] == ECTools.ae(dd, dr));

         Channels[dn].dh = false;

         if(bq[0] != 0 || bq[1] != 0) {
             Channels[dn].p[0].transfer(bq[0]);
             Channels[dn].p[1].transfer(bq[1]);
         }

         if(bq[2] != 0 || bq[3] != 0) {
             require(Channels[dn].dl.transfer(Channels[dn].p[0], bq[2]),"happyCloseChannel: token transfer failure");
             require(Channels[dn].dl.transfer(Channels[dn].p[1], bq[3]),"happyCloseChannel: token transfer failure");
         }

         ax--;

         emit DidLCClose(dn, bu, bq[0], bq[1], bq[2], bq[3]);
     }


     function aa(
         bytes32 dn,
         uint256[6] aj,
         bytes32 cu,
         string dt,
         string dr
     )
         public
     {
         Channel storage co = Channels[dn];
         require(co.dh);
         require(co.cf < aj[0]);
         require(co.ao[0] + co.ao[1] >= aj[2] + aj[3]);
         require(co.ab[0] + co.ab[1] >= aj[4] + aj[5]);

         if(co.h == true) {
             require(co.l > ej);
         }

         bytes32 dd = bm(
             abi.ag(
                 dn,
                 false,
                 aj[0],
                 aj[1],
                 cu,
                 co.p[0],
                 co.p[1],
                 aj[2],
                 aj[3],
                 aj[4],
                 aj[5]
             )
         );

         require(co.p[0] == ECTools.ae(dd, dt));
         require(co.p[1] == ECTools.ae(dd, dr));


         co.cf = aj[0];
         co.br = aj[1];
         co.ao[0] = aj[2];
         co.ao[1] = aj[3];
         co.ab[0] = aj[4];
         co.ab[1] = aj[5];
         co.VCrootHash = cu;
         co.h = true;
         co.l = ej + co.aq;


         emit DidLCUpdateState (
             dn,
             aj[0],
             aj[1],
             aj[2],
             aj[3],
             aj[4],
             aj[5],
             cu,
             co.l
         );
     }


     function at(
         bytes32 dn,
         bytes32 du,
         bytes de,
         address cn,
         address cv,
         uint256[2] dk,
         uint256[4] bq,
         string ea
     )
         public
     {
         require(Channels[dn].dh, "LC is closed.");

         require(!n[du].cs, "VC is closed.");

         require(Channels[dn].l < ej, "LC timeout not over.");

         require(n[du].k == 0);

         bytes32 be = bm(
             abi.ag(du, uint256(0), cn, cv, dk[0], dk[1], bq[0], bq[1], bq[2], bq[3])
         );


         require(cn == ECTools.ae(be, ea));


         require(af(be, de, Channels[dn].VCrootHash) == true);

         n[du].cx = cn;
         n[du].db = cv;
         n[du].cf = uint256(0);
         n[du].ao[0] = bq[0];
         n[du].ao[1] = bq[1];
         n[du].ab[0] = bq[2];
         n[du].ab[1] = bq[3];
         n[du].ec = dk;
         n[du].k = ej + Channels[dn].aq;
         n[du].f = true;

         emit DidVCInit(dn, du, de, uint256(0), cn, cv, bq[0], bq[1]);
     }


     function ch(
         bytes32 dn,
         bytes32 du,
         uint256 bw,
         address cn,
         address cv,
         uint256[4] bo,
         string ea
     )
         public
     {
         require(Channels[dn].dh, "LC is closed.");

         require(!n[du].cs, "VC is closed.");
         require(n[du].cf < bw, "VC sequence is higher than update sequence.");
         require(
             n[du].ao[1] < bo[1] && n[du].ab[1] < bo[3],
             "State updates may only increase recipient balance."
         );
         require(
             n[du].ec[0] == bo[0] + bo[1] &&
             n[du].ec[1] == bo[2] + bo[3],
             "Incorrect balances for bonded amount");


         require(Channels[dn].l < ej);

         bytes32 am = bm(
             abi.ag(
                 du,
                 bw,
                 cn,
                 cv,
                 n[du].ec[0],
                 n[du].ec[1],
                 bo[0],
                 bo[1],
                 bo[2],
                 bo[3]
             )
         );


         require(n[du].cx == ECTools.ae(am, ea));


         n[du].bc = msg.sender;
         n[du].cf = bw;


         n[du].ao[0] = bo[0];
         n[du].ao[1] = bo[1];
         n[du].ab[0] = bo[2];
         n[du].ab[1] = bo[3];

         n[du].k = ej + Channels[dn].aq;

         emit DidVCSettle(dn, du, bw, bo[0], bo[1], msg.sender, n[du].k);
     }

     function g(bytes32 dn, bytes32 du) public {

         require(Channels[dn].dh, "LC is closed.");
         require(n[du].f, "VC is not in settlement state.");
         require(n[du].k < ej, "Update vc timeout has not elapsed.");
         require(!n[du].cs, "VC is already closed");

         Channels[dn].br--;

         n[du].cs = true;


         if(n[du].cx == Channels[dn].p[0]) {
             Channels[dn].ao[0] += n[du].ao[0];
             Channels[dn].ao[1] += n[du].ao[1];

             Channels[dn].ab[0] += n[du].ab[0];
             Channels[dn].ab[1] += n[du].ab[1];
         } else if (n[du].db == Channels[dn].p[0]) {
             Channels[dn].ao[0] += n[du].ao[1];
             Channels[dn].ao[1] += n[du].ao[0];

             Channels[dn].ab[0] += n[du].ab[1];
             Channels[dn].ab[1] += n[du].ab[0];
         }

         emit DidVCClose(dn, du, n[du].ab[0], n[du].ab[1]);
     }


     function d(bytes32 dn) public {
         Channel storage co = Channels[dn];


         require(co.dh, "Channel is not open");
         require(co.h == true);
         require(co.br == 0);
         require(co.l < ej, "LC timeout over.");


         uint256 m = co.s[0] + co.ao[2] + co.ao[3];
         uint256 i = co.s[1] + co.ab[2] + co.ab[3];

         uint256 b = co.ao[0] + co.ao[1];
         uint256 a = co.ab[0] + co.ab[1];

         if(b < m) {
             co.ao[0]+=co.ao[2];
             co.ao[1]+=co.ao[3];
         } else {
             require(b == m);
         }

         if(a < i) {
             co.ab[0]+=co.ab[2];
             co.ab[1]+=co.ab[3];
         } else {
             require(a == i);
         }

         uint256 av = co.ao[0];
         uint256 ap = co.ao[1];
         uint256 x = co.ab[0];
         uint256 w = co.ab[1];

         co.ao[0] = 0;
         co.ao[1] = 0;
         co.ab[0] = 0;
         co.ab[1] = 0;

         if(av != 0 || ap != 0) {
             co.p[0].transfer(av);
             co.p[1].transfer(ap);
         }

         if(x != 0 || w != 0) {
             require(
                 co.dl.transfer(co.p[0], x),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 co.dl.transfer(co.p[1], w),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         co.dh = false;
         ax--;

         emit DidLCClose(dn, co.cf, av, ap, x, w);
     }

     function af(bytes32 do, bytes de, bytes32 dq) internal pure returns (bool) {
         bytes32 df = do;
         bytes32 bl;

         for (uint256 i = 64; i <= de.length; i += 32) {
             assembly { bl := mload(add(de, i)) }

             if (df < bl) {
                 df = bm(abi.ag(df, bl));
             } else {
                 df = bm(abi.ag(bl, df));
             }
         }

         return df == dq;
     }


     function bd(bytes32 ek) public view returns (
         address[2],
         uint256[4],
         uint256[4],
         uint256[2],
         uint256,
         uint256,
         bytes32,
         uint256,
         uint256,
         bool,
         bool,
         uint256
     ) {
         Channel memory co = Channels[ek];
         return (
             co.p,
             co.ao,
             co.ab,
             co.s,
             co.cf,
             co.aq,
             co.VCrootHash,
             co.LCopenTimeout,
             co.l,
             co.dh,
             co.h,
             co.br
         );
     }

     function j(bytes32 ek) public view returns(
         bool,
         bool,
         uint256,
         address,
         uint256,
         address,
         address,
         address,
         uint256[2],
         uint256[2],
         uint256[2]
     ) {
         VirtualChannel memory r = n[ek];
         return(
             r.cs,
             r.f,
             r.cf,
             r.bc,
             r.k,
             r.cx,
             r.db,
             r.cw,
             r.ao,
             r.ab,
             r.ec
         );
     }
 }