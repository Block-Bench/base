pragma solidity =0.7.6;

import "./interfaces/ICLFactory.sol";
import "./interfaces/fees/IFeeModule.sol";

import "./interfaces/IGaugeManager.sol";
import "./interfaces/IFactoryRegistry.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@nomad-xyz/src/ExcessivelySafeCall.sol";
import "./CLPool.sol";


contract CLFactory is ICLFactory {
    using ExcessivelySafeCall for address;


    IGaugeManager public override ar;

    address public immutable override q;

    address public override bv;

    address public override aj;

    address public override am;

    address public override p;

    address public override ab;

    uint24 public override r;


    address public override u;

    address public override aa;

    uint24 public override s;

    mapping(int24 => uint24) public override ac;

    mapping(address => mapping(address => mapping(int24 => address))) public override bj;

    mapping(address => bool) private bi;

    address[] public override bd;

    int24[] private ao;

    constructor(address n) {
        bv = msg.sender;
        aj = msg.sender;
        p = msg.sender;
        u = msg.sender;
        q = n;
        r = 100_000;
        s = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        z(1, 100);
        z(50, 500);
        z(100, 500);
        z(200, 3_000);
        z(2_000, 10_000);
    }

    function ae(address ap) external {
        require(msg.sender == bv);
        ar = IGaugeManager(ap);
    }


    function ax(address bu, address bs, int24 av, uint160 aq)
        external
        override
        returns (address bx)
    {
        require(bu != bs);
        (address bt, address bn) = bu < bs ? (bu, bs) : (bs, bu);
        require(bt != address(0));
        require(ac[av] != 0);
        require(bj[bt][bn][av] == address(0));
        bx = Clones.w({
            bm: q,
            bw: ba(abi.bl(bt, bn, av))
        });
        CLPool(bx).ay({
            bb: address(this),
            bg: bt,
            bf: bn,
            au: av,
            ap: address(ar),
            an: aq
        });
        bd.push(bx);
        bi[bx] = true;
        bj[bt][bn][av] = bx;

        bj[bn][bt][av] = bx;
        emit PoolCreated(bt, bn, av, bx);
    }


    function bc(address br) external override {
        address aw = bv;
        require(msg.sender == aw);
        require(br != address(0));
        emit OwnerChanged(aw, br);
        bv = br;
    }


    function y(address af) external override {
        address i = aj;
        require(msg.sender == i);
        require(af != address(0));
        aj = af;
        emit SwapFeeManagerChanged(i, af);
    }


    function f(address l) external override {
        address b = p;
        require(msg.sender == b);
        require(l != address(0));
        p = l;
        emit UnstakedFeeManagerChanged(b, l);
    }


    function ad(address ah) external override {
        require(msg.sender == aj);
        require(ah != address(0));
        address as = am;
        am = ah;
        emit SwapFeeModuleChanged(as, ah);
    }


    function g(address v) external override {
        require(msg.sender == p);
        require(v != address(0));
        address as = ab;
        ab = v;
        emit UnstakedFeeModuleChanged(as, v);
    }


    function e(uint24 j) external override {
        require(msg.sender == p);
        require(j <= 500_000);
        uint24 ai = r;
        r = j;
        emit DefaultUnstakedFeeChanged(ai, j);
    }

    function h(address x) external override {
        require(msg.sender == u);
        require(x != address(0));
        aa = x;
    }

    function d(address o) external override {
        require(msg.sender == u);
        require(o != address(0));
        u = o;
    }


    function az(address bx) external view override returns (uint24) {
        if (am != address(0)) {
            (bool bh, bytes memory data) = am.a(
                200_000, 32, abi.t(IFeeModule.bo.selector, bx)
            );
            if (bh) {
                uint24 by = abi.bp(data, (uint24));
                if (by <= 100_000) {
                    return by;
                }
            }
        }
        return ac[CLPool(bx).av()];
    }


    function ag(address bx) external view override returns (uint24) {

        if (!ar.m(bx)) {
            return 0;
        }
        if (ab != address(0)) {
            (bool bh, bytes memory data) = ab.a(
                200_000, 32, abi.t(IFeeModule.bo.selector, bx)
            );
            if (bh) {
                uint24 by = abi.bp(data, (uint24));
                if (by <= 1_000_000) {
                    return by;
                }
            }
        }
        return r;
    }

    function al(address bx) external view override returns (uint24) {

        if (ar.m(bx)) {
            return 0;
        }

        if (aa != address(0)) {
            (bool bh, bytes memory data) = aa.a(
                200_000, 32, abi.t(IFeeModule.bo.selector, bx)
            );
            if (bh) {
                uint24 by = abi.bp(data, (uint24));
                if (by <= 500_000) {
                    return by;
                }
            }
        }
        return s;
    }


    function z(int24 av, uint24 by) public override {
        require(msg.sender == bv);
        require(by > 0 && by <= 100_000);


        require(av > 0 && av < 16384);
        require(ac[av] == 0);

        ac[av] = by;
        ao.push(av);
        emit TickSpacingEnabled(av, by);
    }

    function c() external  {
        require(msg.sender == bv);

        for (uint256 i = 0; i < bd.length; i++) {
            CLPool(bd[i]).k(msg.sender);
        }
    }

    function k(address bx) external returns (uint128 be, uint128 bk) {
        require(msg.sender == bv);
        (be, bk) = CLPool(bx).k(msg.sender);
    }


    function at() external view override returns (int24[] memory) {
        return ao;
    }


    function ak() external view override returns (uint256) {
        return bd.length;
    }


    function bq(address bx) external view override returns (bool) {
        return bi[bx];
    }
}