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
    IERC20 public immutable ay;
    address public immutable de;
    address public VE;
    address public DISTRIBUTION;
    address public ad;
    address public ab;

    uint256 public DURATION;
    uint256 internal ai;
    uint256 public bh;
    ICLPool public cz;
    address public as;
    INonfungiblePositionManager public b;

    bool public bk;
    bool public immutable bv;
    address immutable cq;

    mapping(uint256 => uint256) public  n; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal cl;
    mapping(uint256 => uint256) public  j;

    mapping(uint256 => uint256) public  cm;

    mapping(uint256 => uint256) public  af;

    event RewardAdded(uint256 cw);
    event Deposit(address indexed dj, uint256 cx);
    event Withdraw(address indexed dj, uint256 cx);
    event Harvest(address indexed dj, uint256 cw);
    event ClaimFees(address indexed from, uint256 bz, uint256 cc);
    event EmergencyActivated(address indexed dd, uint256 timestamp);
    event EmergencyDeactivated(address indexed dd, uint256 timestamp);

    constructor(address ap, address cy, address dn, address dh, address aj, address z,
        address aa, bool bc, address dk,  address cd) {
        cq = cd;
        ay = IERC20(ap);     // main reward
        de = cy;
        VE = dn;                               // vested
        as = dh;
        cz = ICLPool(dh);
        DISTRIBUTION = aj;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        ad = z;       // lp fees goes here
        ab = aa;       // bribe fees goes here
        bv = bc;
        b = INonfungiblePositionManager(dk);
        bk = false;
    }

    modifier v() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier ag() {
        require(bk == false, "emergency");
        _;
    }

    function ac(uint256 co, int24 bt, int24 bo) internal {
        if (af[co] == block.timestamp) return;
        cz.c();
        af[co] = block.timestamp;
        cm[co] += cn(co);
        j[co] = cz.g(bt, bo, 0);
    }

    function h() external bx {
        require(bk == false, "emergency");
        bk = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function m() external bx {

        require(bk == true,"emergency");

        bk = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function br(uint256 co) external view returns (uint256) {
        (,,,,,,,uint128 bl,,,,) = b.bq(co);
        return bl;
    }

    function x(address cv, address cr, int24 ax) internal view returns (address) {
        return ICLFactory(b.cq()).cf(cv, cr, ax);
    }

    function cu(uint256 co) external view returns (uint256 cw) {
        require(cl[msg.sender].cb(co), "NA");

        uint256 cw = cn(co);
        return (cw); // bonsReward is 0 for now
    }

       function cn(uint256 co) internal view returns (uint256) {
        uint256 av = cz.av();

        uint256 bw = block.timestamp - av;

        uint256 f = cz.f();
        uint256 ah = cz.ah();

        if (bw != 0 && ah > 0 && cz.y() > 0) {
            uint256 cw = bh * bw;
            if (cw > ah) cw = ah;

            f += FullMath.dc(cw, FixedPoint128.Q128, cz.y());
        }

        (,,,,, int24 bt, int24 bo, uint128 bl,,,,) = b.bq(co);

        uint256 a = j[co];
        uint256 d = cz.g(bt, bo, f);

        uint256 bs =
            FullMath.dc(d - a, bl, FixedPoint128.Q128);
        return bs;
    }

    function ck(uint256 co) external ar ag {

         (,,address cv, address cr, int24 ax, int24 bt, int24 bo, uint128 bl,,,,) =
            b.bq(co);

        require(bl > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address am = x(cv, cr, ax);
        // Verify that the position's pool matches this gauge's pool
        require(am == as, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        b.ci(INonfungiblePositionManager.CollectParams({
                co: co,
                bp: msg.sender,
                bd: type(uint128).dm,
                be: type(uint128).dm
            }));

        b.s(msg.sender, address(this), co);

        cz.df(int128(bl), bt, bo, true);

        uint256 an = cz.g(bt, bo, 0);
        j[co] = an;
        af[co] = block.timestamp;

        cl[msg.sender].dl(co);

        emit Deposit(msg.sender, co);
    }

    function ca(uint256 co, uint8 bf) external ar ag {
           require(cl[msg.sender].cb(co), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        b.ci(
            INonfungiblePositionManager.CollectParams({
                co: co,
                bp: msg.sender,
                bd: type(uint128).dm,
                be: type(uint128).dm
            })
        );

        (,,,,, int24 bt, int24 bo, uint128 r,,,,) = b.bq(co);
        bg(bt, bo, co, msg.sender, bf);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (r != 0) {
            cz.df(-int128(r), bt, bo, true);
        }

        cl[msg.sender].da(co);
        b.s(address(this), msg.sender, co);

        emit Withdraw(msg.sender, co);
    }

    function bu(uint256 co, address cg,uint8 bf ) public ar v {

        require(cl[cg].cb(co), "NA");

        (,,,,, int24 bt, int24 bo,,,,,) = b.bq(co);
        bg(bt, bo, co, cg, bf);
    }

    function bg(int24 bt, int24 bo, uint256 co,address cg, uint8 bf) internal {
        ac(co, bt, bo);
        uint256 aq = cm[co];
        if(aq > 0){
            delete cm[co];
            ay.at(de, aq);
            IRHYBR(de).e(aq);
            IRHYBR(de).bi(aq, bf, cg);
        }
        emit Harvest(msg.sender, aq);
    }

    function i(address dg, uint256 aq) external ar
        ag v returns (uint256 aw) {
        require(dg == address(ay), "Invalid reward token");

        // Update global reward growth before processing new rewards
        cz.c();

        // Calculate time remaining until next epoch begins
        uint256 k = HybraTimeLibrary.bm(block.timestamp) - block.timestamp;
        uint256 o = block.timestamp + k;

        // Include any rolled over rewards from previous period
        uint256 p = aq + cz.ce();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= ai) {
            // New period: distribute rewards over remaining epoch time
            bh = aq / k;
            cz.az({
                bh: bh,
                ah: p,
                ao: o
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 ae = k * bh;
            bh = (aq + ae) / k;
            cz.az({
                bh: bh,
                ah: p + ae,
                ao: o
            });
        }

        // Store reward rate for current epoch tracking
        n[HybraTimeLibrary.ba(block.timestamp)] = bh;

        // Transfer reward tokens from distributor to gauge
        ay.s(DISTRIBUTION, address(this), aq);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 w = ay.br(address(this));
        require(bh <= w / k, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        ai = o;
        aw = bh;

        emit RewardAdded(aq);
    }

    function al() external view returns (uint256 cv, uint256 cr){

        (cv, cr) = cz.bj();

    }

    function bn() external ar returns (uint256 bz, uint256 cc) {
        return bb();
    }

    function bb() internal returns (uint256 bz, uint256 cc) {
        if (!bv) {
            return (0, 0);
        }

        cz.au();

        address cj = cz.cv();
        address ch = cz.cr();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        bz = IERC20(cj).br(address(this));
        cc = IERC20(ch).br(address(this));

        if (bz > 0 || cc > 0) {

            uint256 cs = bz;
            uint256 ct = cc;

            if (cs  > 0) {
                IERC20(cj).at(ad, 0);
                IERC20(cj).at(ad, cs);
                IBribe(ad).i(cj, cs);
            }
            if (ct  > 0) {
                IERC20(ch).at(ad, 0);
                IERC20(ch).at(ad, ct);
                IBribe(ad).i(ch, ct);
            }
            emit ClaimFees(msg.sender, bz, cc);
        }
    }

    ///@notice get total reward for the duration
    function q() external view returns (uint256) {
        return bh * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function t(address di) external bx {
        require(di >= address(0), "zero");
        ad = di;
    }

    function ak(address dg,address do,uint256 value) internal {
        require(dg.code.length > 0);
        (bool cp, bytes memory data) = dg.call(abi.l(IERC20.transfer.selector, do, value));
        require(cp && (data.length == 0 || abi.db(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function u(
        address by,
        address from,
        uint256 co,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.u.selector;
    }

}

