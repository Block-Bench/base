pragma solidity ^0.4.24;

contract ERC20 {
    function cy() constant returns (uint hu);
    function fg( address jd ) constant returns (uint value);
    function fd( address ij, address gq ) constant returns (uint du);

    function transfer( address ji, uint value) returns (bool jl);
    function cu( address from, address ji, uint value) returns (bool jl);
    function gv( address gq, uint value ) returns (bool jl);

    event Transfer( address indexed from, address indexed ji, uint value);
    event Approval( address indexed ij, address indexed gq, uint value);
}
contract Ownable {
  address public ij;

  function Ownable() {
    ij = msg.sender;
  }

  modifier eu() {
    require(msg.sender == ij);
    _;
  }

  function ap(address fm) eu {
    if (fm != address(0)) {
      ij = fm;
    }
  }

}


contract ERC721 {

    function cy() public view returns (uint256 ie);
    function fg(address he) public view returns (uint256 balance);
    function gg(uint256 fk) external view returns (address ij);
    function gv(address jf, uint256 fk) external;
    function transfer(address jf, uint256 fk) external;
    function cu(address hy, address jf, uint256 fk) external;


    event Transfer(address from, address ji, uint256 gw);
    event Approval(address ij, address fn, uint256 gw);


    function ak(bytes4 cw) external view returns (bool);
}

contract GeneScienceInterface {

    function bs() public pure returns (bool);


    function fy(uint256[2] ho, uint256[2] hg,uint256 jh,uint256 jj, uint256 dl) public returns (uint256[2]);

    function ax(uint256[2] ir) public view returns(uint256);


    function hb(uint256[2] ir) public view returns(uint256);


    function do(uint256[2] ir) public view returns(uint256);

    function bw(uint256[2] ih) public returns(uint256[2]);
}


contract PandaAccessControl {


    event ContractUpgrade(address dr);


    address public ds;
    address public ed;
    address public ea;


    bool public hp = false;


    modifier gj() {
        require(msg.sender == ds);
        _;
    }


    modifier gd() {
        require(msg.sender == ed);
        _;
    }


    modifier ge() {
        require(msg.sender == ea);
        _;
    }

    modifier dt() {
        require(
            msg.sender == ea ||
            msg.sender == ds ||
            msg.sender == ed
        );
        _;
    }


    function hi(address gf) external gj {
        require(gf != address(0));

        ds = gf;
    }


    function hv(address gm) external gj {
        require(gm != address(0));

        ed = gm;
    }


    function gz(address gk) external gj {
        require(gk != address(0));

        ea = gk;
    }


    modifier ce() {
        require(!hp);
        _;
    }


    modifier ej {
        require(hp);
        _;
    }


    function ii() external dt ce {
        hp = true;
    }


    function gp() public gj ej {

        hp = false;
    }
}


