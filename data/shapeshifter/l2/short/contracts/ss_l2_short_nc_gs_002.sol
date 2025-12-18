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


    IGaugeManager public override au;

    address public immutable override v;

    address public override bv;

    address public override ak;

    address public override an;

    address public override t;

    address public override ab;

    uint24 public override w;


    address public override s;

    address public override aa;

    uint24 public override u;

    mapping(int24 => uint24) public override ac;

    mapping(address => mapping(address => mapping(int24 => address))) public override bi;

    mapping(address => bool) private bg;

    address[] public override bc;

    int24[] private ao;

    constructor(address k) {
        bv = msg.sender;
        ak = msg.sender;
        t = msg.sender;
        s = msg.sender;
        v = k;
        w = 100_000;
        u = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        y(1, 100);
        y(50, 500);
        y(100, 500);
        y(200, 3_000);
        y(2_000, 10_000);
    }

    function af(address ap) external {
        require(msg.sender == bv);
        au = IGaugeManager(ap);
    }


    function ax(address br, address bm, int24 aw, uint160 at)
        external
        override
        returns (address bw)
    {
        require(br != bm);
        (address bo, address bu) = br < bm ? (br, bm) : (bm, br);
        require(bo != address(0));
        require(ac[aw] != 0);
        require(bi[bo][bu][aw] == address(0));
        bw = Clones.x({
            bs: v,
            bx: ba(abi.bp(bo, bu, aw))
        });
        CLPool(bw).az({
            bd: address(this),
            bh: bo,
            be: bu,
            ar: aw,
            ap: address(au),
            am: at
        });
        bc.push(bw);
        bg[bw] = true;
        bi[bo][bu][aw] = bw;

        bi[bu][bo][aw] = bw;
        emit PoolCreated(bo, bu, aw, bw);
    }


    function bb(address bl) external override {
        address av = bv;
        require(msg.sender == av);
        require(bl != address(0));
        emit OwnerChanged(av, bl);
        bv = bl;
    }


    function z(address ae) external override {
        address i = ak;
        require(msg.sender == i);
        require(ae != address(0));
        ak = ae;
        emit SwapFeeManagerChanged(i, ae);
    }


    function d(address o) external override {
        address b = t;
        require(msg.sender == b);
        require(o != address(0));
        t = o;
        emit UnstakedFeeManagerChanged(b, o);
    }


    function ad(address ag) external override {
        require(msg.sender == ak);
        require(ag != address(0));
        address aq = an;
        an = ag;
        emit SwapFeeModuleChanged(aq, ag);
    }


    function h(address p) external override {
        require(msg.sender == t);
        require(p != address(0));
        address aq = ab;
        ab = p;
        emit UnstakedFeeModuleChanged(aq, p);
    }


    function e(uint24 m) external override {
        require(msg.sender == t);
        require(m <= 500_000);
        uint24 aj = w;
        w = m;
        emit DefaultUnstakedFeeChanged(aj, m);
    }

    function g(address r) external override {
        require(msg.sender == s);
        require(r != address(0));
        aa = r;
    }

    function f(address j) external override {
        require(msg.sender == s);
        require(j != address(0));
        s = j;
    }


    function ay(address bw) external view override returns (uint24) {
        if (an != address(0)) {
            (bool bk, bytes memory data) = an.a(
                200_000, 32, abi.q(IFeeModule.bt.selector, bw)
            );
            if (bk) {
                uint24 by = abi.bn(data, (uint24));
                if (by <= 100_000) {
                    return by;
                }
            }
        }
        return ac[CLPool(bw).aw()];
    }


    function ah(address bw) external view override returns (uint24) {

        if (!au.l(bw)) {
            return 0;
        }
        if (ab != address(0)) {
            (bool bk, bytes memory data) = ab.a(
                200_000, 32, abi.q(IFeeModule.bt.selector, bw)
            );
            if (bk) {
                uint24 by = abi.bn(data, (uint24));
                if (by <= 1_000_000) {
                    return by;
                }
            }
        }
        return w;
    }

    function ai(address bw) external view override returns (uint24) {

        if (au.l(bw)) {
            return 0;
        }

        if (aa != address(0)) {
            (bool bk, bytes memory data) = aa.a(
                200_000, 32, abi.q(IFeeModule.bt.selector, bw)
            );
            if (bk) {
                uint24 by = abi.bn(data, (uint24));
                if (by <= 500_000) {
                    return by;
                }
            }
        }
        return u;
    }


    function y(int24 aw, uint24 by) public override {
        require(msg.sender == bv);
        require(by > 0 && by <= 100_000);


        require(aw > 0 && aw < 16384);
        require(ac[aw] == 0);

        ac[aw] = by;
        ao.push(aw);
        emit TickSpacingEnabled(aw, by);
    }

    function c() external  {
        require(msg.sender == bv);

        for (uint256 i = 0; i < bc.length; i++) {
            CLPool(bc[i]).n(msg.sender);
        }
    }

    function n(address bw) external returns (uint128 bj, uint128 bf) {
        require(msg.sender == bv);
        (bj, bf) = CLPool(bw).n(msg.sender);
    }


    function as() external view override returns (int24[] memory) {
        return ao;
    }


    function al() external view override returns (uint256) {
        return bc.length;
    }


    function bq(address bw) external view override returns (bool) {
        return bg[bw];
    }
}