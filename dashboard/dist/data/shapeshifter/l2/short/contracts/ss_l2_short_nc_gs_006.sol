pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
 import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import '../interfaces/IGaugeFactoryCL.sol';
import '../interfaces/IGaugeManager.sol';
import './interface/ICLPool.sol';
import './interface/ICLFactory.sol';
import './interface/INonfungiblePositionManager.sol';
import '../interfaces/IBribe.sol';
import '../interfaces/IRHYBR.sol';
import {HybraTimeLibrary} from "../libraries/HybraTimeLibrary.sol";
import {FullMath} from "./libraries/FullMath.sol";
import {FixedPoint128} from "./libraries/FixedPoint128.sol";
import '../interfaces/IRHYBR.sol';

contract GaugeCL is ReentrancyGuard, Ownable, IERC721Receiver {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeCast for uint128;
    IERC20 public immutable at;
    address public immutable df;
    address public VE;
    address public DISTRIBUTION;
    address public af;
    address public ad;

    uint256 public DURATION;
    uint256 internal ah;
    uint256 public be;
    ICLPool public db;
    address public au;
    INonfungiblePositionManager public b;

    bool public bq;
    bool public immutable bv;
    address immutable cp;

    mapping(uint256 => uint256) public  m;
    mapping(address => EnumerableSet.UintSet) internal cm;
    mapping(uint256 => uint256) public  k;

    mapping(uint256 => uint256) public  cn;

    mapping(uint256 => uint256) public  ab;

    event RewardAdded(uint256 cs);
    event Deposit(address indexed dj, uint256 cr);
    event Withdraw(address indexed dj, uint256 cr);
    event Harvest(address indexed dj, uint256 cs);
    event ClaimFees(address indexed from, uint256 cc, uint256 cd);
    event EmergencyActivated(address indexed dg, uint256 timestamp);
    event EmergencyDeactivated(address indexed dg, uint256 timestamp);

    constructor(address am, address cv, address dl, address dd, address ak, address aa,
        address x, bool az, address dk,  address bz) {
        cp = bz;
        at = IERC20(am);
        df = cv;
        VE = dl;
        au = dd;
        db = ICLPool(dd);
        DISTRIBUTION = ak;
        DURATION = HybraTimeLibrary.WEEK;

        af = aa;
        ad = x;
        bv = az;
        b = INonfungiblePositionManager(dk);
        bq = false;
    }

    modifier r() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier ae() {
        require(bq == false, "emergency");
        _;
    }

    function ag(uint256 co, int24 bu, int24 bm) internal {
        if (ab[co] == block.timestamp) return;
        db.c();
        ab[co] = block.timestamp;
        cn[co] += cl(co);
        k[co] = db.h(bu, bm, 0);
    }

    function g() external br {
        require(bq == false, "emergency");
        bq = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function o() external br {

        require(bq == true,"emergency");

        bq = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function bw(uint256 co) external view returns (uint256) {
        (,,,,,,,uint128 bs,,,,) = b.bi(co);
        return bs;
    }

    function y(address cx, address dc, int24 ay) internal view returns (address) {
        return ICLFactory(b.cp()).cj(cx, dc, ay);
    }

    function da(uint256 co) external view returns (uint256 cs) {
        require(cm[msg.sender].ce(co), "NA");

        uint256 cs = cl(co);
        return (cs);
    }

       function cl(uint256 co) internal view returns (uint256) {
        uint256 as = db.as();

        uint256 bx = block.timestamp - as;

        uint256 f = db.f();
        uint256 aj = db.aj();

        if (bx != 0 && aj > 0 && db.w() > 0) {
            uint256 cs = be * bx;
            if (cs > aj) cs = aj;

            f += FullMath.cu(cs, FixedPoint128.Q128, db.w());
        }

        (,,,,, int24 bu, int24 bm, uint128 bs,,,,) = b.bi(co);

        uint256 a = k[co];
        uint256 d = db.h(bu, bm, f);

        uint256 bk =
            FullMath.cu(d - a, bs, FixedPoint128.Q128);
        return bk;
    }

    function ch(uint256 co) external an ae {

         (,,address cx, address dc, int24 ay, int24 bu, int24 bm, uint128 bs,,,,) =
            b.bi(co);

        require(bs > 0, "Gauge: zero liquidity");

        address ao = y(cx, dc, ay);

        require(ao == au, "Pool mismatch: Position not for this gauge pool");

        b.cg(INonfungiblePositionManager.CollectParams({
                co: co,
                bp: msg.sender,
                bh: type(uint128).dn,
                bf: type(uint128).dn
            }));

        b.u(msg.sender, address(this), co);

        db.dh(int128(bs), bu, bm, true);

        uint256 ap = db.h(bu, bm, 0);
        k[co] = ap;
        ab[co] = block.timestamp;

        cm[msg.sender].dm(co);

        emit Deposit(msg.sender, co);
    }

    function ca(uint256 co, uint8 bd) external an ae {
           require(cm[msg.sender].ce(co), "NA");


        b.cg(
            INonfungiblePositionManager.CollectParams({
                co: co,
                bp: msg.sender,
                bh: type(uint128).dn,
                bf: type(uint128).dn
            })
        );

        (,,,,, int24 bu, int24 bm, uint128 t,,,,) = b.bi(co);
        bc(bu, bm, co, msg.sender, bd);


        if (t != 0) {
            db.dh(-int128(t), bu, bm, true);
        }

        cm[msg.sender].cz(co);
        b.u(address(this), msg.sender, co);

        emit Withdraw(msg.sender, co);
    }

    function bl(uint256 co, address cq,uint8 bd ) public an r {

        require(cm[cq].ce(co), "NA");

        (,,,,, int24 bu, int24 bm,,,,,) = b.bi(co);
        bc(bu, bm, co, cq, bd);
    }

    function bc(int24 bu, int24 bm, uint256 co,address cq, uint8 bd) internal {
        ag(co, bu, bm);
        uint256 aq = cn[co];
        if(aq > 0){
            delete cn[co];
            at.ax(df, aq);
            IRHYBR(df).e(aq);
            IRHYBR(df).bn(aq, bd, cq);
        }
        emit Harvest(msg.sender, aq);
    }

    function j(address de, uint256 aq) external an
        ae r returns (uint256 aw) {
        require(de == address(at), "Invalid reward token");


        db.c();


        uint256 l = HybraTimeLibrary.bj(block.timestamp) - block.timestamp;
        uint256 p = block.timestamp + l;


        uint256 n = aq + db.cb();


        if (block.timestamp >= ah) {

            be = aq / l;
            db.bg({
                be: be,
                aj: n,
                ar: p
            });
        } else {

            uint256 ac = l * be;
            be = (aq + ac) / l;
            db.bg({
                be: be,
                aj: n + ac,
                ar: p
            });
        }


        m[HybraTimeLibrary.ba(block.timestamp)] = be;


        at.u(DISTRIBUTION, address(this), aq);


        uint256 z = at.bw(address(this));
        require(be <= z / l, "Insufficient balance for reward rate");


        ah = p;
        aw = be;

        emit RewardAdded(aq);
    }

    function ai() external view returns (uint256 cx, uint256 dc){

        (cx, dc) = db.bt();

    }

    function bo() external an returns (uint256 cc, uint256 cd) {
        return bb();
    }

    function bb() internal returns (uint256 cc, uint256 cd) {
        if (!bv) {
            return (0, 0);
        }

        db.av();

        address ci = db.cx();
        address cf = db.dc();

        cc = IERC20(ci).bw(address(this));
        cd = IERC20(cf).bw(address(this));

        if (cc > 0 || cd > 0) {

            uint256 cy = cc;
            uint256 ct = cd;

            if (cy  > 0) {
                IERC20(ci).ax(af, 0);
                IERC20(ci).ax(af, cy);
                IBribe(af).j(ci, cy);
            }
            if (ct  > 0) {
                IERC20(cf).ax(af, 0);
                IERC20(cf).ax(af, ct);
                IBribe(af).j(cf, ct);
            }
            emit ClaimFees(msg.sender, cc, cd);
        }
    }


    function q() external view returns (uint256) {
        return be * DURATION;
    }


    function s(address di) external br {
        require(di >= address(0), "zero");
        af = di;
    }

    function al(address de,address do,uint256 value) internal {
        require(de.code.length > 0);
        (bool ck, bytes memory data) = de.call(abi.i(IERC20.transfer.selector, do, value));
        require(ck && (data.length == 0 || abi.cw(data, (bool))));
    }


    function v(
        address by,
        address from,
        uint256 co,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.v.selector;
    }

}