pragma solidity ^0.4.23;


contract Token {

    uint256 public ao;


    function bw(address cx) public constant returns (uint256 balance);


    function transfer(address ei, uint256 cz) public returns (bool cp);


    function aj(address dl, address ei, uint256 cz) public returns (bool cp);


    function ct(address cc, uint256 cz) public returns (bool cp);


    function bt(address cx, address cc) public constant returns (uint256 bp);

    event Transfer(address indexed dl, address indexed ei, uint256 cz);
    event Approval(address indexed cx, address indexed cc, uint256 cz);
}

library ECTools {


    function w(bytes32 be, string ed) public pure returns (address) {
        require(be != 0x00);


        bytes memory dd = "\x19Ethereum Signed Message:\n32";
        bytes32 ai = bv(abi.am(dd, be));

        if (bytes(ed).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = x(bo(ed, 2, 132));
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
        return bi(ai, v, r, s);
    }


    function bf(bytes32 be, string ed, address dt) public pure returns (bool) {
        require(dt != 0x0);

        return dt == w(be, ed);
    }


    function x(string cu) public pure returns (bytes) {
        uint ej = bytes(cu).length;
        require(ej % 2 == 0);

        bytes memory ea = bytes(new string(ej / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < ej; i += 2) {
            s = bo(cu, i, i + 1);
            r = bo(cu, i + 1, i + 2);
            uint p = p(s) * 16 + p(r);
            ea[k++] = ab(p)[31];
        }
        return ea;
    }


    function p(string dw) public pure returns (uint) {
        bytes memory ci = bytes(dw);

        if ((ci[0] >= 48) && (ci[0] <= 57)) {
            return uint(ci[0]) - 48;
        } else if ((ci[0] >= 65) && (ci[0] <= 70)) {
            return uint(ci[0]) - 55;
        } else if ((ci[0] >= 97) && (ci[0] <= 102)) {
            return uint(ci[0]) - 87;
        } else {
            revert();
        }
    }


    function ab(uint du) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), du)}
    }


    function c(string dz) public pure returns (bytes32) {
        uint ej = bytes(dz).length;
        require(ej > 0);
        bytes memory dd = "\x19Ethereum Signed Message:\n";
        return bv(abi.am(dd, al(ej), dz));
    }


    function al(uint du) public pure returns (string eh) {
        uint ej = 0;
        uint m = du + 0;
        while (m != 0) {
            ej++;
            m /= 10;
        }
        bytes memory b = new bytes(ej);
        uint i = ej - 1;
        while (du != 0) {
            uint bs = du % 10;
            du = du / 10;
            b[i--] = byte(48 + bs);
        }
        eh = string(b);
    }


    function bo(string ef, uint aw, uint bm) public pure returns (string) {
        bytes memory ch = bytes(ef);
        require(aw <= bm);
        require(aw >= 0);
        require(bm <= ch.length);

        bytes memory cy = new bytes(bm - aw);
        for (uint i = aw; i < bm; i++) {
            cy[i - aw] = ch[i];
        }
        return string(cy);
    }
}
contract StandardToken is Token {

    function transfer(address ei, uint256 cz) public returns (bool cp) {


        require(ce[msg.sender] >= cz);
        ce[msg.sender] -= cz;
        ce[ei] += cz;
        emit Transfer(msg.sender, ei, cz);
        return true;
    }

    function aj(address dl, address ei, uint256 cz) public returns (bool cp) {


        require(ce[dl] >= cz && cr[dl][msg.sender] >= cz);
        ce[ei] += cz;
        ce[dl] -= cz;
        cr[dl][msg.sender] -= cz;
        emit Transfer(dl, ei, cz);
        return true;
    }

    function bw(address cx) public constant returns (uint256 balance) {
        return ce[cx];
    }

    function ct(address cc, uint256 cz) public returns (bool cp) {
        cr[msg.sender][cc] = cz;
        emit Approval(msg.sender, cc, cz);
        return true;
    }

    function bt(address cx, address cc) public constant returns (uint256 bp) {
      return cr[cx][cc];
    }

    mapping (address => uint256) ce;
    mapping (address => mapping (address => uint256)) cr;
}

