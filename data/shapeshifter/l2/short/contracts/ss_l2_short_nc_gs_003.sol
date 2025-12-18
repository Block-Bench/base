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
        address at,
        uint256 an
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable ba;
    bool public bb;

    IERC20 public immutable am;
    IERC20 public immutable TOKEN;
    address public immutable cb;
    address public VE;
    address public DISTRIBUTION;
    address public y;
    address public u;
    address public v;

    uint256 public DURATION;
    uint256 internal z;
    uint256 public ao;
    uint256 public w;
    uint256 public g;

    mapping(address => uint256) public d;
    mapping(address => uint256) public bm;

    uint256 internal ab;
    mapping(address => uint256) internal ax;
    mapping(address => uint256) public ag;

    event RewardAdded(uint256 bv);
    event Deposit(address indexed cd, uint256 bu);
    event Withdraw(address indexed cd, uint256 bu);
    event Harvest(address indexed cd, uint256 bv);

    event ClaimFees(address indexed from, uint256 bh, uint256 bj);
    event EmergencyActivated(address indexed bz, uint256 timestamp);
    event EmergencyDeactivated(address indexed bz, uint256 timestamp);

    modifier ad(address bo) {
        g = s();
        w = a();
        if (bo != address(0)) {
            bm[bo] = bx(bo);
            d[bo] = g;
        }
        _;
    }

    modifier m() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier x() {
        require(bb == false, "EMER");
        _;
    }

    constructor(address ah,address bq,address ce,address bs,address aa, address q, address r, bool ap) {
        am = IERC20(ah);
        cb = bq;
        VE = ce;
        TOKEN = IERC20(bs);
        DISTRIBUTION = aa;
        DURATION = HybraTimeLibrary.WEEK;

        u = q;
        v = r;

        ba = ap;

        bb = false;

    }


    function p(address aa) external ay {
        require(aa != address(0), "ZA");
        require(aa != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = aa;
    }


    function n(address t) external ay {
        require(t != y, "SAME_ADDR");
        y = t;
    }


    function l(address cc) external ay {
        require(cc >= address(0), "ZA");
        u = cc;
    }

    function e() external ay {
        require(bb == false, "EMER");
        bb = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function j() external ay {

        require(bb == true,"EMER");

        bb = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }


    function ak() public view returns (uint256) {
        return ab;
    }


    function az(address bo) external view returns (uint256) {
        return aq(bo);
    }

    function aq(address bo) internal view returns (uint256) {

        return ax[bo];
    }


    function a() public view returns (uint256) {
        return Math.cf(block.timestamp, z);
    }


    function s() public view returns (uint256) {
        if (ab == 0) {
            return g;
        } else {
            return g + (a() - w) * ao * 1e18 / ab;
        }
    }


    function bx(address bo) public view returns (uint256) {
        return bm[bo] + aq(bo) * (s() - d[bo]) / 1e18;
    }


    function k() external view returns (uint256) {
        return ao * DURATION;
    }

    function ae() external view returns (uint256) {
        return z;
    }


    function ar() external {
        bf(TOKEN.az(msg.sender), msg.sender);
    }


    function bn(uint256 bu) external {
        bf(bu, msg.sender);
    }


    function bf(uint256 bu, address bo) internal ac x ad(bo) {
        require(bu > 0, "ZV");

        ax[bo] = ax[bo] + bu;
        ab = ab + bu;
        if (address(y) != address(0)) {
            IRewarder(y).bi(bo, bo, aq(bo));
        }

        TOKEN.o(bo, address(this), bu);

        emit Deposit(bo, bu);
    }


    function al() external {
        aw(aq(msg.sender));
    }


    function bg(uint256 bu) external {
        aw(bu);
    }


    function aw(uint256 bu) internal ac x ad(msg.sender) {
        require(bu > 0, "ZV");
        require(aq(msg.sender) > 0, "ZV");
        require(block.timestamp >= ag[msg.sender], "!MATURE");

        ab = ab - bu;
        ax[msg.sender] = ax[msg.sender] - bu;

        if (address(y) != address(0)) {
            IRewarder(y).bi(msg.sender, msg.sender,aq(msg.sender));
        }

        TOKEN.af(msg.sender, bu);

        emit Withdraw(msg.sender, bu);
    }

    function i() external ac {
        require(bb, "EMER");
        uint256 bp = aq(msg.sender);
        require(bp > 0, "ZV");
        ab = ab - bp;

        ax[msg.sender] = 0;

        TOKEN.af(msg.sender, bp);
        emit Withdraw(msg.sender, bp);
    }

    function b(uint256 bp) external ac {

        require(bb, "EMER");
        ab = ab - bp;

        ax[msg.sender] = ax[msg.sender] - bp;

        TOKEN.af(msg.sender, bp);
        emit Withdraw(msg.sender, bp);
    }


    function f(uint8 ai) external {
        aw(aq(msg.sender));
        av(ai);
    }


    function av(address ca, uint8 ai) public ac m ad(ca) {
        uint256 bv = bm[ca];
        if (bv > 0) {
            bm[ca] = 0;
            IERC20(am).aj(cb, bv);
            IRHYBR(cb).c(bv);
            IRHYBR(cb).au(bv, ai, ca);
            emit Harvest(ca, bv);
        }

        if (y != address(0)) {
            IRewarder(y).bi(ca, ca, aq(ca));
        }
    }


    function av(uint8 ai) public ac ad(msg.sender) {
        uint256 bv = bm[msg.sender];
        if (bv > 0) {
            bm[msg.sender] = 0;
            IERC20(am).aj(cb, bv);
            IRHYBR(cb).c(bv);
            IRHYBR(cb).au(bv, ai, msg.sender);
            emit Harvest(msg.sender, bv);
        }

        if (y != address(0)) {
            IRewarder(y).bi(msg.sender, msg.sender, aq(msg.sender));
        }
    }


    function h(address by, uint256 bv) external ac x m ad(address(0)) {
        require(by == address(am), "IA");
        am.o(DISTRIBUTION, address(this), bv);

        if (block.timestamp >= z) {
            ao = bv / DURATION;
        } else {
            uint256 bc = z - block.timestamp;
            uint256 be = bc * ao;
            ao = (bv + be) / DURATION;
        }


        uint256 balance = am.az(address(this));
        require(ao <= balance / DURATION, "REWARD_HIGH");

        w = block.timestamp;
        z = block.timestamp + DURATION;
        emit RewardAdded(bv);
    }

    function bd() external ac returns (uint256 bh, uint256 bj) {
        return as();
    }

     function as() internal returns (uint256 bh, uint256 bj) {
        if (!ba) {
            return (0, 0);
        }
        address bs = address(TOKEN);
        (bh, bj) = IPair(bs).bd();
        if (bh > 0 || bj > 0) {

            uint256 bw = bh;
            uint256 bt = bj;

            (address bl, address bk) = IPair(bs).br();

            if (bw  > 0) {
                IERC20(bl).aj(u, 0);
                IERC20(bl).aj(u, bw);
                IBribe(u).h(bl, bw);
            }
            if (bt  > 0) {
                IERC20(bk).aj(u, 0);
                IERC20(bk).aj(u, bt);
                IBribe(u).h(bk, bt);
            }
            emit ClaimFees(msg.sender, bh, bj);
        }
    }

}