contract PandaBase is PandaAccessControl {


    uint256 public constant GEN0_TOTAL_COUNT = 16200;
    uint256 public as;


    event Birth(address ij, uint256 gu, uint256 ft, uint256 hh, uint256[2] ig);


    event Transfer(address from, address ji, uint256 gw);


    struct Panda {


        uint256[2] ig;


        uint64 em;


        uint64 av;


        uint32 ft;
        uint32 hh;


        uint32 ck;


        uint16 bq;


        uint16 dx;
    }


    uint32[9] public el = [
        uint32(5 minutes),
        uint32(30 minutes),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(24 hours),
        uint32(48 hours),
        uint32(72 hours),
        uint32(7 days)
    ];


    uint256 public ay = 15;


    Panda[] hd;


    mapping (uint256 => address) public am;


    mapping (address => uint256) y;


    mapping (uint256 => address) public o;


    mapping (uint256 => address) public s;


    SaleClockAuction public df;


    SiringClockAuction public ca;


    GeneScienceInterface public dj;

    SaleClockAuctionERC20 public ar;


    mapping (uint256 => uint256) public bl;
    mapping (uint256 => uint256) public bj;


    function aa(uint256 iz) view external returns(uint256) {
        return bl[iz];
    }

    function u(uint256 iz) view external returns(uint256) {
        return bj[iz];
    }

    function w(uint256 iz,uint256 hn) external dt {
        require (bl[iz]==0);
        require (hn==uint256(uint32(hn)));
        bl[iz] = hn;
    }

    function cf(uint256 iy) view external returns(uint256) {
        Panda memory jk = hd[iy];
        return dj.do(jk.ig);
    }


    function ey(address hy, address jf, uint256 fk) internal {

        y[jf]++;

        am[fk] = jf;

        if (hy != address(0)) {
            y[hy]--;

            delete s[fk];

            delete o[fk];
        }

        Transfer(hy, jf, fk);
    }


    function cq(
        uint256 ex,
        uint256 gx,
        uint256 dc,
        uint256[2] hs,
        address he
    )
        internal
        returns (uint)
    {


        require(ex == uint256(uint32(ex)));
        require(gx == uint256(uint32(gx)));
        require(dc == uint256(uint16(dc)));


        uint16 bq = 0;

        if (hd.length>0){
            uint16 ee = uint16(dj.ax(hs));
            if (ee==0) {
                ee = 1;
            }
            bq = 1000/ee;
            if (bq%10 < 5){
                bq = bq/10;
            }else{
                bq = bq/10 + 1;
            }
            bq = bq - 1;
            if (bq > 8) {
                bq = 8;
            }
            uint256 iz = dj.do(hs);
            if (iz>0 && bl[iz]<=bj[iz]) {
                hs = dj.bw(hs);
                iz = 0;
            }

            if (iz == 1){
                bq = 5;
            }


            if (iz>0){
                bj[iz] = bj[iz] + 1;
            }

            if (dc <= 1 && iz != 1){
                require(as<GEN0_TOTAL_COUNT);
                as++;
            }
        }

        Panda memory hl = Panda({
            ig: hs,
            em: uint64(jg),
            av: 0,
            ft: uint32(ex),
            hh: uint32(gx),
            ck: 0,
            bq: bq,
            dx: uint16(dc)
        });
        uint256 da = hd.push(hl) - 1;


        require(da == uint256(uint32(da)));


        Birth(
            he,
            da,
            uint256(hl.ft),
            uint256(hl.hh),
            hl.ig
        );


        ey(0, he, da);

        return da;
    }


    function ae(uint256 it) external dt {
        require(it < el[0]);
        ay = it;
    }
}


contract ERC721Metadata {

    function db(uint256 fk, string) public view returns (bytes32[4] hw, uint256 il) {
        if (fk == 1) {
            hw[0] = "Hello World! :D";
            il = 15;
        } else if (fk == 2) {
            hw[0] = "I would definitely choose a medi";
            hw[1] = "um length string.";
            il = 49;
        } else if (fk == 3) {
            hw[0] = "Lorem ipsum dolor sit amet, mi e";
            hw[1] = "st accumsan dapibus augue lorem,";
            hw[2] = " tristique vestibulum id, libero";
            hw[3] = " suscipit varius sapien aliquam.";
            il = 128;
        }
    }
}


