pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {ILiquidityBuffer} from "./interfaces/ILiquidityBuffer.sol";
import {IPositionManager} from "./interfaces/IPositionManager.sol";
import {IStakingReturnsWrite} from "../interfaces/IStaking.sol";
import {IPauserRead} from "../interfaces/IPauser.sol";
import {ProtocolEvents} from "../interfaces/ProtocolEvents.sol";

interface LiquidityBufferEvents {
    event ETHWithdrawnFromManager(uint256 indexed ca, uint256 ck);
    event ETHReturnedToStaking(uint256 ck);
    event ETHAllocatedToManager(uint256 indexed ca, uint256 ck);
    event ETHReceivedFromStaking(uint256 ck);
    event FeesCollected(uint256 ck);
    event InterestClaimed(
        uint256 indexed ca,
        uint256 bk
    );
    event InterestToppedUp(
        uint256 ck
    );
}


contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant LIQUIDITY_MANAGER_ROLE = cd("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = cd("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = cd("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = cd("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant h = 10_000;


    IStakingReturnsWrite public bf;


    IPauserRead public co;


    uint256 public ad;


    mapping(uint256 => PositionManagerConfig) public o;


    mapping(uint256 => PositionAccountant) public ak;


    uint256 public am;


    uint256 public ap;


    uint256 public s;


    uint256 public aa;


    uint256 public v;


    uint256 public l;


    uint256 public aq;


    uint256 public ax;


    address payable public br;


    uint16 public bg;

    uint256 public ar;


    uint256 public bd;


    uint256 public ba;


    bool public n;

    mapping(address => bool) public ai;

    struct Init {
        address cq;
        address az;
        address be;
        address bp;
        address bb;
        address payable br;
        IStakingReturnsWrite ch;
        IPauserRead co;
    }


    error LiquidityBuffer__ManagerNotFound();
    error LiquidityBuffer__ManagerInactive();
    error LiquidityBuffer__ManagerAlreadyRegistered();
    error LiquidityBuffer__ExceedsAllocationCap();
    error LiquidityBuffer__InsufficientBalance();
    error LiquidityBuffer__InsufficientAllocation();
    error LiquidityBuffer__DoesNotReceiveETH();
    error LiquidityBuffer__Paused();
    error LiquidityBuffer__InvalidConfiguration();
    error LiquidityBuffer__ZeroAddress();
    error LiquidityBuffer__NotStakingContract();
    error LiquidityBuffer__NotPositionManagerContract();
    error LiquidityBuffer__ExceedsPendingInterest();
    error LiquidityBuffer__ExceedsPendingPrincipal();


    constructor() {
        ae();
    }

    function by(Init memory cr) external bu {

        __AccessControlEnumerable_init();

        bz(DEFAULT_ADMIN_ROLE, cr.cq);
        bz(LIQUIDITY_MANAGER_ROLE, cr.az);
        bz(POSITION_MANAGER_ROLE, cr.be);
        bz(INTEREST_TOPUP_ROLE, cr.bp);
        bz(DRAWDOWN_MANAGER_ROLE, cr.bb);

        bf = cr.ch;
        co = cr.co;
        br = cr.br;
        n = true;

        bz(LIQUIDITY_MANAGER_ROLE, address(bf));
    }


    function au(uint256 ca) public view returns (uint256) {
        PositionManagerConfig memory cl = o[ca];

        IPositionManager cj = IPositionManager(cl.bi);
        uint256 bo = cj.z();


        PositionAccountant memory bx = ak[ca];

        if (bo > bx.ay) {
            return bo - bx.ay;
        }

        return 0;
    }

    function ac() public view returns (uint256) {
        return l - s;
    }

    function ag() public view returns (uint256) {
        return am - ap;
    }

    function ab() public view returns (uint256) {
        uint256 bs = address(this).balance;


        for (uint256 i = 0; i < ad; i++) {
            PositionManagerConfig storage cl = o[i];
            if (cl.cg) {
                IPositionManager cj = IPositionManager(cl.bi);
                uint256 bn = cj.z();
                bs += bn;
            }
        }

        return bs;
    }


    function ao(
        address bi,
        uint256 bq
    ) external ce(POSITION_MANAGER_ROLE) returns (uint256 ca) {
        if (ai[bi]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        ca = ad;
        ad++;

        o[ca] = PositionManagerConfig({
            bi: bi,
            bq: bq,
            cg: true
        });
        ak[ca] = PositionAccountant({
            ay: 0,
            f: 0
        });
        ai[bi] = true;

        l += bq;
        emit ProtocolConfigChanged(
            this.ao.selector,
            "addPositionManager(address,uint256)",
            abi.cn(bi, bq)
        );
    }

    function x(
        uint256 ca,
        uint256 aw,
        bool cg
    ) external ce(POSITION_MANAGER_ROLE) {
        if (ca >= ad) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage cl = o[ca];

        if (aw < ak[ca].ay) {
            revert LiquidityBuffer__InvalidConfiguration();
        }


        l = l - cl.bq + aw;

        cl.bq = aw;
        cl.cg = cg;

        emit ProtocolConfigChanged(
            this.x.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi.cn(ca, aw, cg)
        );
    }

    function d(uint256 ca) external ce(POSITION_MANAGER_ROLE) {
        if (ca >= ad) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage cl = o[ca];
        cl.cg = !cl.cg;

        emit ProtocolConfigChanged(
            this.d.selector,
            "togglePositionManagerStatus(uint256)",
            abi.cn(ca)
        );
    }

    function t(uint256 bm) external ce(DRAWDOWN_MANAGER_ROLE) {
        aq = bm;

        emit ProtocolConfigChanged(
            this.t.selector,
            "setCumulativeDrawdown(uint256)",
            abi.cn(bm)
        );
    }

    function af(uint256 aj) external ce(POSITION_MANAGER_ROLE) {
        if (aj >= ad) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!o[aj].cg) {
            revert LiquidityBuffer__ManagerInactive();
        }

        ax = aj;

        emit ProtocolConfigChanged(
            this.af.selector,
            "setDefaultManagerId(uint256)",
            abi.cn(aj)
        );
    }


    function av(uint16 bl) external ce(POSITION_MANAGER_ROLE) {
        if (bl > h) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        bg = bl;
        emit ProtocolConfigChanged(
            this.av.selector, "setFeeBasisPoints(uint16)", abi.cn(bl)
        );
    }


    function bc(address payable bt)
        external
        ce(POSITION_MANAGER_ROLE)
        bh(bt)
    {
        br = bt;
        emit ProtocolConfigChanged(this.bc.selector, "setFeesReceiver(address)", abi.cn(bt));
    }


    function g(bool as) external ce(POSITION_MANAGER_ROLE) {
        n = as;
        emit ProtocolConfigChanged(this.g.selector, "setShouldExecuteAllocation(bool)", abi.cn(as));
    }


    function bw() external payable ce(LIQUIDITY_MANAGER_ROLE) {
        if (co.m()) revert LiquidityBuffer__Paused();
        r(msg.value);
        if (n) {
            w(ax, msg.value);
        }
    }

    function at(uint256 ca, uint256 ck) external ce(LIQUIDITY_MANAGER_ROLE) {
        k(ca, ck);
        al(ck);
    }

    function y(uint256 ca, uint256 ck) external ce(LIQUIDITY_MANAGER_ROLE) {
        w(ca, ck);
    }

    function p(uint256 ca, uint256 ck) external ce(LIQUIDITY_MANAGER_ROLE) {
        k(ca, ck);
    }

    function an(uint256 ck) external ce(LIQUIDITY_MANAGER_ROLE) {
        al(ck);
    }

    function c() external payable e {


    }


    function j(uint256 ca, uint256 cb) external ce(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 ck = i(ca);
        if (ck < cb) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return ck;
    }

    function q(uint256 ck) external ce(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < ck) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        a(ck);
        return ck;
    }

    function u(uint256 ca, uint256 cb) external ce(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 ck = i(ca);
        if (ck < cb) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        a(ck);

        return ck;
    }


    function a(uint256 ck) internal {
        if (co.m()) {
            revert LiquidityBuffer__Paused();
        }
        if (ck > bd) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        bd -= ck;
        uint256 cs = Math.cm(bg, ck, h);
        uint256 bv = ck - cs;
        bf.cp{value: bv}();
        v += bv;
        emit InterestToppedUp(bv);

        if (cs > 0) {
            Address.cc(br, cs);
            ar += cs;
            emit FeesCollected(cs);
        }
    }

    function i(uint256 ca) internal returns (uint256) {
        if (co.m()) {
            revert LiquidityBuffer__Paused();
        }

        uint256 bk = au(ca);

        if (bk > 0) {
            PositionManagerConfig memory cl = o[ca];


            ak[ca].f += bk;
            aa += bk;
            bd += bk;
            emit InterestClaimed(ca, bk);


            IPositionManager cj = IPositionManager(cl.bi);
            cj.cf(bk);
        } else {
            emit InterestClaimed(ca, bk);
        }

        return bk;
    }

    function k(uint256 ca, uint256 ck) internal {
        if (co.m()) {
            revert LiquidityBuffer__Paused();
        }
        if (ca >= ad) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory cl = o[ca];
        if (!cl.cg) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage bx = ak[ca];


        if (ck > bx.ay) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        bx.ay -= ck;
        s -= ck;
        ba += ck;
        emit ETHWithdrawnFromManager(ca, ck);


        IPositionManager cj = IPositionManager(cl.bi);
        cj.cf(ck);
    }

    function al(uint256 ck) internal {
        if (co.m()) {
            revert LiquidityBuffer__Paused();
        }


        if (address(bf) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (ck > ba) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        ap += ck;
        ba -= ck;
        emit ETHReturnedToStaking(ck);


        bf.b{value: ck}();
    }

    function w(uint256 ca, uint256 ck) internal {
        if (co.m()) {
            revert LiquidityBuffer__Paused();
        }
        if (ck > ba) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (ca >= ad) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < ck) revert LiquidityBuffer__InsufficientBalance();


        PositionManagerConfig memory cl = o[ca];
        if (!cl.cg) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage bx = ak[ca];
        if (bx.ay + ck > cl.bq) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        bx.ay += ck;
        s += ck;
        ba -= ck;
        emit ETHAllocatedToManager(ca, ck);


        IPositionManager cj = IPositionManager(cl.bi);
        cj.ci{value: ck}(0);
    }

    function r(uint256 ck) internal {
        am += ck;
        ba += ck;
        emit ETHReceivedFromStaking(ck);
    }


    modifier bh(address ct) {
        if (ct == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier ah() {
        if (msg.sender != address(bf)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier e() {
        bool bj = false;


        for (uint256 i = 0; i < ad; i++) {
            PositionManagerConfig memory cl = o[i];

            if (msg.sender == cl.bi && cl.cg) {
                bj = true;
                break;
            }
        }

        if (!bj) {
            revert LiquidityBuffer__NotPositionManagerContract();
        }
        _;
    }

    receive() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }

    fallback() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }
}