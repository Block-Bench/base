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
    function be(
        address cd,
        address aw,
        uint256 ak
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable ba;
    bool public ax;

    IERC20 public immutable aj;
    IERC20 public immutable TOKEN;
    address public immutable ca;
    address public VE;
    address public DISTRIBUTION;
    address public z;
    address public x;
    address public u;

    uint256 public DURATION;
    uint256 internal y;
    uint256 public as;
    uint256 public t;
    uint256 public g;

    mapping(address => uint256) public d;
    mapping(address => uint256) public bo;

    uint256 internal ac;
    mapping(address => uint256) internal bc;
    mapping(address => uint256) public af;

    event RewardAdded(uint256 br);
    event Deposit(address indexed cd, uint256 bq);
    event Withdraw(address indexed cd, uint256 bq);
    event Harvest(address indexed cd, uint256 br);

    event ClaimFees(address indexed from, uint256 bi, uint256 bj);
    event EmergencyActivated(address indexed cb, uint256 timestamp);
    event EmergencyDeactivated(address indexed cb, uint256 timestamp);

    modifier ag(address bp) {
        g = s();
        t = a();
        if (bp != address(0)) {
            bo[bp] = bv(bp);
            d[bp] = g;
        }
        _;
    }

    modifier l() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier v() {
        require(ax == false, "EMER");
        _;
    }

    constructor(address ab,address bs,address ce,address bt,address aa, address q, address p, bool ao) {
        aj = IERC20(ab);
        ca = bs;
        VE = ce;
        TOKEN = IERC20(bt);
        DISTRIBUTION = aa;
        DURATION = HybraTimeLibrary.WEEK;

        x = q;
        u = p;

        ba = ao;

        ax = false;

    }


    function r(address aa) external ay {
        require(aa != address(0), "ZA");
        require(aa != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = aa;
    }


    function n(address w) external ay {
        require(w != z, "SAME_ADDR");
        z = w;
    }


    function m(address cc) external ay {
        require(cc >= address(0), "ZA");
        x = cc;
    }

    function e() external ay {
        require(ax == false, "EMER");
        ax = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function i() external ay {

        require(ax == true,"EMER");

        ax = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }


    function ai() public view returns (uint256) {
        return ac;
    }


    function bd(address bp) external view returns (uint256) {
        return ap(bp);
    }

    function ap(address bp) internal view returns (uint256) {

        return bc[bp];
    }


    function a() public view returns (uint256) {
        return Math.cf(block.timestamp, y);
    }


    function s() public view returns (uint256) {
        if (ac == 0) {
            return g;
        } else {
            return g + (a() - t) * as * 1e18 / ac;
        }
    }


    function bv(address bp) public view returns (uint256) {
        return bo[bp] + ap(bp) * (s() - d[bp]) / 1e18;
    }


    function k() external view returns (uint256) {
        return as * DURATION;
    }

    function ah() external view returns (uint256) {
        return y;
    }


    function ar() external {
        bf(TOKEN.bd(msg.sender), msg.sender);
    }


    function bl(uint256 bq) external {
        bf(bq, msg.sender);
    }


    function bf(uint256 bq, address bp) internal ad v ag(bp) {
        require(bq > 0, "ZV");

        bc[bp] = bc[bp] + bq;
        ac = ac + bq;
        if (address(z) != address(0)) {
            IRewarder(z).be(bp, bp, ap(bp));
        }

        TOKEN.o(bp, address(this), bq);

        emit Deposit(bp, bq);
    }


    function am() external {
        bb(ap(msg.sender));
    }


    function bg(uint256 bq) external {
        bb(bq);
    }


    function bb(uint256 bq) internal ad v ag(msg.sender) {
        require(bq > 0, "ZV");
        require(ap(msg.sender) > 0, "ZV");
        require(block.timestamp >= af[msg.sender], "!MATURE");

        ac = ac - bq;
        bc[msg.sender] = bc[msg.sender] - bq;

        if (address(z) != address(0)) {
            IRewarder(z).be(msg.sender, msg.sender,ap(msg.sender));
        }

        TOKEN.ae(msg.sender, bq);

        emit Withdraw(msg.sender, bq);
    }

    function j() external ad {
        require(ax, "EMER");
        uint256 bn = ap(msg.sender);
        require(bn > 0, "ZV");
        ac = ac - bn;

        bc[msg.sender] = 0;

        TOKEN.ae(msg.sender, bn);
        emit Withdraw(msg.sender, bn);
    }

    function b(uint256 bn) external ad {

        require(ax, "EMER");
        ac = ac - bn;

        bc[msg.sender] = bc[msg.sender] - bn;

        TOKEN.ae(msg.sender, bn);
        emit Withdraw(msg.sender, bn);
    }


    function f(uint8 al) external {
        bb(ap(msg.sender));
        at(al);
    }


    function at(address by, uint8 al) public ad l ag(by) {
        uint256 br = bo[by];
        if (br > 0) {
            bo[by] = 0;
            IERC20(aj).an(ca, br);
            IRHYBR(ca).c(br);
            IRHYBR(ca).au(br, al, by);
            emit Harvest(by, br);
        }

        if (z != address(0)) {
            IRewarder(z).be(by, by, ap(by));
        }
    }


    function at(uint8 al) public ad ag(msg.sender) {
        uint256 br = bo[msg.sender];
        if (br > 0) {
            bo[msg.sender] = 0;
            IERC20(aj).an(ca, br);
            IRHYBR(ca).c(br);
            IRHYBR(ca).au(br, al, msg.sender);
            emit Harvest(msg.sender, br);
        }

        if (z != address(0)) {
            IRewarder(z).be(msg.sender, msg.sender, ap(msg.sender));
        }
    }


    function h(address bz, uint256 br) external ad v l ag(address(0)) {
        require(bz == address(aj), "IA");
        aj.o(DISTRIBUTION, address(this), br);

        if (block.timestamp >= y) {
            as = br / DURATION;
        } else {
            uint256 az = y - block.timestamp;
            uint256 bh = az * as;
            as = (br + bh) / DURATION;
        }


        uint256 balance = aj.bd(address(this));
        require(as <= balance / DURATION, "REWARD_HIGH");

        t = block.timestamp;
        y = block.timestamp + DURATION;
        emit RewardAdded(br);
    }

    function av() external ad returns (uint256 bi, uint256 bj) {
        return aq();
    }

     function aq() internal returns (uint256 bi, uint256 bj) {
        if (!ba) {
            return (0, 0);
        }
        address bt = address(TOKEN);
        (bi, bj) = IPair(bt).av();
        if (bi > 0 || bj > 0) {

            uint256 bu = bi;
            uint256 bx = bj;

            (address bm, address bk) = IPair(bt).bw();

            if (bu  > 0) {
                IERC20(bm).an(x, 0);
                IERC20(bm).an(x, bu);
                IBribe(x).h(bm, bu);
            }
            if (bx  > 0) {
                IERC20(bk).an(x, 0);
                IERC20(bk).an(x, bx);
                IBribe(x).h(bk, bx);
            }
            emit ClaimFees(msg.sender, bi, bj);
        }
    }

}