contract PandaOwnership is PandaBase, ERC721 {


    string public constant im = "PandaEarth";
    string public constant hr = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(ff('ak(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(ff('im()')) ^
        bytes4(ff('hr()')) ^
        bytes4(ff('cy()')) ^
        bytes4(ff('fg(address)')) ^
        bytes4(ff('gg(uint256)')) ^
        bytes4(ff('gv(address,uint256)')) ^
        bytes4(ff('transfer(address,uint256)')) ^
        bytes4(ff('cu(address,address,uint256)')) ^
        bytes4(ff('cb(address)')) ^
        bytes4(ff('tokenMetadata(uint256,string)'));


    function ak(bytes4 cw) external view returns (bool)
    {


        return ((cw == InterfaceSignature_ERC165) || (cw == InterfaceSignature_ERC721));
    }


    function hz(address ew, uint256 fk) internal view returns (bool) {
        return am[fk] == ew;
    }


    function cn(address ew, uint256 fk) internal view returns (bool) {
        return o[fk] == ew;
    }


    function fl(uint256 fk, address ep) internal {
        o[fk] = ep;
    }


    function fg(address he) public view returns (uint256 il) {
        return y[he];
    }


    function transfer(
        address jf,
        uint256 fk
    )
        external
        ce
    {

        require(jf != address(0));


        require(jf != address(this));


        require(jf != address(df));
        require(jf != address(ca));


        require(hz(msg.sender, fk));


        ey(msg.sender, jf, fk);
    }


    function gv(
        address jf,
        uint256 fk
    )
        external
        ce
    {

        require(hz(msg.sender, fk));


        fl(fk, jf);


        Approval(msg.sender, jf, fk);
    }


    function cu(
        address hy,
        address jf,
        uint256 fk
    )
        external
        ce
    {

        require(jf != address(0));


        require(jf != address(this));

        require(cn(msg.sender, fk));
        require(hz(hy, fk));


        ey(hy, jf, fk);
    }


    function cy() public view returns (uint) {
        return hd.length - 1;
    }


    function gg(uint256 fk)
        external
        view
        returns (address ij)
    {
        ij = am[fk];

        require(ij != address(0));
    }


    function cb(address he) external view returns(uint256[] dd) {
        uint256 eb = fg(he);

        if (eb == 0) {

            return new uint256[](0);
        } else {
            uint256[] memory hf = new uint256[](eb);
            uint256 er = cy();
            uint256 dn = 0;


            uint256 hx;

            for (hx = 1; hx <= er; hx++) {
                if (am[hx] == he) {
                    hf[dn] = hx;
                    dn++;
                }
            }

            return hf;
        }
    }


    function gl(uint ib, uint is, uint ip) private view {

        for(; ip >= 32; ip -= 32) {
            assembly {
                mstore(ib, mload(is))
            }
            ib += 32;
            is += 32;
        }


        uint256 iq = 256 ** (32 - ip) - 1;
        assembly {
            let gt := and(mload(is), not(iq))
            let fs := and(mload(ib), iq)
            mstore(ib, or(fs, gt))
        }
    }


    function eo(bytes32[4] fa, uint256 bt) private view returns (string) {
        var cx = new string(bt);
        uint256 fh;
        uint256 fr;

        assembly {
            fh := add(cx, 32)
            fr := fa
        }

        gl(fh, fr, bt);

        return cx;
    }

}


contract PandaBreeding is PandaOwnership {

    uint256 public constant GENSIS_TOTAL_COUNT = 100;


    event Pregnant(address ij, uint256 ft, uint256 hh, uint256 av);

    event Abortion(address ij, uint256 ft, uint256 hh);


    uint256 public co = 2 finney;


    uint256 public bm;

    mapping(uint256 => address) ei;


    function k(address fj) external gj {
        GeneScienceInterface al = GeneScienceInterface(fj);


        require(al.bs());


        dj = al;
    }


    function bc(Panda iw) internal view returns(bool) {


        return (iw.ck == 0) && (iw.av <= uint64(block.number));
    }


    function ah(uint256 gx, uint256 ex) internal view returns(bool) {
        address dh = am[ex];
        address eq = am[gx];


        return (dh == eq || s[gx] == dh);
    }


    function at(Panda storage go) internal {

        go.av = uint64((el[go.bq] / ay) + block.number);


        if (go.bq < 8 && dj.do(go.ig) != 1) {
            go.bq += 1;
        }
    }


    function cd(address if, uint256 gx)
    external
    ce {
        require(hz(msg.sender, gx));
        s[gx] = if;
    }


    function az(uint256 jb) external ge {
        co = jb;
    }


    function x(Panda gn) private view returns(bool) {
        return (gn.ck != 0) && (gn.av <= uint64(block.number));
    }


    function bh(uint256 fo)
    public
    view
    returns(bool) {
        require(fo > 0);
        Panda storage ja = hd[fo];
        return bc(ja);
    }


    function ef(uint256 fo)
    public
    view
    returns(bool) {
        require(fo > 0);

        return hd[fo].ck != 0;
    }


    function ag(
        Panda storage gn,
        uint256 ex,
        Panda storage id,
        uint256 gx
    )
    private
    view
    returns(bool) {

        if (ex == gx) {
            return false;
        }


        if (gn.ft == gx || gn.hh == gx) {
            return false;
        }
        if (id.ft == ex || id.hh == ex) {
            return false;
        }


        if (id.ft == 0 || gn.ft == 0) {
            return true;
        }


        if (id.ft == gn.ft || id.ft == gn.hh) {
            return false;
        }
        if (id.hh == gn.ft || id.hh == gn.hh) {
            return false;
        }


        if (dj.hb(gn.ig) + dj.hb(id.ig) != 1) {
            return false;
        }


        return true;
    }


    function g(uint256 ex, uint256 gx)
    internal
    view
    returns(bool) {
        Panda storage ha = hd[ex];
        Panda storage io = hd[gx];
        return ag(ha, ex, io, gx);
    }


    function cm(uint256 ex, uint256 gx)
    external
    view
    returns(bool) {
        require(ex > 0);
        require(gx > 0);
        Panda storage ha = hd[ex];
        Panda storage io = hd[gx];
        return ag(ha, ex, io, gx) &&
            ah(gx, ex);
    }

    function l(uint256 ex, uint256 gx) internal returns(uint256, uint256) {
        if (dj.hb(hd[ex].ig) == 1) {
            return (gx, ex);
        } else {
            return (ex, gx);
        }
    }


    function eh(uint256 ex, uint256 gx, address he) internal {

        (ex, gx) = l(ex, gx);

        Panda storage io = hd[gx];
        Panda storage ha = hd[ex];


        ha.ck = uint32(gx);


        at(io);
        at(ha);


        delete s[ex];
        delete s[gx];


        bm++;

        ei[ex] = he;


        Pregnant(am[ex], ex, gx, ha.av);
    }


    function cc(uint256 ex, uint256 gx)
    external
    payable
    ce {

        require(msg.value >= co);


        require(hz(msg.sender, ex));


        require(ah(gx, ex));


        Panda storage ha = hd[ex];


        require(bc(ha));


        Panda storage io = hd[gx];


        require(bc(io));


        require(ag(
            ha,
            ex,
            io,
            gx
        ));


        eh(ex, gx, msg.sender);
    }


    function fc(uint256 ex, uint256[2] dk, uint256[2] ga)
    external
    ce
    dt
    returns(uint256) {

        Panda storage ha = hd[ex];


        require(ha.em != 0);


        require(x(ha));


        uint256 hh = ha.ck;
        Panda storage io = hd[hh];


        uint16 en = ha.dx;
        if (io.dx > ha.dx) {
            en = io.dx;
        }


        uint256[2] memory dz = dk;

        uint256 fi = 0;


        uint256 dg = (dj.ax(ha.ig) + dj.ax(io.ig)) / 2 + ga[0];
        if (dg >= (en + 1) * ga[1]) {
            dg = dg - (en + 1) * ga[1];
        } else {
            dg = 0;
        }
        if (en == 0 && as == GEN0_TOTAL_COUNT) {
            dg = 0;
        }
        if (uint256(ff(block.blockhash(block.number - 2), jg)) % 100 < dg) {

            address ij = ei[ex];
            fi = cq(ex, ha.ck, en + 1, dz, ij);
        } else {
            Abortion(am[ex], ex, hh);
        }


        delete ha.ck;


        bm--;


        msg.sender.send(co);

        delete ei[ex];


        return fi;
    }
}


contract ClockAuctionBase {


    struct Auction {

        address hk;

        uint128 br;

        uint128 di;

        uint64 fq;


        uint64 ez;

        uint64 hj;
    }


    ERC721 public ab;


    uint256 public gc;


    mapping (uint256 => Auction) aw;

    event AuctionCreated(uint256 gw, uint256 br, uint256 di, uint256 fq);
    event AuctionSuccessful(uint256 gw, uint256 dv, address ht);
    event AuctionCancelled(uint256 gw);


    function hz(address ew, uint256 fk) internal view returns (bool) {
        return (ab.gg(fk) == ew);
    }


    function gh(address he, uint256 fk) internal {

        ab.cu(he, this, fk);
    }


    function ey(address fe, uint256 fk) internal {

        ab.transfer(fe, fk);
    }


    function de(uint256 fk, Auction fw) internal {


        require(fw.fq >= 1 minutes);

        aw[fk] = fw;

        AuctionCreated(
            uint256(fk),
            uint256(fw.br),
            uint256(fw.di),
            uint256(fw.fq)
        );
    }


    function bf(uint256 fk, address gs) internal {
        bk(fk);
        ey(gs, fk);
        AuctionCancelled(fk);
    }


    function iv(uint256 fk, uint256 dy)
        internal
        returns (uint256)
    {

        Auction storage gy = aw[fk];


        require(cp(gy));


        uint256 ia = bn(gy);
        require(dy >= ia);


        address hk = gy.hk;


        bk(fk);


        if (ia > 0) {


            uint256 bu = cz(ia);
            uint256 bg = ia - bu;


            hk.transfer(bg);
        }


        uint256 et = dy - ia;


        msg.sender.transfer(et);


        AuctionSuccessful(fk, ia, msg.sender);

        return ia;
    }


    function bk(uint256 fk) internal {
        delete aw[fk];
    }


    function cp(Auction storage fw) internal view returns (bool) {
        return (fw.ez > 0);
    }


    function bn(Auction storage fw)
        internal
        view
        returns (uint256)
    {
        uint256 ci = 0;


        if (jg > fw.ez) {
            ci = jg - fw.ez;
        }

        return p(
            fw.br,
            fw.di,
            fw.fq,
            ci
        );
    }


    function p(
        uint256 be,
        uint256 cr,
        uint256 es,
        uint256 bi
    )
        internal
        pure
        returns (uint256)
    {


        if (bi >= es) {


            return cr;
        } else {


            int256 au = int256(cr) - int256(be);


            int256 af = au * int256(bi) / int256(es);


            int256 ct = int256(be) + af;

            return uint256(ct);
        }
    }


    function cz(uint256 hm) internal view returns (uint256) {


        return hm * gc / 10000;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public hp = false;

  modifier ce() {
    require(!hp);
    _;
  }

  modifier ej {
    require(hp);
    _;
  }

  function ii() eu ce returns (bool) {
    hp = true;
    Pause();
    return true;
  }

  function gp() eu ej returns (bool) {
    hp = false;
    Unpause();
    return true;
  }
}


contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);


    function ClockAuction(address dm, uint256 iu) public {
        require(iu <= 10000);
        gc = iu;

        ERC721 al = ERC721(dm);
        require(al.ak(InterfaceSignature_ERC721));
        ab = al;
    }


    function bd() external {
        address eg = address(ab);

        require(
            msg.sender == ij ||
            msg.sender == eg
        );

        bool je = eg.send(this.balance);
    }


    function bz(
        uint256 fk,
        uint256 be,
        uint256 cr,
        uint256 es,
        address gs
    )
        external
        ce
    {


        require(be == uint256(uint128(be)));
        require(cr == uint256(uint128(cr)));
        require(es == uint256(uint64(es)));

        require(hz(msg.sender, fk));
        gh(msg.sender, fk);
        Auction memory gy = Auction(
            gs,
            uint128(be),
            uint128(cr),
            uint64(es),
            uint64(jg),
            0
        );
        de(fk, gy);
    }


    function ix(uint256 fk)
        external
        payable
        ce
    {

        iv(fk, msg.value);
        ey(msg.sender, fk);
    }


    function cg(uint256 fk)
        external
    {
        Auction storage gy = aw[fk];
        require(cp(gy));
        address hk = gy.hk;
        require(msg.sender == hk);
        bf(fk, hk);
    }


    function e(uint256 fk)
        ej
        eu
        external
    {
        Auction storage gy = aw[fk];
        require(cp(gy));
        bf(fk, gy.hk);
    }


    function dw(uint256 fk)
        external
        view
        returns
    (
        address hk,
        uint256 br,
        uint256 di,
        uint256 fq,
        uint256 ez
    ) {
        Auction storage gy = aw[fk];
        require(cp(gy));
        return (
            gy.hk,
            gy.br,
            gy.di,
            gy.fq,
            gy.ez
        );
    }


    function ba(uint256 fk)
        external
        view
        returns (uint256)
    {
        Auction storage gy = aw[fk];
        require(cp(gy));
        return bn(gy);
    }

}


contract SiringClockAuction is ClockAuction {


    bool public t = true;


    function SiringClockAuction(address fx, uint256 iu) public
        ClockAuction(fx, iu) {}


    function bz(
        uint256 fk,
        uint256 be,
        uint256 cr,
        uint256 es,
        address gs
    )
        external
    {


        require(be == uint256(uint128(be)));
        require(cr == uint256(uint128(cr)));
        require(es == uint256(uint64(es)));

        require(msg.sender == address(ab));
        gh(gs, fk);
        Auction memory gy = Auction(
            gs,
            uint128(be),
            uint128(cr),
            uint64(es),
            uint64(jg),
            0
        );
        de(fk, gy);
    }


    function ix(uint256 fk)
        external
        payable
    {
        require(msg.sender == address(ab));
        address hk = aw[fk].hk;

        iv(fk, msg.value);


        ey(hk, fk);
    }

}


contract SaleClockAuction is ClockAuction {


    bool public ac = true;


    uint256 public cj;
    uint256[5] public ad;
    uint256 public constant SurpriseValue = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaIndex;
    uint256   RarePandaIndex;


    function SaleClockAuction(address fx, uint256 iu) public
        ClockAuction(fx, iu) {
            CommonPandaIndex = 1;
            RarePandaIndex   = 1;
    }


    function bz(
        uint256 fk,
        uint256 be,
        uint256 cr,
        uint256 es,
        address gs
    )
        external
    {


        require(be == uint256(uint128(be)));
        require(cr == uint256(uint128(cr)));
        require(es == uint256(uint64(es)));

        require(msg.sender == address(ab));
        gh(gs, fk);
        Auction memory gy = Auction(
            gs,
            uint128(be),
            uint128(cr),
            uint64(es),
            uint64(jg),
            0
        );
        de(fk, gy);
    }

    function ao(
        uint256 fk,
        uint256 be,
        uint256 cr,
        uint256 es,
        address gs
    )
        external
    {


        require(be == uint256(uint128(be)));
        require(cr == uint256(uint128(cr)));
        require(es == uint256(uint64(es)));

        require(msg.sender == address(ab));
        gh(gs, fk);
        Auction memory gy = Auction(
            gs,
            uint128(be),
            uint128(cr),
            uint64(es),
            uint64(jg),
            1
        );
        de(fk, gy);
    }


    function ix(uint256 fk)
        external
        payable
    {

        uint64 hj = aw[fk].hj;
        uint256 ia = iv(fk, msg.value);
        ey(msg.sender, fk);


        if (hj == 1) {

            ad[cj % 5] = ia;
            cj++;
        }
    }

    function dq(uint256 fk,uint256 ik)
        external
    {
        require(msg.sender == address(ab));
        if (ik == 0) {
            CommonPanda.push(fk);
        }else {
            RarePanda.push(fk);
        }
    }

    function bo()
        external
        payable
    {
        bytes32 ic = ff(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaIndex;
        if (ic[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaIndex);
            PandaIndex = RarePandaIndex;
            RarePandaIndex ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaIndex);
            PandaIndex = CommonPandaIndex;
            CommonPandaIndex ++;
        }
        ey(msg.sender,PandaIndex);
    }

    function cs() external view returns(uint256 hq,uint256 fz) {
        hq   = CommonPanda.length + 1 - CommonPandaIndex;
        fz = RarePanda.length + 1 - RarePandaIndex;
    }

    function r() external view returns (uint256) {
        uint256 jc = 0;
        for (uint256 i = 0; i < 5; i++) {
            jc += ad[i];
        }
        return jc / 5;
    }

}


contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 gw, uint256 br, uint256 di, uint256 fq, address bv);


    bool public d = true;

    mapping (uint256 => address) public j;

    mapping (address => uint256) public h;

    mapping (address => uint256) public fv;


    function SaleClockAuctionERC20(address fx, uint256 iu) public
        ClockAuction(fx, iu) {}

    function v(address bx, uint256 hc) external{
        require (msg.sender == address(ab));

        require (bx != address(0));

        h[bx] = hc;
    }


    function bz(
        uint256 fk,
        address ch,
        uint256 be,
        uint256 cr,
        uint256 es,
        address gs
    )
        external
    {


        require(be == uint256(uint128(be)));
        require(cr == uint256(uint128(cr)));
        require(es == uint256(uint64(es)));

        require(msg.sender == address(ab));

        require (h[ch] > 0);

        gh(gs, fk);
        Auction memory gy = Auction(
            gs,
            uint128(be),
            uint128(cr),
            uint64(es),
            uint64(jg),
            0
        );
        aq(fk, gy, ch);
        j[fk] = ch;
    }


    function aq(uint256 fk, Auction fw, address bx) internal {


        require(fw.fq >= 1 minutes);

        aw[fk] = fw;

        AuctionERC20Created(
            uint256(fk),
            uint256(fw.br),
            uint256(fw.di),
            uint256(fw.fq),
            bx
        );
    }

    function ix(uint256 fk)
        external
        payable{

    }


    function fp(uint256 fk,uint256 gr)
        external
    {

        address hk = aw[fk].hk;
        address bx = j[fk];
        require (bx != address(0));
        uint256 ia = ev(bx,msg.sender,fk, gr);
        ey(msg.sender, fk);
        delete j[fk];
    }

    function cg(uint256 fk)
        external
    {
        Auction storage gy = aw[fk];
        require(cp(gy));
        address hk = gy.hk;
        require(msg.sender == hk);
        bf(fk, hk);
        delete j[fk];
    }

    function q(address ch, address jf) external returns(bool je)  {
        require (fv[ch] > 0);
        require(msg.sender == address(ab));
        ERC20(ch).transfer(jf, fv[ch]);
    }


    function ev(address ch,address by, uint256 fk, uint256 dy)
        internal
        returns (uint256)
    {

        Auction storage gy = aw[fk];


        require(cp(gy));

        require (ch != address(0) && ch == j[fk]);


        uint256 ia = bn(gy);
        require(dy >= ia);


        address hk = gy.hk;


        bk(fk);


        if (ia > 0) {


            uint256 bu = cz(ia);
            uint256 bg = ia - bu;


            require(ERC20(ch).cu(by,hk,bg));
            if (bu > 0){
                require(ERC20(ch).cu(by,address(this),bu));
                fv[ch] += bu;
            }
        }


        AuctionSuccessful(fk, ia, msg.sender);

        return ia;
    }
}