contract HumanStandardToken is StandardToken {


    string public dx;
    uint8 public cf;
    string public dh;
    string public cm = 'H0.1';

    constructor(
        uint256 t,
        string bb,
        uint8 y,
        string ag
        ) public {
        ce[msg.sender] = t;
        ao = t;
        dx = bb;
        cf = y;
        dh = ag;
    }


    function s(address cc, uint256 cz, bytes bc) public returns (bool cp) {
        cr[msg.sender][cc] = cz;
        emit Approval(msg.sender, cc, cz);


        require(cc.call(bytes4(bytes32(bv("receiveApproval(address,uint256,address,bytes)"))), msg.sender, cz, this, bc));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant VERSION = "0.0.1";

    uint256 public ar = 0;

    event DidLCOpen (
        bytes32 indexed bk,
        address indexed df,
        address indexed dc,
        uint256 as,
        address ds,
        uint256 ac,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed bk,
        uint256 av,
        uint256 u
    );

    event DidLCDeposit (
        bytes32 indexed bk,
        address indexed bn,
        uint256 cl,
        bool cs
    );

    event DidLCUpdateState (
        bytes32 indexed bk,
        uint256 cb,
        uint256 bl,
        uint256 as,
        uint256 ac,
        uint256 av,
        uint256 u,
        bytes32 cw,
        uint256 l
    );

    event DidLCClose (
        bytes32 indexed bk,
        uint256 cb,
        uint256 as,
        uint256 ac,
        uint256 av,
        uint256 u
    );

    event DidVCInit (
        bytes32 indexed eb,
        bytes32 indexed ec,
        bytes dq,
        uint256 cb,
        address df,
        address di,
        uint256 ca,
        uint256 cd
    );

    event DidVCSettle (
        bytes32 indexed eb,
        bytes32 indexed ec,
        uint256 bu,
        uint256 bh,
        uint256 bg,
        address bd,
        uint256 n
    );

    event DidVCClose(
        bytes32 indexed eb,
        bytes32 indexed ec,
        uint256 ca,
        uint256 cd
    );

    struct Channel {

        address[2] r;
        uint256[4] au;
        uint256[4] v;
        uint256[2] q;
        uint256 cb;
        uint256 ap;
        bytes32 VCrootHash;
        uint256 LCopenTimeout;
        uint256 l;
        bool da;
        bool h;
        uint256 bq;
        HumanStandardToken ds;
    }


    struct VirtualChannel {
        bool cq;
        bool f;
        uint256 cb;
        address bd;
        uint256 n;

        address df;
        address di;
        address dc;
        uint256[2] au;
        uint256[2] v;
        uint256[2] ee;
        HumanStandardToken ds;
    }

    mapping(bytes32 => VirtualChannel) public k;
    mapping(bytes32 => Channel) public Channels;

    function ae(
        bytes32 do,
        address cj,
        uint256 ak,
        address db,
        uint256[2] bx
    )
        public
        payable
    {
        require(Channels[do].r[0] == address(0), "Channel has already been created.");
        require(cj != 0x0, "No partyI address provided to LC creation");
        require(bx[0] >= 0 && bx[1] >= 0, "Balances cannot be negative");


        Channels[do].r[0] = msg.sender;
        Channels[do].r[1] = cj;

        if(bx[0] != 0) {
            require(msg.value == bx[0], "Eth balance does not match sent value");
            Channels[do].au[0] = msg.value;
        }
        if(bx[1] != 0) {
            Channels[do].ds = HumanStandardToken(db);
            require(Channels[do].ds.aj(msg.sender, this, bx[1]),"CreateChannel: token transfer failure");
            Channels[do].v[0] = bx[1];
        }

        Channels[do].cb = 0;
        Channels[do].ap = ak;


        Channels[do].LCopenTimeout = eg + ak;
        Channels[do].q = bx;

        emit DidLCOpen(do, msg.sender, cj, bx[0], db, bx[1], Channels[do].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 do) public {
        require(msg.sender == Channels[do].r[0] && Channels[do].da == false);
        require(eg > Channels[do].LCopenTimeout);

        if(Channels[do].q[0] != 0) {
            Channels[do].r[0].transfer(Channels[do].au[0]);
        }
        if(Channels[do].q[1] != 0) {
            require(Channels[do].ds.transfer(Channels[do].r[0], Channels[do].v[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(do, 0, Channels[do].au[0], Channels[do].v[0], 0, 0);


        delete Channels[do];
    }

    function aq(bytes32 do, uint256[2] bx) public payable {

        require(Channels[do].da == false);
        require(msg.sender == Channels[do].r[1]);

        if(bx[0] != 0) {
            require(msg.value == bx[0], "state balance does not match sent value");
            Channels[do].au[1] = msg.value;
        }
        if(bx[1] != 0) {
            require(Channels[do].ds.aj(msg.sender, this, bx[1]),"joinChannel: token transfer failure");
            Channels[do].v[1] = bx[1];
        }

        Channels[do].q[0]+=bx[0];
        Channels[do].q[1]+=bx[1];

        Channels[do].da = true;
        ar++;

        emit DidLCJoin(do, bx[0], bx[1]);
    }


    function cl(bytes32 do, address bn, uint256 cg, bool cs) public payable {
        require(Channels[do].da == true, "Tried adding funds to a closed channel");
        require(bn == Channels[do].r[0] || bn == Channels[do].r[1]);


        if (Channels[do].r[0] == bn) {
            if(cs) {
                require(Channels[do].ds.aj(msg.sender, this, cg),"deposit: token transfer failure");
                Channels[do].v[2] += cg;
            } else {
                require(msg.value == cg, "state balance does not match sent value");
                Channels[do].au[2] += msg.value;
            }
        }

        if (Channels[do].r[1] == bn) {
            if(cs) {
                require(Channels[do].ds.aj(msg.sender, this, cg),"deposit: token transfer failure");
                Channels[do].v[3] += cg;
            } else {
                require(msg.value == cg, "state balance does not match sent value");
                Channels[do].au[3] += msg.value;
            }
        }

        emit DidLCDeposit(do, bn, cg, cs);
    }


    function d(
        bytes32 do,
        uint256 by,
        uint256[4] bx,
        string dk,
        string dv
    )
        public
    {


        require(Channels[do].da == true);
        uint256 m = Channels[do].q[0] + Channels[do].au[2] + Channels[do].au[3];
        uint256 j = Channels[do].q[1] + Channels[do].v[2] + Channels[do].v[3];
        require(m == bx[0] + bx[1]);
        require(j == bx[2] + bx[3]);

        bytes32 dg = bv(
            abi.am(
                do,
                true,
                by,
                uint256(0),
                bytes32(0x0),
                Channels[do].r[0],
                Channels[do].r[1],
                bx[0],
                bx[1],
                bx[2],
                bx[3]
            )
        );

        require(Channels[do].r[0] == ECTools.w(dg, dk));
        require(Channels[do].r[1] == ECTools.w(dg, dv));

        Channels[do].da = false;

        if(bx[0] != 0 || bx[1] != 0) {
            Channels[do].r[0].transfer(bx[0]);
            Channels[do].r[1].transfer(bx[1]);
        }

        if(bx[2] != 0 || bx[3] != 0) {
            require(Channels[do].ds.transfer(Channels[do].r[0], bx[2]),"happyCloseChannel: token transfer failure");
            require(Channels[do].ds.transfer(Channels[do].r[1], bx[3]),"happyCloseChannel: token transfer failure");
        }

        ar--;

        emit DidLCClose(do, by, bx[0], bx[1], bx[2], bx[3]);
    }


    function ad(
        bytes32 do,
        uint256[6] af,
        bytes32 ck,
        string dk,
        string dv
    )
        public
    {
        Channel storage co = Channels[do];
        require(co.da);
        require(co.cb < af[0]);
        require(co.au[0] + co.au[1] >= af[2] + af[3]);
        require(co.v[0] + co.v[1] >= af[4] + af[5]);

        if(co.h == true) {
            require(co.l > eg);
        }

        bytes32 dg = bv(
            abi.am(
                do,
                false,
                af[0],
                af[1],
                ck,
                co.r[0],
                co.r[1],
                af[2],
                af[3],
                af[4],
                af[5]
            )
        );

        require(co.r[0] == ECTools.w(dg, dk));
        require(co.r[1] == ECTools.w(dg, dv));


        co.cb = af[0];
        co.bq = af[1];
        co.au[0] = af[2];
        co.au[1] = af[3];
        co.v[0] = af[4];
        co.v[1] = af[5];
        co.VCrootHash = ck;
        co.h = true;
        co.l = eg + co.ap;


        emit DidLCUpdateState (
            do,
            af[0],
            af[1],
            af[2],
            af[3],
            af[4],
            af[5],
            ck,
            co.l
        );
    }


    function ax(
        bytes32 do,
        bytes32 dn,
        bytes dj,
        address cn,
        address cv,
        uint256[2] dp,
        uint256[4] bx,
        string dy
    )
        public
    {
        require(Channels[do].da, "LC is closed.");

        require(!k[dn].cq, "VC is closed.");

        require(Channels[do].l < eg, "LC timeout not over.");

        require(k[dn].n == 0);

        bytes32 ba = bv(
            abi.am(dn, uint256(0), cn, cv, dp[0], dp[1], bx[0], bx[1], bx[2], bx[3])
        );


        require(cn == ECTools.w(ba, dy));


        require(ah(ba, dj, Channels[do].VCrootHash) == true);

        k[dn].df = cn;
        k[dn].di = cv;
        k[dn].cb = uint256(0);
        k[dn].au[0] = bx[0];
        k[dn].au[1] = bx[1];
        k[dn].v[0] = bx[2];
        k[dn].v[1] = bx[3];
        k[dn].ee = dp;
        k[dn].n = eg + Channels[do].ap;
        k[dn].f = true;

        emit DidVCInit(do, dn, dj, uint256(0), cn, cv, bx[0], bx[1]);
    }


    function bz(
        bytes32 do,
        bytes32 dn,
        uint256 bu,
        address cn,
        address cv,
        uint256[4] bj,
        string dy
    )
        public
    {
        require(Channels[do].da, "LC is closed.");

        require(!k[dn].cq, "VC is closed.");
        require(k[dn].cb < bu, "VC sequence is higher than update sequence.");
        require(
            k[dn].au[1] < bj[1] && k[dn].v[1] < bj[3],
            "State updates may only increase recipient balance."
        );
        require(
            k[dn].ee[0] == bj[0] + bj[1] &&
            k[dn].ee[1] == bj[2] + bj[3],
            "Incorrect balances for bonded amount");


        require(Channels[do].l < eg);

        bytes32 an = bv(
            abi.am(
                dn,
                bu,
                cn,
                cv,
                k[dn].ee[0],
                k[dn].ee[1],
                bj[0],
                bj[1],
                bj[2],
                bj[3]
            )
        );


        require(k[dn].df == ECTools.w(an, dy));


        k[dn].bd = msg.sender;
        k[dn].cb = bu;


        k[dn].au[0] = bj[0];
        k[dn].au[1] = bj[1];
        k[dn].v[0] = bj[2];
        k[dn].v[1] = bj[3];

        k[dn].n = eg + Channels[do].ap;

        emit DidVCSettle(do, dn, bu, bj[0], bj[1], msg.sender, k[dn].n);
    }

    function g(bytes32 do, bytes32 dn) public {

        require(Channels[do].da, "LC is closed.");
        require(k[dn].f, "VC is not in settlement state.");
        require(k[dn].n < eg, "Update vc timeout has not elapsed.");
        require(!k[dn].cq, "VC is already closed");

        Channels[do].bq--;

        k[dn].cq = true;


        if(k[dn].df == Channels[do].r[0]) {
            Channels[do].au[0] += k[dn].au[0];
            Channels[do].au[1] += k[dn].au[1];

            Channels[do].v[0] += k[dn].v[0];
            Channels[do].v[1] += k[dn].v[1];
        } else if (k[dn].di == Channels[do].r[0]) {
            Channels[do].au[0] += k[dn].au[1];
            Channels[do].au[1] += k[dn].au[0];

            Channels[do].v[0] += k[dn].v[1];
            Channels[do].v[1] += k[dn].v[0];
        }

        emit DidVCClose(do, dn, k[dn].v[0], k[dn].v[1]);
    }


    function e(bytes32 do) public {
        Channel storage co = Channels[do];


        require(co.da, "Channel is not open");
        require(co.h == true);
        require(co.bq == 0);
        require(co.l < eg, "LC timeout over.");


        uint256 m = co.q[0] + co.au[2] + co.au[3];
        uint256 j = co.q[1] + co.v[2] + co.v[3];

        uint256 b = co.au[0] + co.au[1];
        uint256 a = co.v[0] + co.v[1];

        if(b < m) {
            co.au[0]+=co.au[2];
            co.au[1]+=co.au[3];
        } else {
            require(b == m);
        }

        if(a < j) {
            co.v[0]+=co.v[2];
            co.v[1]+=co.v[3];
        } else {
            require(a == j);
        }

        uint256 at = co.au[0];
        uint256 ay = co.au[1];
        uint256 aa = co.v[0];
        uint256 z = co.v[1];

        co.au[0] = 0;
        co.au[1] = 0;
        co.v[0] = 0;
        co.v[1] = 0;

        if(at != 0 || ay != 0) {
            co.r[0].transfer(at);
            co.r[1].transfer(ay);
        }

        if(aa != 0 || z != 0) {
            require(
                co.ds.transfer(co.r[0], aa),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                co.ds.transfer(co.r[1], z),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        co.da = false;
        ar--;

        emit DidLCClose(do, co.cb, at, ay, aa, z);
    }

    function ah(bytes32 dm, bytes dj, bytes32 dr) internal pure returns (bool) {
        bytes32 de = dm;
        bytes32 br;

        for (uint256 i = 64; i <= dj.length; i += 32) {
            assembly { br := mload(add(dj, i)) }

            if (de < br) {
                de = bv(abi.am(de, br));
            } else {
                de = bv(abi.am(br, de));
            }
        }

        return de == dr;
    }


    function az(bytes32 ek) public view returns (
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
            co.r,
            co.au,
            co.v,
            co.q,
            co.cb,
            co.ap,
            co.VCrootHash,
            co.LCopenTimeout,
            co.l,
            co.da,
            co.h,
            co.bq
        );
    }

    function i(bytes32 ek) public view returns(
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
        VirtualChannel memory o = k[ek];
        return(
            o.cq,
            o.f,
            o.cb,
            o.bd,
            o.n,
            o.df,
            o.di,
            o.dc,
            o.au,
            o.v,
            o.ee
        );
    }
}