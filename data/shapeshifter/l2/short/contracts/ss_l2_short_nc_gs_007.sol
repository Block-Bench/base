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
    IERC20 public immutable ax;
    address public immutable df;
    address public VE;
    address public DISTRIBUTION;
    address public ab;
    address public ac;

    uint256 public DURATION;
    uint256 internal aj;
    uint256 public bb;
    ICLPool public cw;
    address public ay;
    INonfungiblePositionManager public b;

    bool public bu;
    bool public immutable bt;
    address immutable cj;

    mapping(uint256 => uint256) public  q;
    mapping(address => EnumerableSet.UintSet) internal cl;
    mapping(uint256 => uint256) public  l;

    mapping(uint256 => uint256) public  ck;

    mapping(uint256 => uint256) public  ae;

    event RewardAdded(uint256 cy);
    event Deposit(address indexed dj, uint256 cx);
    event Withdraw(address indexed dj, uint256 cx);
    event Harvest(address indexed dj, uint256 cy);
    event ClaimFees(address indexed from, uint256 cc, uint256 ce);
    event EmergencyActivated(address indexed de, uint256 timestamp);
    event EmergencyDeactivated(address indexed de, uint256 timestamp);

    constructor(address ar, address cr, address dn, address dg, address ak, address x,
        address y, bool bc, address dk,  address by) {
        cj = by;
        ax = IERC20(ar);
        df = cr;
        VE = dn;
        ay = dg;
        cw = ICLPool(dg);
        DISTRIBUTION = ak;
        DURATION = HybraTimeLibrary.WEEK;

        ab = x;
        ac = y;
        bt = bc;
        b = INonfungiblePositionManager(dk);
        bu = false;
    }

    modifier s() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier ag() {
        require(bu == false, "emergency");
        _;
    }

    function ad(uint256 cq, int24 bq, int24 bs) internal {
        if (ae[cq] == block.timestamp) return;
        cw.c();
        ae[cq] = block.timestamp;
        ck[cq] += cp(cq);
        l[cq] = cw.g(bq, bs, 0);
    }

    function h() external bp {
        require(bu == false, "emergency");
        bu = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function m() external bp {

        require(bu == true,"emergency");

        bu = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function br(uint256 cq) external view returns (uint256) {
        (,,,,,,,uint128 bw,,,,) = b.bm(cq);
        return bw;
    }

    function aa(address da, address cs, int24 av) internal view returns (address) {
        return ICLFactory(b.cj()).cm(da, cs, av);
    }

    function dc(uint256 cq) external view returns (uint256 cy) {
        require(cl[msg.sender].bz(cq), "NA");

        uint256 cy = cp(cq);
        return (cy);
    }

       function cp(uint256 cq) internal view returns (uint256) {
        uint256 at = cw.at();

        uint256 bl = block.timestamp - at;

        uint256 f = cw.f();
        uint256 al = cw.al();

        if (bl != 0 && al > 0 && cw.z() > 0) {
            uint256 cy = bb * bl;
            if (cy > al) cy = al;

            f += FullMath.db(cy, FixedPoint128.Q128, cw.z());
        }

        (,,,,, int24 bq, int24 bs, uint128 bw,,,,) = b.bm(cq);

        uint256 a = l[cq];
        uint256 d = cw.g(bq, bs, f);

        uint256 bv =
            FullMath.db(d - a, bw, FixedPoint128.Q128);
        return bv;
    }

    function cn(uint256 cq) external ap ag {

         (,,address da, address cs, int24 av, int24 bq, int24 bs, uint128 bw,,,,) =
            b.bm(cq);

        require(bw > 0, "Gauge: zero liquidity");

        address am = aa(da, cs, av);

        require(am == ay, "Pool mismatch: Position not for this gauge pool");

        b.cf(INonfungiblePositionManager.CollectParams({
                cq: cq,
                bi: msg.sender,
                bd: type(uint128).dl,
                az: type(uint128).dl
            }));

        b.u(msg.sender, address(this), cq);

        cw.dh(int128(bw), bq, bs, true);

        uint256 an = cw.g(bq, bs, 0);
        l[cq] = an;
        ae[cq] = block.timestamp;

        cl[msg.sender].dm(cq);

        emit Deposit(msg.sender, cq);
    }

    function cb(uint256 cq, uint8 ba) external ap ag {
           require(cl[msg.sender].bz(cq), "NA");


        b.cf(
            INonfungiblePositionManager.CollectParams({
                cq: cq,
                bi: msg.sender,
                bd: type(uint128).dl,
                az: type(uint128).dl
            })
        );

        (,,,,, int24 bq, int24 bs, uint128 t,,,,) = b.bm(cq);
        bf(bq, bs, cq, msg.sender, ba);


        if (t != 0) {
            cw.dh(-int128(t), bq, bs, true);
        }

        cl[msg.sender].ct(cq);
        b.u(address(this), msg.sender, cq);

        emit Withdraw(msg.sender, cq);
    }

    function bn(uint256 cq, address co,uint8 ba ) public ap s {

        require(cl[co].bz(cq), "NA");

        (,,,,, int24 bq, int24 bs,,,,,) = b.bm(cq);
        bf(bq, bs, cq, co, ba);
    }

    function bf(int24 bq, int24 bs, uint256 cq,address co, uint8 ba) internal {
        ad(cq, bq, bs);
        uint256 ao = ck[cq];
        if(ao > 0){
            delete ck[cq];
            ax.aw(df, ao);
            IRHYBR(df).e(ao);
            IRHYBR(df).bj(ao, ba, co);
        }
        emit Harvest(msg.sender, ao);
    }

    function k(address dd, uint256 ao) external ap
        ag s returns (uint256 au) {
        require(dd == address(ax), "Invalid reward token");


        cw.c();


        uint256 j = HybraTimeLibrary.bk(block.timestamp) - block.timestamp;
        uint256 o = block.timestamp + j;


        uint256 p = ao + cw.ca();


        if (block.timestamp >= aj) {

            bb = ao / j;
            cw.be({
                bb: bb,
                al: p,
                aq: o
            });
        } else {

            uint256 af = j * bb;
            bb = (ao + af) / j;
            cw.be({
                bb: bb,
                al: p + af,
                aq: o
            });
        }


        q[HybraTimeLibrary.bh(block.timestamp)] = bb;


        ax.u(DISTRIBUTION, address(this), ao);


        uint256 w = ax.br(address(this));
        require(bb <= w / j, "Insufficient balance for reward rate");


        aj = o;
        au = bb;

        emit RewardAdded(ao);
    }

    function ah() external view returns (uint256 da, uint256 cs){

        (da, cs) = cw.bo();

    }

    function bx() external ap returns (uint256 cc, uint256 ce) {
        return bg();
    }

    function bg() internal returns (uint256 cc, uint256 ce) {
        if (!bt) {
            return (0, 0);
        }

        cw.as();

        address ch = cw.da();
        address cg = cw.cs();

        cc = IERC20(ch).br(address(this));
        ce = IERC20(cg).br(address(this));

        if (cc > 0 || ce > 0) {

            uint256 cz = cc;
            uint256 cv = ce;

            if (cz  > 0) {
                IERC20(ch).aw(ab, 0);
                IERC20(ch).aw(ab, cz);
                IBribe(ab).k(ch, cz);
            }
            if (cv  > 0) {
                IERC20(cg).aw(ab, 0);
                IERC20(cg).aw(ab, cv);
                IBribe(ab).k(cg, cv);
            }
            emit ClaimFees(msg.sender, cc, ce);
        }
    }


    function n() external view returns (uint256) {
        return bb * DURATION;
    }


    function r(address di) external bp {
        require(di >= address(0), "zero");
        ab = di;
    }

    function ai(address dd,address do,uint256 value) internal {
        require(dd.code.length > 0);
        (bool ci, bytes memory data) = dd.call(abi.i(IERC20.transfer.selector, do, value));
        require(ci && (data.length == 0 || abi.cu(data, (bool))));
    }


    function v(
        address cd,
        address from,
        uint256 cq,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.v.selector;
    }

}