pragma solidity 0.8.13;

import {IERC721, IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import "./interfaces/IHybra.sol";
import {IHybraVotes} from "./interfaces/IHybraVotes.sol";
import {IVeArtProxy} from "./interfaces/IVeArtProxy.sol";
import {IVotingEscrow} from "./interfaces/IVotingEscrow.sol";
import {IVoter} from "./interfaces/IVoter.sol";
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import {VotingDelegationLib} from "./libraries/VotingDelegationLib.sol";
import {VotingBalanceLogic} from "./libraries/VotingBalanceLogic.sol";


contract VotingEscrow is IERC721, IERC721Metadata, IHybraVotes {
    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME
    }


    event Deposit(
        address indexed eo,
        uint fo,
        uint value,
        uint indexed fb,
        DepositType br,
        uint hs
    );

    event Merge(
        address indexed fn,
        uint256 indexed hc,
        uint256 indexed hk,
        uint256 cp,
        uint256 ef,
        uint256 cd,
        uint256 du,
        uint256 hq
    );
    event Split(
        uint256 indexed hc,
        uint256 indexed ea,
        uint256 indexed ed,
        address fn,
        uint256 bm,
        uint256 bf,
        uint256 du,
        uint256 hq
    );

    event MultiSplit(
        uint256 indexed hc,
        uint256[] bt,
        address fn,
        uint256[] ey,
        uint256 du,
        uint256 hq
    );

    event MetadataUpdate(uint256 fa);
    event BatchMetadataUpdate(uint256 cc, uint256 cz);

    event Withdraw(address indexed eo, uint fo, uint value, uint hs);
    event LockPermanent(address indexed gd, uint256 indexed fa, uint256 gf, uint256 hq);
    event UnlockPermanent(address indexed gd, uint256 indexed fa, uint256 gf, uint256 hq);
    event Supply(uint dm, uint ga);


    address public immutable gn;
    address public gv;
    address public hf;
    address public eq;


    uint public PRECISISON = 10000;


    mapping(bytes4 => bool) internal l;
    mapping(uint => bool) internal as;


    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;


    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;


    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;


    uint internal fo;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal ej;
    IHybra public gy;


    VotingDelegationLib.Data private gi;

    VotingBalanceLogic.Data private d;


    constructor(address dj, address eb) {
        gn = dj;
        gv = msg.sender;
        hf = msg.sender;
        eq = eb;
        WEEK = HybraTimeLibrary.WEEK;
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        ej = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION));

        d.az[0].hn = block.number;
        d.az[0].hs = block.timestamp;

        l[ERC165_INTERFACE_ID] = true;
        l[ERC721_INTERFACE_ID] = true;
        l[ERC721_METADATA_INTERFACE_ID] = true;
        gy = IHybra(gn);


        emit Transfer(address(0), address(this), fo);

        emit Transfer(address(this), address(0), fo);
    }


    uint8 internal constant bp = 1;
    uint8 internal constant el = 2;
    uint8 internal ar = 1;
    modifier ca() {
        require(ar == bp);
        ar = el;
        _;
        ar = bp;
    }

    modifier bh(uint256 fa) {
        require(!as[fa], "PNFT");
        _;
    }

    modifier bx(uint hc) {
        require(fd[msg.sender] || fd[address(0)], "!SPLIT");
        require(cf[hc] == 0 && !gw[hc], "ATT");
        require(r(msg.sender, hc), "NAO");
        _;
    }


    string constant public he = "veHYBR";
    string constant public fx = "veHYBR";
    string constant public ff = "1.0.0";
    uint8 constant public ex = 18;

    function fj(address gx) external {
        require(msg.sender == hf);
        hf = gx;
    }

    function cg(address fy) external {
        require(msg.sender == hf);
        eq = fy;
        emit BatchMetadataUpdate(0, type(uint256).hl);
    }


    function al(uint fa, bool dd) external {
        require(msg.sender == hf, "NA");
        require(dw[fa] != address(0), "DNE");
        as[fa] = dd;
    }


    function et(uint fa) external view returns (string memory) {
        require(dw[fa] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory fk = ge[fa];

        return IVeArtProxy(eq).do(fa,VotingBalanceLogic.bu(fa, block.timestamp, d),fk.hp,uint(int256(fk.gf)));
    }


    mapping(uint => address) internal dw;


    mapping(address => uint) internal k;


    function fe(uint fa) public view returns (address) {
        return dw[fa];
    }

    function e(address gm) public view returns (uint) {

        return k[gm];
    }


    function ek(address gd) internal view returns (uint) {
        return k[gd];
    }


    function ec(address gd) external view returns (uint) {
        return ek(gd);
    }


    mapping(uint => address) internal bd;


    mapping(address => mapping(address => bool)) internal ac;

    mapping(uint => uint) public z;


    function ch(uint fa) external view returns (address) {
        return bd[fa];
    }


    function ad(address gd, address dq) external view returns (bool) {
        return (ac[gd])[dq];
    }


    function fg(address ei, uint fa) public {
        address gm = dw[fa];

        require(gm != address(0), "ZA");

        require(ei != gm, "IA");

        bool bg = (dw[fa] == msg.sender);
        bool c = (ac[gm])[msg.sender];
        require(bg || c, "NAO");

        bd[fa] = ei;
        emit Approval(gm, ei, fa);
    }


    function x(address dq, bool ei) external {

        assert(dq != msg.sender);
        ac[msg.sender][dq] = ei;
        emit ApprovalForAll(msg.sender, dq, ei);
    }


    function av(address gd, uint fa) internal {

        assert(dw[fa] == gd);
        if (bd[fa] != address(0)) {

            bd[fa] = address(0);
        }
    }


    function r(address ew, uint fa) internal view returns (bool) {
        address gm = dw[fa];
        bool ay = gm == ew;
        bool w = ew == bd[fa];
        bool b = (ac[gm])[ew];
        return ay || w || b;
    }

    function v(address ew, uint fa) external view returns (bool) {
        return r(ew, fa);
    }


    function bb(
        address hc,
        address hk,
        uint fa,
        address fn
    ) internal bh(fa) {
        require(cf[fa] == 0 && !gw[fa], "ATT");

        require(r(fn, fa), "NAO");


        av(hc, fa);

        ab(hc, fa);

        VotingDelegationLib.n(gi, dy(hc), dy(hk), fa, fe);

        cw(hk, fa);

        z[fa] = block.number;


        emit Transfer(hc, hk, fa);
    }


    function by(
        address hc,
        address hk,
        uint fa
    ) external {
        bb(hc, hk, fa, msg.sender);
    }


    function ae(
        address hc,
        address hk,
        uint fa
    ) external {
        ae(hc, hk, fa, "");
    }

    function cv(address fm) internal view returns (bool) {


        uint hj;
        assembly {
            hj := extcodesize(fm)
        }
        return hj > 0;
    }


    function ae(
        address hc,
        address hk,
        uint fa,
        bytes memory gt
    ) public {
        bb(hc, hk, fa, msg.sender);

        if (cv(hk)) {

            try IERC721Receiver(hk).af(msg.sender, hc, fa, gt) returns (bytes4 en) {
                if (en != IERC721Receiver(hk).af.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory fw) {
                if (fw.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, fw), mload(fw))
                    }
                }
            }
        }
    }


    function u(bytes4 bq) external view returns (bool) {
        return l[bq];
    }


    mapping(address => mapping(uint => uint)) internal h;


    mapping(uint => uint) internal t;


    function m(address gd, uint ce) public view returns (uint) {
        return h[gd][ce];
    }


    function i(address hk, uint fa) internal {
        uint be = ek(hk);

        h[hk][be] = fa;
        t[fa] = be;
    }


    function cw(address hk, uint fa) internal {

        assert(dw[fa] == address(0));

        dw[fa] = hk;

        i(hk, fa);

        k[hk] += 1;
    }


    function hb(address hk, uint fa) internal returns (bool) {

        assert(hk != address(0));

        VotingDelegationLib.n(gi, address(0), dy(hk), fa, fe);

        cw(hk, fa);
        emit Transfer(address(0), hk, fa);
        return true;
    }


    function a(address hc, uint fa) internal {

        uint be = ek(hc) - 1;
        uint bn = t[fa];

        if (be == bn) {

            h[hc][be] = 0;

            t[fa] = 0;
        } else {
            uint cx = h[hc][be];


            h[hc][bn] = cx;

            t[cx] = bn;


            h[hc][be] = 0;

            t[fa] = 0;
        }
    }


    function ab(address hc, uint fa) internal {

        assert(dw[fa] == hc);

        dw[fa] = address(0);

        a(hc, fa);

        k[hc] -= 1;
    }

    function ha(uint fa) internal {
        require(r(msg.sender, fa), "NAO");

        address gm = fe(fa);


        delete bd[fa];


        ab(gm, fa);

        VotingDelegationLib.n(gi, dy(gm), address(0), fa, fe);

        emit Transfer(gm, address(0), fa);
    }


    mapping(uint => IVotingEscrow.LockedBalance) public ge;
    uint public f;
    uint public gz;
    mapping(uint => int128) public ba;
    uint public ga;
    mapping(address => bool) public fd;

    uint internal constant MULTIPLIER = 1 ether;


    function j(uint fa) external view returns (int128) {
        uint gb = d.aa[fa];
        return d.q[fa][gb].gu;
    }


    function q(uint fa, uint hg) external view returns (IVotingEscrow.Point memory) {
        return d.q[fa][hg];
    }

    function az(uint gz) external view returns (IVotingEscrow.Point memory) {
        return d.az[gz];
    }

    function aa(uint fo) external view returns (uint) {
        return d.aa[fo];
    }


    function ck(
        uint fa,
        IVotingEscrow.LockedBalance memory dc,
        IVotingEscrow.LockedBalance memory db
    ) internal {
        IVotingEscrow.Point memory gp;
        IVotingEscrow.Point memory hd;
        int128 dn = 0;
        int128 di = 0;
        uint ft = gz;

        if (fa != 0) {
            hd.dz = 0;

            if(db.cq){
                hd.dz = uint(int256(db.gf));
            }


            if (dc.hp > block.timestamp && dc.gf > 0) {
                gp.gu = dc.gf / ej;
                gp.hh = gp.gu * int128(int256(dc.hp - block.timestamp));
            }
            if (db.hp > block.timestamp && db.gf > 0) {
                hd.gu = db.gf / ej;
                hd.hh = hd.gu * int128(int256(db.hp - block.timestamp));
            }


            dn = ba[dc.hp];
            if (db.hp != 0) {
                if (db.hp == dc.hp) {
                    di = dn;
                } else {
                    di = ba[db.hp];
                }
            }
        }

        IVotingEscrow.Point memory da = IVotingEscrow.Point({hh: 0, gu: 0, hs: block.timestamp, hn: block.number, dz: 0});
        if (ft > 0) {
            da = d.az[ft];
        }
        uint aj = da.hs;


        IVotingEscrow.Point memory p = da;
        uint ct = 0;
        if (block.timestamp > da.hs) {
            ct = (MULTIPLIER * (block.number - da.hn)) / (block.timestamp - da.hs);
        }


        {
            uint hm = (aj / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {


                hm += WEEK;
                int128 fp = 0;
                if (hm > block.timestamp) {
                    hm = block.timestamp;
                } else {
                    fp = ba[hm];
                }
                da.hh -= da.gu * int128(int256(hm - aj));
                da.gu += fp;
                if (da.hh < 0) {

                    da.hh = 0;
                }
                if (da.gu < 0) {

                    da.gu = 0;
                }
                aj = hm;
                da.hs = hm;
                da.hn = p.hn + (ct * (hm - p.hs)) / MULTIPLIER;
                ft += 1;
                if (hm == block.timestamp) {
                    da.hn = block.number;
                    break;
                } else {
                    d.az[ft] = da;
                }
            }
        }

        gz = ft;


        if (fa != 0) {


            da.gu += (hd.gu - gp.gu);
            da.hh += (hd.hh - gp.hh);
            if (da.gu < 0) {
                da.gu = 0;
            }
            if (da.hh < 0) {
                da.hh = 0;
            }
            da.dz = f;
        }


        d.az[ft] = da;

        if (fa != 0) {


            if (dc.hp > block.timestamp) {

                dn += gp.gu;
                if (db.hp == dc.hp) {
                    dn -= hd.gu;
                }
                ba[dc.hp] = dn;
            }

            if (db.hp > block.timestamp) {
                if (db.hp > dc.hp) {
                    di -= hd.gu;
                    ba[db.hp] = di;
                }

            }

            uint df = d.aa[fa] + 1;

            d.aa[fa] = df;
            hd.hs = block.timestamp;
            hd.hn = block.number;
            d.q[fa][df] = hd;
        }
    }


    function bs(
        uint fa,
        uint gj,
        uint cs,
        IVotingEscrow.LockedBalance memory at,
        DepositType br
    ) internal {
        IVotingEscrow.LockedBalance memory fk = at;
        uint bi = ga;

        ga = bi + gj;
        IVotingEscrow.LockedBalance memory dc;
        (dc.gf, dc.hp, dc.cq) = (fk.gf, fk.hp, fk.cq);

        fk.gf += int128(int256(gj));

        if (cs != 0) {
            fk.hp = cs;
        }
        ge[fa] = fk;


        ck(fa, dc, fk);

        address from = msg.sender;
        if (gj != 0) {
            assert(IERC20(gn).by(from, address(this), gj));
        }

        emit Deposit(from, fa, gj, fk.hp, br, block.timestamp);
        emit Supply(bi, bi + gj);
    }


    function de() external {
        ck(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }


    function ci(uint fa, uint gj) external ca {
        IVotingEscrow.LockedBalance memory fk = ge[fa];

        require(gj > 0, "ZV");
        require(fk.gf > 0, 'ZL');
        require(fk.hp > block.timestamp || fk.cq, 'EXP');

        if (fk.cq) f += gj;

        bs(fa, gj, 0, fk, DepositType.DEPOSIT_FOR_TYPE);

        if(gw[fa]) {
            IVoter(gv).hi(fa);
        }
    }


    function bo(uint gj, uint ax, address hk) internal returns (uint) {
        uint cs = (block.timestamp + ax) / WEEK * WEEK;

        require(gj > 0, "ZV");
        require(cs > block.timestamp && (cs <= block.timestamp + MAXTIME), 'IUT');

        ++fo;
        uint fa = fo;
        hb(hk, fa);

        IVotingEscrow.LockedBalance memory fk = ge[fa];

        bs(fa, gj, cs, fk, DepositType.CREATE_LOCK_TYPE);
        return fa;
    }


    function cm(uint gj, uint ax) external ca returns (uint) {
        return bo(gj, ax, msg.sender);
    }


    function ak(uint gj, uint ax, address hk) external ca returns (uint) {
        return bo(gj, ax, hk);
    }


    function am(uint fa, uint gj) external ca {
        assert(r(msg.sender, fa));

        IVotingEscrow.LockedBalance memory fk = ge[fa];

        assert(gj > 0);
        require(fk.gf > 0, 'ZL');
        require(fk.hp > block.timestamp || fk.cq, 'EXP');

        if (fk.cq) f += gj;
        bs(fa, gj, 0, fk, DepositType.INCREASE_LOCK_AMOUNT);


        if(gw[fa]) {
            IVoter(gv).hi(fa);
        }
        emit MetadataUpdate(fa);
    }


    function g(uint fa, uint ax) external ca {
        assert(r(msg.sender, fa));

        IVotingEscrow.LockedBalance memory fk = ge[fa];
        require(!fk.cq, "!NORM");
        uint cs = (block.timestamp + ax) / WEEK * WEEK;

        require(fk.hp > block.timestamp && fk.gf > 0, 'EXP||ZV');
        require(cs > fk.hp && (cs <= block.timestamp + MAXTIME), 'IUT');

        bs(fa, 0, cs, fk, DepositType.INCREASE_UNLOCK_TIME);


        if(gw[fa]) {
            IVoter(gv).hi(fa);
        }
        emit MetadataUpdate(fa);
    }


    function eu(uint fa) external ca {
        assert(r(msg.sender, fa));
        require(cf[fa] == 0 && !gw[fa], "ATT");

        IVotingEscrow.LockedBalance memory fk = ge[fa];
        require(!fk.cq, "!NORM");
        require(block.timestamp >= fk.hp, "!EXP");
        uint value = uint(int256(fk.gf));

        ge[fa] = IVotingEscrow.LockedBalance(0, 0, false);
        uint bi = ga;
        ga = bi - value;


        ck(fa, fk, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(gn).transfer(msg.sender, value));


        ha(fa);

        emit Withdraw(msg.sender, fa, value, block.timestamp);
        emit Supply(bi, bi - value);
    }

    function bk(uint fa) external {
        address sender = msg.sender;
        require(r(sender, fa), "NAO");

        IVotingEscrow.LockedBalance memory dl = ge[fa];
        require(!dl.cq, "!NORM");
        require(dl.hp > block.timestamp, "EXP");
        require(dl.gf > 0, "ZV");

        uint fq = uint(int256(dl.gf));
        f += fq;
        dl.hp = 0;
        dl.cq = true;
        ck(fa, ge[fa], dl);
        ge[fa] = dl;
        if(gw[fa]) {
            IVoter(gv).hi(fa);
        }
        emit LockPermanent(sender, fa, fq, block.timestamp);
        emit MetadataUpdate(fa);
    }

    function ag(uint fa) external {
        address sender = msg.sender;
        require(r(msg.sender, fa), "NAO");

        require(cf[fa] == 0 && !gw[fa], "ATT");
        IVotingEscrow.LockedBalance memory dl = ge[fa];
        require(dl.cq, "!NORM");
        uint fq = uint(int256(dl.gf));
        f -= fq;
        dl.hp = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        dl.cq = false;

        ck(fa, ge[fa], dl);
        ge[fa] = dl;

        emit UnlockPermanent(sender, fa, fq, block.timestamp);
        emit MetadataUpdate(fa);
    }


    function bu(uint fa) external view returns (uint) {
        if (z[fa] == block.number) return 0;
        return VotingBalanceLogic.bu(fa, block.timestamp, d);
    }

    function au(uint fa, uint hr) external view returns (uint) {
        return VotingBalanceLogic.bu(fa, hr, d);
    }

    function aw(uint fa, uint fz) external view returns (uint) {
        return VotingBalanceLogic.aw(fa, fz, d, gz);
    }


    function bc(uint fz) external view returns (uint) {
        return VotingBalanceLogic.bc(fz, gz, d, ba);
    }

    function cr() external view returns (uint) {
        return ao(block.timestamp);
    }


    function ao(uint t) public view returns (uint) {
        return VotingBalanceLogic.ao(t, gz, ba,  d);
    }


    mapping(uint => uint) public cf;
    mapping(uint => bool) public gw;

    function ep(address gh) external {
        require(msg.sender == hf);
        gv = gh;
    }

    function fu(uint fa) external {
        require(msg.sender == gv);
        gw[fa] = true;
    }

    function fl(uint fa) external {
        require(msg.sender == gv, "NA");
        gw[fa] = false;
    }

    function fv(uint fa) external {
        require(msg.sender == gv, "NA");
        cf[fa] = cf[fa] + 1;
    }

    function fs(uint fa) external {
        require(msg.sender == gv, "NA");
        cf[fa] = cf[fa] - 1;
    }

    function go(uint hc, uint hk) external ca bh(hc) {
        require(cf[hc] == 0 && !gw[hc], "ATT");
        require(hc != hk, "SAME");
        require(r(msg.sender, hc) &&
        r(msg.sender, hk), "NAO");

        IVotingEscrow.LockedBalance memory er = ge[hc];
        IVotingEscrow.LockedBalance memory em = ge[hk];
        require(em.hp > block.timestamp ||  em.cq,"EXP||PERM");
        require(er.cq ? em.cq : true, "!MERGE");

        uint gg = uint(int256(er.gf));
        uint hp = er.hp >= em.hp ? er.hp : em.hp;

        ge[hc] = IVotingEscrow.LockedBalance(0, 0, false);
        ck(hc, er, IVotingEscrow.LockedBalance(0, 0, false));
        ha(hc);

        IVotingEscrow.LockedBalance memory cl;
        cl.cq = em.cq;

        if (cl.cq){
            cl.gf = em.gf + er.gf;
            if (!er.cq) {
                f += gg;
            }
        }else{
            cl.gf = em.gf + er.gf;
            cl.hp = hp;
        }


        ck(hk, em, cl);
        ge[hk] = cl;

        if(gw[hk]) {
            IVoter(gv).hi(hk);
        }
        emit Merge(
            msg.sender,
            hc,
            hk,
            uint(int256(er.gf)),
            uint(int256(em.gf)),
            uint(int256(cl.gf)),
            cl.hp,
            block.timestamp
        );
        emit MetadataUpdate(hk);
    }


    function dh(
        uint hc,
        uint[] memory fi
    ) external ca bx(hc) bh(hc) returns (uint256[] memory cn) {
        require(fi.length >= 2 && fi.length <= 10, "MIN2MAX10");

        address gm = dw[hc];

        IVotingEscrow.LockedBalance memory ap = ge[hc];
        require(ap.hp > block.timestamp || ap.cq, "EXP");
        require(ap.gf > 0, "ZV");


        uint co = 0;
        for(uint i = 0; i < fi.length; i++) {
            require(fi[i] > 0, "ZW");
            co += fi[i];
        }


        ge[hc] = IVotingEscrow.LockedBalance(0, 0, false);
        ck(hc, ap, IVotingEscrow.LockedBalance(0, 0, false));
        ha(hc);


        cn = new uint256[](fi.length);
        uint[] memory bj = new uint[](fi.length);

        for(uint i = 0; i < fi.length; i++) {
            IVotingEscrow.LockedBalance memory ds = IVotingEscrow.LockedBalance({
                gf: int128(int256(uint256(int256(ap.gf)) * fi[i] / co)),
                hp: ap.hp,
                cq: ap.cq
            });

            cn[i] = ai(gm, ds);
            bj[i] = uint256(int256(ds.gf));
        }

        emit MultiSplit(
            hc,
            cn,
            msg.sender,
            bj,
            ap.hp,
            block.timestamp
        );
    }

    function ai(address hk, IVotingEscrow.LockedBalance memory dl) private returns (uint256 fa) {
        fa = ++fo;
        ge[fa] = dl;
        ck(fa, IVotingEscrow.LockedBalance(0, 0, false), dl);
        hb(hk, fa);
    }

    function cu(address ev, bool gs) external {
        require(msg.sender == hf);
        fd[ev] = gs;
    }


    bytes32 public constant DOMAIN_TYPEHASH = dr("EIP712Domain(string name,uint256 chainId,address verifyingContract)");


    bytes32 public constant DELEGATION_TYPEHASH = dr("Delegation(address delegatee,uint256 nonce,uint256 expiry)");


    mapping(address => address) private dk;


    mapping(address => uint) public gk;


    function dy(address dt) public view returns (address) {
        address fh = dk[dt];
        return fh == address(0) ? dt : fh;
    }


    function ez(address fm) external view returns (uint) {
        uint32 bw = gi.aq[fm];
        if (bw == 0) {
            return 0;
        }
        uint[] storage ee = gi.cj[fm][bw - 1].fc;
        uint gq = 0;
        for (uint i = 0; i < ee.length; i++) {
            uint ho = ee[i];
            gq = gq + VotingBalanceLogic.bu(ho, block.timestamp, d);
        }
        return gq;
    }

    function bz(address fm, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 cy = VotingDelegationLib.s(gi, fm, timestamp);

        uint[] storage ee = gi.cj[fm][cy].fc;
        uint gq = 0;
        for (uint i = 0; i < ee.length; i++) {
            uint ho = ee[i];

            gq = gq + VotingBalanceLogic.bu(ho, timestamp,  d);
        }

        return gq;
    }

    function o(uint256 timestamp) external view returns (uint) {
        return ao(timestamp);
    }


    function dp(address dt, address eh) internal {

        address an = dy(dt);

        dk[dt] = eh;

        emit DelegateChanged(dt, an, eh);
        VotingDelegationLib.TokenHelpers memory bv = VotingDelegationLib.TokenHelpers({
            dv: fe,
            e: e,
            m:m
        });
        VotingDelegationLib.y(gi, dt, an, eh, bv);
    }


    function es(address eh) public {
        if (eh == address(0)) eh = msg.sender;
        return dp(msg.sender, eh);
    }

    function bl(
        address eh,
        uint gr,
        uint gl,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(eh != msg.sender, "NA");
        require(eh != address(0), "ZA");

        bytes32 ah = dr(
            abi.fr(
                DOMAIN_TYPEHASH,
                dr(bytes(he)),
                dr(bytes(ff)),
                block.chainid,
                address(this)
            )
        );
        bytes32 dg = dr(
            abi.fr(DELEGATION_TYPEHASH, eh, gr, gl)
        );
        bytes32 gc = dr(
            abi.cb("\x19\x01", ah, dg)
        );
        address dx = eg(gc, v, r, s);
        require(
            dx != address(0),
            "ZA"
        );
        require(
            gr == gk[dx]++,
            "!NONCE"
        );
        require(
            block.timestamp <= gl,
            "EXP"
        );
        return dp(dx, eh);
    }

}