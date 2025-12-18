pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IVotingEscrow.sol";
import "./interfaces/IVoter.sol";
import "./interfaces/IBribe.sol";
import "./interfaces/IRewardsDistributor.sol";
import "./interfaces/IGaugeManager.sol";
import "./interfaces/ISwapper.sol";
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract GrowthHYBR is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public k = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public d = 1200;
    uint256 public c = 300;


    uint256 public bg = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public dq;
    uint256 public dg;
    uint256 public bm;

    struct UserLock {
        uint256 dv;
        uint256 cd;
    }

    mapping(address => UserLock[]) public cq;
    mapping(address => uint256) public ak;


    address public immutable HYBR;
    address public immutable aw;
    address public ed;
    address public l;
    address public au;
    uint256 public cr;


    address public db;
    uint256 public an;


    uint256 public ad;
    uint256 public s;


    ISwapper public de;


    error NOT_AUTHORIZED();


    event Deposit(address indexed em, uint256 cb, uint256 af);
    event Withdraw(address indexed em, uint256 dt, uint256 cb, uint256 er);
    event Compound(uint256 dj, uint256 ag);
    event PenaltyRewardReceived(uint256 dv);
    event TransferLockPeriodUpdated(uint256 ci, uint256 ct);
    event SwapperUpdated(address indexed bv, address indexed bz);
    event VoterSet(address ed);
    event EmergencyUnlock(address indexed em);
    event AutoVotingEnabled(bool do);
    event OperatorUpdated(address indexed bs, address indexed br);
    event DefaultVotingStrategyUpdated(address[] dy, uint256[] dl);
    event AutoVoteExecuted(uint256 ei, address[] dy, uint256[] dl);

    constructor(
        address el,
        address am
    ) ERC20("Growth HYBR", "gHYBR") {
        require(el != address(0), "Invalid HYBR");
        require(am != address(0), "Invalid VE");

        HYBR = el;
        aw = am;
        ad = block.timestamp;
        s = block.timestamp;
        db = msg.sender;
    }

    function e(address j) external cn {
        require(j != address(0), "Invalid rewards distributor");
        l = j;
    }

    function u(address ar) external cn {
        require(ar != address(0), "Invalid gauge manager");
        au = ar;
    }


    modifier at() {
        if (msg.sender != db) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function dk(uint256 dv, address cj) external ay {
        require(dv > 0, "Zero amount");
        cj = cj == address(0) ? msg.sender : cj;


        IERC20(HYBR).ba(msg.sender, address(this), dv);


        if (cr == 0) {
            n(dv);
        } else {

            IERC20(HYBR).df(aw, dv);
            IVotingEscrow(aw).bf(cr, dv);


            q();
        }


        uint256 dt = ab(dv);


        ek(cj, dt);


        p(cj, dt);

        emit Deposit(msg.sender, dv, dt);
    }


    function cy(uint256 dt) external ay returns (uint256 bi) {
        require(dt > 0, "Zero shares");
        require(cp(msg.sender) >= dt, "Insufficient balance");
        require(cr != 0, "No veNFT initialized");
        require(IVotingEscrow(aw).ef(cr) == false, "Cannot withdraw yet");

        uint256 ce = HybraTimeLibrary.ce(block.timestamp);
        uint256 cm = HybraTimeLibrary.cm(block.timestamp);

        require(block.timestamp >= ce + d && block.timestamp < cm - c, "Cannot withdraw yet");


        uint256 cb = y(dt);
        require(cb > 0, "No assets to withdraw");


        uint256 co = 0;
        if (bg > 0) {
            co = (cb * bg) / BASIS;
        }


        uint256 cg = cb - co;
        require(cg > 0, "Amount too small after fee");


        uint256 ch = bp();
        require(cb <= ch, "Insufficient veNFT balance");

        uint256 aa = ch - cg - co;
        require(aa >= 0, "Cannot withdraw entire veNFT");


        ej(msg.sender, dt);


        uint256[] memory dh = new uint256[](3);
        dh[0] = aa;
        dh[1] = cg;
        dh[2] = co;

        uint256[] memory bj = IVotingEscrow(aw).bx(cr, dh);


        cr = bj[0];
        bi = bj[1];
        uint256 cf = bj[2];

        IVotingEscrow(aw).t(address(this), msg.sender, bi);
        IVotingEscrow(aw).t(address(this), Team, cf);
        emit Withdraw(msg.sender, dt, cg, co);
    }


    function n(uint256 aq) internal {

        IERC20(HYBR).df(aw, type(uint256).eq);
        uint256 da = HybraTimeLibrary.MAX_LOCK_DURATION;


        cr = IVotingEscrow(aw).v(aq, da, address(this));

    }


    function ab(uint256 dv) public view returns (uint256) {
        uint256 ax = bo();
        uint256 as = bp();
        if (ax == 0 || as == 0) {
            return dv;
        }
        return (dv * ax) / as;
    }


    function y(uint256 dt) public view returns (uint256) {
        uint256 ax = bo();
        if (ax == 0) {
            return dt;
        }
        return (dt * bp()) / ax;
    }


    function bp() public view returns (uint256) {
        if (cr == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory du = IVotingEscrow(aw).du(cr);
        return uint256(int256(du.dv));
    }


    function p(address em, uint256 dv) internal {
        uint256 cd = block.timestamp + k;
        cq[em].push(UserLock({
            dv: dv,
            cd: cd
        }));
        ak[em] += dv;
    }


    function r(address em) external view returns (uint256 ck) {
        uint256 av = cp(em);
        uint256 ao = 0;

        UserLock[] storage es = cq[em];
        for (uint256 i = 0; i < es.length; i++) {
            if (es[i].cd > block.timestamp) {
                ao += es[i].dv;
            }
        }

        return av > ao ? av - ao : 0;
    }

    function ap(address em) internal returns (uint256 ec) {
        UserLock[] storage es = cq[em];
        uint256 ep = es.length;
        if (ep == 0) return 0;

        uint256 eb = 0;
        unchecked {
            for (uint256 i = 0; i < ep; i++) {
                UserLock memory L = es[i];
                if (L.cd <= block.timestamp) {
                    ec += L.dv;
                } else {
                    if (eb != i) es[eb] = L;
                    eb++;
                }
            }
            if (ec > 0) {
                ak[em] -= ec;
            }
            while (es.length > eb) {
                es.pop();
            }
        }
    }


    function i(
        address from,
        address eu,
        uint256 dv
    ) internal override {
        super.i(from, eu, dv);

        if (from != address(0) && eu != address(0)) {
            uint256 av = cp(from);


            uint256 o = av > ak[from] ? av - ak[from] : 0;


            if (o >= dv) {
                return;
            }


            ap(from);
            uint256 ac = av > ak[from] ? av - ak[from] : 0;


            require(ac >= dv, "Tokens locked");
        }
    }


    function bd() external at {
        require(ed != address(0), "Voter not set");
        require(l != address(0), "Distributor not set");


        uint256  bc = IRewardsDistributor(l).ea(cr);
        dq += bc;

        address[] memory ca = IVoter(ed).cz(cr);

        for (uint256 i = 0; i < ca.length; i++) {
            if (ca[i] != address(0)) {
                address ee = IGaugeManager(au).dp(ca[i]);

                if (ee != address(0)) {

                    address[] memory dr = new address[](1);
                    address[][] memory ds = new address[][](1);


                    address al = IGaugeManager(au).z(ee);
                    if (al != address(0)) {
                        uint256 bw = IBribe(al).m();
                        if (bw > 0) {
                            address[] memory bt = new address[](bw);
                            for (uint256 j = 0; j < bw; j++) {
                                bt[j] = IBribe(al).bt(j);
                            }
                            dr[0] = al;
                            ds[0] = bt;

                            IGaugeManager(au).bq(dr, ds, cr);
                        }
                    }


                    address aj = IGaugeManager(au).w(ee);
                    if (aj != address(0)) {
                        uint256 bw = IBribe(aj).m();
                        if (bw > 0) {
                            address[] memory bt = new address[](bw);
                            for (uint256 j = 0; j < bw; j++) {
                                bt[j] = IBribe(aj).bt(j);
                            }
                            dr[0] = aj;
                            ds[0] = bt;

                            IGaugeManager(au).bq(dr, ds, cr);
                        }
                    }
                }
            }
        }
    }


    function bh(ISwapper.SwapParams calldata dn) external ay at {
        require(address(de) != address(0), "Swapper not set");


        uint256 bb = IERC20(dn.dm).cp(address(this));
        require(bb >= dn.cw, "Insufficient token balance");


        IERC20(dn.dm).bl(address(de), dn.cw);


        uint256 be = de.by(dn);


        IERC20(dn.dm).bl(address(de), 0);


        bm += be;
    }


    function dc() external at {


        uint256 bu = IERC20(HYBR).cp(address(this));

        if (bu > 0) {

            IERC20(HYBR).bl(aw, bu);
            IVotingEscrow(aw).bf(cr, bu);


            q();

            s = block.timestamp;

            emit Compound(bu, bp());
        }
    }


    function en(address[] calldata cs, uint256[] calldata cu) external {
        require(msg.sender == dx() || msg.sender == db, "Not authorized");
        require(ed != address(0), "Voter not set");

        IVoter(ed).en(cr, cs, cu);
        an = HybraTimeLibrary.ce(block.timestamp);

    }


    function dz() external {
        require(msg.sender == dx() || msg.sender == db, "Not authorized");
        require(ed != address(0), "Voter not set");

        IVoter(ed).dz(cr);
    }


    function g(uint256 dv) external {


        if (dv > 0) {
            IERC20(HYBR).df(aw, dv);

            if(cr == 0){
                n(dv);
            } else{
                IVotingEscrow(aw).bf(cr, dv);


                q();
            }
        }
        dg += dv;
        emit PenaltyRewardReceived(dv);
    }


    function cv(address dw) external cn {
        require(dw != address(0), "Invalid voter");
        ed = dw;
        emit VoterSet(dw);
    }


    function f(uint256 dd) external cn {
        require(dd >= MIN_LOCK_PERIOD && dd <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 ci = k;
        k = dd;
        emit TransferLockPeriodUpdated(ci, dd);
    }


    function ae(uint256 eo) external cn {
        require(eo >= MIN_WITHDRAW_FEE && eo <= MAX_WITHDRAW_FEE, "Invalid fee");
        bg = eo;
    }

    function b(uint256 eh) external cn {
        d = eh;
    }

    function a(uint256 eh) external cn {
        c = eh;
    }


    function cc(address cx) external cn {
        require(cx != address(0), "Invalid swapper");
        address bv = address(de);
        de = ISwapper(cx);
        emit SwapperUpdated(bv, cx);
    }


    function di(address eg) external cn {
        require(eg != address(0), "Invalid team");
        Team = eg;
    }


    function x(address em) external at {
        delete cq[em];
        ak[em] = 0;
        emit EmergencyUnlock(em);
    }


    function az(address em) external view returns (UserLock[] memory) {
        return cq[em];
    }


    function bk(address cl) external cn {
        require(cl != address(0), "Invalid operator");
        address bs = db;
        db = cl;
        emit OperatorUpdated(bs, cl);
    }


    function ah() external view returns (uint256) {
        if (cr == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory du = IVotingEscrow(aw).du(cr);
        return uint256(du.et);
    }


    function q() internal {
        if (cr == 0) return;

        IVotingEscrow.LockedBalance memory du = IVotingEscrow(aw).du(cr);
        if (du.bn || du.et <= block.timestamp) return;

        uint256 ai = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (ai > du.et + 2 hours) {
            try IVotingEscrow(aw).h(cr, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }

}