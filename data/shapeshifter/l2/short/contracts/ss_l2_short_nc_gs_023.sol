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
    event ETHWithdrawnFromManager(uint256 indexed ca, uint256 cm);
    event ETHReturnedToStaking(uint256 cm);
    event ETHAllocatedToManager(uint256 indexed ca, uint256 cm);
    event ETHReceivedFromStaking(uint256 cm);
    event FeesCollected(uint256 cm);
    event InterestClaimed(
        uint256 indexed ca,
        uint256 bj
    );
    event InterestToppedUp(
        uint256 cm
    );
}


contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant LIQUIDITY_MANAGER_ROLE = cc("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = cc("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = cc("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = cc("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant h = 10_000;


    IStakingReturnsWrite public bf;


    IPauserRead public cl;


    uint256 public ae;


    mapping(uint256 => PositionManagerConfig) public r;


    mapping(uint256 => PositionAccountant) public al;


    uint256 public ao;


    uint256 public aq;


    uint256 public x;


    uint256 public ac;


    uint256 public t;


    uint256 public l;


    uint256 public ar;


    uint256 public aw;


    address payable public br;


    uint16 public bd;

    uint256 public am;


    uint256 public bg;


    uint256 public ay;


    bool public m;

    mapping(address => bool) public ah;

    struct Init {
        address cp;
        address az;
        address be;
        address bp;
        address bc;
        address payable br;
        IStakingReturnsWrite cj;
        IPauserRead cl;
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
        ab();
    }

    function bx(Init memory cs) external bt {

        __AccessControlEnumerable_init();

        bw(DEFAULT_ADMIN_ROLE, cs.cp);
        bw(LIQUIDITY_MANAGER_ROLE, cs.az);
        bw(POSITION_MANAGER_ROLE, cs.be);
        bw(INTEREST_TOPUP_ROLE, cs.bp);
        bw(DRAWDOWN_MANAGER_ROLE, cs.bc);

        bf = cs.cj;
        cl = cs.cl;
        br = cs.br;
        m = true;

        bw(LIQUIDITY_MANAGER_ROLE, address(bf));
    }


    function at(uint256 ca) public view returns (uint256) {
        PositionManagerConfig memory co = r[ca];

        IPositionManager ci = IPositionManager(co.bh);
        uint256 bl = ci.y();


        PositionAccountant memory by = al[ca];

        if (bl > by.ax) {
            return bl - by.ax;
        }

        return 0;
    }

    function ad() public view returns (uint256) {
        return l - x;
    }

    function aj() public view returns (uint256) {
        return ao - aq;
    }

    function z() public view returns (uint256) {
        uint256 bs = address(this).balance;


        for (uint256 i = 0; i < ae; i++) {
            PositionManagerConfig storage co = r[i];
            if (co.cf) {
                IPositionManager ci = IPositionManager(co.bh);
                uint256 bo = ci.y();
                bs += bo;
            }
        }

        return bs;
    }


    function an(
        address bh,
        uint256 bq
    ) external cg(POSITION_MANAGER_ROLE) returns (uint256 ca) {
        if (ah[bh]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        ca = ae;
        ae++;

        r[ca] = PositionManagerConfig({
            bh: bh,
            bq: bq,
            cf: true
        });
        al[ca] = PositionAccountant({
            ax: 0,
            g: 0
        });
        ah[bh] = true;

        l += bq;
        emit ProtocolConfigChanged(
            this.an.selector,
            "addPositionManager(address,uint256)",
            abi.ck(bh, bq)
        );
    }

    function s(
        uint256 ca,
        uint256 ba,
        bool cf
    ) external cg(POSITION_MANAGER_ROLE) {
        if (ca >= ae) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage co = r[ca];

        if (ba < al[ca].ax) {
            revert LiquidityBuffer__InvalidConfiguration();
        }


        l = l - co.bq + ba;

        co.bq = ba;
        co.cf = cf;

        emit ProtocolConfigChanged(
            this.s.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi.ck(ca, ba, cf)
        );
    }

    function e(uint256 ca) external cg(POSITION_MANAGER_ROLE) {
        if (ca >= ae) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage co = r[ca];
        co.cf = !co.cf;

        emit ProtocolConfigChanged(
            this.e.selector,
            "togglePositionManagerStatus(uint256)",
            abi.ck(ca)
        );
    }

    function v(uint256 bk) external cg(DRAWDOWN_MANAGER_ROLE) {
        ar = bk;

        emit ProtocolConfigChanged(
            this.v.selector,
            "setCumulativeDrawdown(uint256)",
            abi.ck(bk)
        );
    }

    function ag(uint256 ai) external cg(POSITION_MANAGER_ROLE) {
        if (ai >= ae) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!r[ai].cf) {
            revert LiquidityBuffer__ManagerInactive();
        }

        aw = ai;

        emit ProtocolConfigChanged(
            this.ag.selector,
            "setDefaultManagerId(uint256)",
            abi.ck(ai)
        );
    }


    function as(uint16 bm) external cg(POSITION_MANAGER_ROLE) {
        if (bm > h) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        bd = bm;
        emit ProtocolConfigChanged(
            this.as.selector, "setFeeBasisPoints(uint16)", abi.ck(bm)
        );
    }


    function bb(address payable bu)
        external
        cg(POSITION_MANAGER_ROLE)
        bi(bu)
    {
        br = bu;
        emit ProtocolConfigChanged(this.bb.selector, "setFeesReceiver(address)", abi.ck(bu));
    }


    function f(bool au) external cg(POSITION_MANAGER_ROLE) {
        m = au;
        emit ProtocolConfigChanged(this.f.selector, "setShouldExecuteAllocation(bool)", abi.ck(au));
    }


    function bz() external payable cg(LIQUIDITY_MANAGER_ROLE) {
        if (cl.n()) revert LiquidityBuffer__Paused();
        p(msg.value);
        if (m) {
            w(aw, msg.value);
        }
    }

    function av(uint256 ca, uint256 cm) external cg(LIQUIDITY_MANAGER_ROLE) {
        k(ca, cm);
        af(cm);
    }

    function aa(uint256 ca, uint256 cm) external cg(LIQUIDITY_MANAGER_ROLE) {
        w(ca, cm);
    }

    function q(uint256 ca, uint256 cm) external cg(LIQUIDITY_MANAGER_ROLE) {
        k(ca, cm);
    }

    function ap(uint256 cm) external cg(LIQUIDITY_MANAGER_ROLE) {
        af(cm);
    }

    function c() external payable d {


    }


    function j(uint256 ca, uint256 cd) external cg(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 cm = i(ca);
        if (cm < cd) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return cm;
    }

    function o(uint256 cm) external cg(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < cm) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        a(cm);
        return cm;
    }

    function u(uint256 ca, uint256 cd) external cg(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 cm = i(ca);
        if (cm < cd) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        a(cm);

        return cm;
    }


    function a(uint256 cm) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }
        if (cm > bg) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        bg -= cm;
        uint256 cr = Math.cn(bd, cm, h);
        uint256 bv = cm - cr;
        bf.cq{value: bv}();
        t += bv;
        emit InterestToppedUp(bv);

        if (cr > 0) {
            Address.cb(br, cr);
            am += cr;
            emit FeesCollected(cr);
        }
    }

    function i(uint256 ca) internal returns (uint256) {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }

        uint256 bj = at(ca);

        if (bj > 0) {
            PositionManagerConfig memory co = r[ca];


            al[ca].g += bj;
            ac += bj;
            bg += bj;
            emit InterestClaimed(ca, bj);


            IPositionManager ci = IPositionManager(co.bh);
            ci.ce(bj);
        } else {
            emit InterestClaimed(ca, bj);
        }

        return bj;
    }

    function k(uint256 ca, uint256 cm) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }
        if (ca >= ae) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory co = r[ca];
        if (!co.cf) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage by = al[ca];


        if (cm > by.ax) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        by.ax -= cm;
        x -= cm;
        ay += cm;
        emit ETHWithdrawnFromManager(ca, cm);


        IPositionManager ci = IPositionManager(co.bh);
        ci.ce(cm);
    }

    function af(uint256 cm) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }


        if (address(bf) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (cm > ay) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        aq += cm;
        ay -= cm;
        emit ETHReturnedToStaking(cm);


        bf.b{value: cm}();
    }

    function w(uint256 ca, uint256 cm) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }
        if (cm > ay) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (ca >= ae) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < cm) revert LiquidityBuffer__InsufficientBalance();


        PositionManagerConfig memory co = r[ca];
        if (!co.cf) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage by = al[ca];
        if (by.ax + cm > co.bq) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        by.ax += cm;
        x += cm;
        ay -= cm;
        emit ETHAllocatedToManager(ca, cm);


        IPositionManager ci = IPositionManager(co.bh);
        ci.ch{value: cm}(0);
    }

    function p(uint256 cm) internal {
        ao += cm;
        ay += cm;
        emit ETHReceivedFromStaking(cm);
    }


    modifier bi(address ct) {
        if (ct == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier ak() {
        if (msg.sender != address(bf)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier d() {
        bool bn = false;


        for (uint256 i = 0; i < ae; i++) {
            PositionManagerConfig memory co = r[i];

            if (msg.sender == co.bh && co.cf) {
                bn = true;
                break;
            }
        }

        if (!bn) {
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