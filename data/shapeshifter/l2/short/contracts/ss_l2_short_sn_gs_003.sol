// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/IPair.sol';
import './interfaces/IBribe.sol';
import "./libraries/Math.sol";

import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import './interfaces/IRHYBR.sol';
interface IRewarder {
    function bi(
        address cd,
        address ax,
        uint256 ak
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable bc;
    bool public au;

    IERC20 public immutable am;
    IERC20 public immutable TOKEN;
    address public immutable bz;
    address public VE;
    address public DISTRIBUTION;
    address public y;
    address public v;
    address public s;

    uint256 public DURATION;
    uint256 internal z;
    uint256 public as;
    uint256 public w;
    uint256 public g;

    mapping(address => uint256) public d;
    mapping(address => uint256) public bp;

    uint256 internal ae;
    mapping(address => uint256) internal aw;
    mapping(address => uint256) public ah;

    event RewardAdded(uint256 bv);
    event Deposit(address indexed cd, uint256 bw);
    event Withdraw(address indexed cd, uint256 bw);
    event Harvest(address indexed cd, uint256 bv);

    event ClaimFees(address indexed from, uint256 be, uint256 bj);
    event EmergencyActivated(address indexed by, uint256 timestamp);
    event EmergencyDeactivated(address indexed by, uint256 timestamp);

    modifier ad(address bk) {
        g = u();
        w = a();
        if (bk != address(0)) {
            bp[bk] = bt(bk);
            d[bk] = g;
        }
        _;
    }

    modifier o() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier x() {
        require(au == false, "EMER");
        _;
    }

    constructor(address af,address bx,address ce,address bu,address aa, address p, address r, bool ar) {
        am = IERC20(af);     // main reward
        bz = bx;
        VE = ce;                               // vested
        TOKEN = IERC20(bu);                 // underlying (LP)
        DISTRIBUTION = aa;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        v = p;       // lp fees goes here
        s = r;       // bribe fees goes here

        bc = ar;                 // pair boolean, if false no claim_fees

        au = false;                      // emergency flag

    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    ONLY OWNER
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice set distribution address (should be GaugeManager)
    function q(address aa) external bd {
        require(aa != address(0), "ZA");
        require(aa != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = aa;
    }

    ///@notice set gauge rewarder address
    function n(address t) external bd {
        require(t != y, "SAME_ADDR");
        y = t;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function m(address cc) external bd {
        require(cc >= address(0), "ZA");
        v = cc;
    }

    function e() external bd {
        require(au == false, "EMER");
        au = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function i() external bd {

        require(au == true,"EMER");

        au = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VIEW FUNCTIONS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice total supply held
    function al() public view returns (uint256) {
        return ae;
    }

    ///@notice balance of a user
    function az(address bk) external view returns (uint256) {
        return ap(bk);
    }

    function ap(address bk) internal view returns (uint256) {

        return aw[bk];
    }

    ///@notice last time reward
    function a() public view returns (uint256) {
        return Math.cf(block.timestamp, z);
    }

    ///@notice  reward for a sinle token
    function u() public view returns (uint256) {
        if (ae == 0) {
            return g;
        } else {
            return g + (a() - w) * as * 1e18 / ae;
        }
    }

    ///@notice see earned rewards for user
    function bt(address bk) public view returns (uint256) {
        return bp[bk] + ap(bk) * (u() - d[bk]) / 1e18;
    }

    ///@notice get total reward for the duration
    function k() external view returns (uint256) {
        return as * DURATION;
    }

    function ac() external view returns (uint256) {
        return z;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    // send whole liquidity as additional param

    ///@notice deposit all TOKEN of msg.sender
    function ao() external {
        bh(TOKEN.az(msg.sender), msg.sender);
    }

    ///@notice deposit amount TOKEN
    function bo(uint256 bw) external {
        bh(bw, msg.sender);
    }

    ///@notice deposit internal
    function bh(uint256 bw, address bk) internal ag x ad(bk) {
        require(bw > 0, "ZV");

        aw[bk] = aw[bk] + bw;
        ae = ae + bw;
        if (address(y) != address(0)) {
            IRewarder(y).bi(bk, bk, ap(bk));
        }

        TOKEN.l(bk, address(this), bw);

        emit Deposit(bk, bw);
    }

    ///@notice withdraw all token
    function ai() external {
        ba(ap(msg.sender));
    }

    ///@notice withdraw a certain amount of TOKEN
    function bf(uint256 bw) external {
        ba(bw);
    }

    ///@notice withdraw internal
    function ba(uint256 bw) internal ag x ad(msg.sender) {
        require(bw > 0, "ZV");
        require(ap(msg.sender) > 0, "ZV");
        require(block.timestamp >= ah[msg.sender], "!MATURE");

        ae = ae - bw;
        aw[msg.sender] = aw[msg.sender] - bw;

        if (address(y) != address(0)) {
            IRewarder(y).bi(msg.sender, msg.sender,ap(msg.sender));
        }

        TOKEN.ab(msg.sender, bw);

        emit Withdraw(msg.sender, bw);
    }

    function j() external ag {
        require(au, "EMER");
        uint256 bm = ap(msg.sender);
        require(bm > 0, "ZV");
        ae = ae - bm;

        aw[msg.sender] = 0;

        TOKEN.ab(msg.sender, bm);
        emit Withdraw(msg.sender, bm);
    }

    function b(uint256 bm) external ag {

        require(au, "EMER");
        ae = ae - bm;

        aw[msg.sender] = aw[msg.sender] - bm;

        TOKEN.ab(msg.sender, bm);
        emit Withdraw(msg.sender, bm);
    }

    ///@notice withdraw all TOKEN and harvest rewardToken
    function f(uint8 an) external {
        ba(ap(msg.sender));
        bb(an);
    }

    ///@notice User harvest function called from distribution (GaugeManager allows harvest on multiple gauges)
    function bb(address cb, uint8 an) public ag o ad(cb) {
        uint256 bv = bp[cb];
        if (bv > 0) {
            bp[cb] = 0;
            IERC20(am).aj(bz, bv);
            IRHYBR(bz).c(bv);
            IRHYBR(bz).at(bv, an, cb);
            emit Harvest(cb, bv);
        }

        if (y != address(0)) {
            IRewarder(y).bi(cb, cb, ap(cb));
        }
    }

    ///@notice User harvest function
    function bb(uint8 an) public ag ad(msg.sender) {
        uint256 bv = bp[msg.sender];
        if (bv > 0) {
            bp[msg.sender] = 0;
            IERC20(am).aj(bz, bv);
            IRHYBR(bz).c(bv);
            IRHYBR(bz).at(bv, an, msg.sender);
            emit Harvest(msg.sender, bv);
        }

        if (y != address(0)) {
            IRewarder(y).bi(msg.sender, msg.sender, ap(msg.sender));
        }
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    DISTRIBUTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @dev Receive rewards from distribution

    function h(address ca, uint256 bv) external ag x o ad(address(0)) {
        require(ca == address(am), "IA");
        am.l(DISTRIBUTION, address(this), bv);

        if (block.timestamp >= z) {
            as = bv / DURATION;
        } else {
            uint256 ay = z - block.timestamp;
            uint256 bg = ay * as;
            as = (bv + bg) / DURATION;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.

        // very high values of rewardRate in the earned and rewardsPerToken functions;

        uint256 balance = am.az(address(this));
        require(as <= balance / DURATION, "REWARD_HIGH");

        w = block.timestamp;
        z = block.timestamp + DURATION;
        emit RewardAdded(bv);
    }

    function av() external ag returns (uint256 be, uint256 bj) {
        return aq();
    }

     function aq() internal returns (uint256 be, uint256 bj) {
        if (!bc) {
            return (0, 0);
        }
        address bu = address(TOKEN);
        (be, bj) = IPair(bu).av();
        if (be > 0 || bj > 0) {

            uint256 br = be;
            uint256 bs = bj;

            (address bn, address bl) = IPair(bu).bq();

            if (br  > 0) {
                IERC20(bn).aj(v, 0);
                IERC20(bn).aj(v, br);
                IBribe(v).h(bn, br);
            }
            if (bs  > 0) {
                IERC20(bl).aj(v, 0);
                IERC20(bl).aj(v, bs);
                IBribe(v).h(bl, bs);
            }
            emit ClaimFees(msg.sender, be, bj);
        }
    }

}