contract PandaAuction is PandaBreeding {


    function m(address fj) external gj {
        SaleClockAuction al = SaleClockAuction(fj);


        require(al.ac());


        df = al;
    }

    function a(address fj) external gj {
        SaleClockAuctionERC20 al = SaleClockAuctionERC20(fj);


        require(al.d());


        ar = al;
    }


    function f(address fj) external gj {
        SiringClockAuction al = SiringClockAuction(fj);


        require(al.t());


        ca = al;
    }


    function an(
        uint256 fo,
        uint256 be,
        uint256 cr,
        uint256 es
    )
        external
        ce
    {


        require(hz(msg.sender, fo));


        require(!ef(fo));
        fl(fo, df);


        df.bz(
            fo,
            be,
            cr,
            es,
            msg.sender
        );
    }


    function i(
        uint256 fo,
        address bx,
        uint256 be,
        uint256 cr,
        uint256 es
    )
        external
        ce
    {


        require(hz(msg.sender, fo));


        require(!ef(fo));
        fl(fo, ar);


        ar.bz(
            fo,
            bx,
            be,
            cr,
            es,
            msg.sender
        );
    }

    function b(address bx, uint256 hc) external ge{
        ar.v(bx,hc);
    }


    function z(
        uint256 fo,
        uint256 be,
        uint256 cr,
        uint256 es
    )
        external
        ce
    {


        require(hz(msg.sender, fo));
        require(bh(fo));
        fl(fo, ca);


        ca.bz(
            fo,
            be,
            cr,
            es,
            msg.sender
        );
    }


    function aj(
        uint256 gx,
        uint256 ex
    )
        external
        payable
        ce
    {

        require(hz(msg.sender, ex));
        require(bh(ex));
        require(g(ex, gx));


        uint256 ct = ca.ba(gx);
        require(msg.value >= ct + co);


        ca.ix.value(msg.value - co)(gx);
        eh(uint32(ex), uint32(gx), msg.sender);
    }


    function c() external dt {
        df.bd();
        ca.bd();
    }

    function q(address ch, address jf) external dt {
        require(ar != address(0));
        ar.q(ch,jf);
    }
}


contract PandaMinting is PandaAuction {


    uint256 public constant GEN0_CREATION_LIMIT = 45000;


    uint256 public constant GEN0_STARTING_PRICE = 100 finney;
    uint256 public constant GEN0_AUCTION_DURATION = 1 days;
    uint256 public constant OPEN_PACKAGE_PRICE = 10 finney;


    function bb(uint256[2] hs, uint256 dc, address he) external ge {
        address ek = he;
        if (ek == address(0)) {
            ek = ea;
        }

        cq(0, 0, dc, hs, ek);
    }


    function dq(uint256[2] hs,uint256 dc,uint256 ik)
        external
        payable
        ge
        ce
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 fi = cq(0, 0, dc, hs, df);
        df.dq(fi,ik);
    }


    function ao(uint256 fo) external ge {
        require(hz(msg.sender, fo));


        fl(fo, df);

        df.ao(
            fo,
            n(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }


    function n() internal view returns(uint256) {
        uint256 gb = df.r();

        require(gb == uint256(uint128(gb)));

        uint256 fb = gb + (gb / 2);


        if (fb < GEN0_STARTING_PRICE) {
            fb = GEN0_STARTING_PRICE;
        }

        return fb;
    }
}


contract PandaCore is PandaMinting {


    address public ai;


    function PandaCore() public {

        hp = true;


        ds = msg.sender;


        ea = msg.sender;


    }


    function in() external gj ej {

        require(hd.length == 0);

        uint256[2] memory hs = [uint256(-1),uint256(-1)];

        bl[1] = 100;
       cq(0, 0, 0, hs, address(0));
    }


    function bp(address ec) external gj ej {

        ai = ec;
        ContractUpgrade(ec);
    }


    function() external payable {
        require(
            msg.sender == address(df) ||
            msg.sender == address(ca)
        );
    }


    function fu(uint256 iy)
        external
        view
        returns (
        bool dp,
        bool gi,
        uint256 bq,
        uint256 cv,
        uint256 ck,
        uint256 em,
        uint256 ft,
        uint256 hh,
        uint256 dx,
        uint256[2] ig
    ) {
        Panda storage ja = hd[iy];


        dp = (ja.ck != 0);
        gi = (ja.av <= block.number);
        bq = uint256(ja.bq);
        cv = uint256(ja.av);
        ck = uint256(ja.ck);
        em = uint256(ja.em);
        ft = uint256(ja.ft);
        hh = uint256(ja.hh);
        dx = uint256(ja.dx);
        ig = ja.ig;
    }


    function gp() public gj ej {
        require(df != address(0));
        require(ca != address(0));
        require(dj != address(0));
        require(ai == address(0));


        super.gp();
    }


    function bd() external gd {
        uint256 balance = this.balance;

        uint256 cl = (bm + 1) * co;

        if (balance > cl) {
            ed.send(balance - cl);
        }
    }
}