// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./interfaces/ICLFactory.sol";
import "./interfaces/fees/IFeeModule.sol";

import "./interfaces/IGaugeManager.sol";
import "./interfaces/IFactoryRegistry.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@nomad-xyz/src/ExcessivelySafeCall.sol";
import "./CLPool.sol";

/// @title Canonical CL factory
/// @notice Deploys CL pools and manages ownership and control over pool protocol fees
contract CLFactory is ICLFactory {
    using ExcessivelySafeCall for address;

    /// @inheritdoc ICLFactory
    IGaugeManager public override as;
    /// @inheritdoc ICLFactory
    address public immutable override q;
    /// @inheritdoc ICLFactory
    address public override bv;
    /// @inheritdoc ICLFactory
    address public override ag;
    /// @inheritdoc ICLFactory
    address public override ao;
    /// @inheritdoc ICLFactory
    address public override r;
    /// @inheritdoc ICLFactory
    address public override z;
    /// @inheritdoc ICLFactory
    uint24 public override t;
    /// @inheritdoc ICLFactory

    address public override p;
    /// @inheritdoc ICLFactory
    address public override y;
    /// @inheritdoc ICLFactory
    uint24 public override u;

    mapping(int24 => uint24) public override ad;
    /// @inheritdoc ICLFactory
    mapping(address => mapping(address => mapping(int24 => address))) public override bf;
    /// @dev Used in VotingEscrow to determine if a contract is a valid pool
    mapping(address => bool) private bi;
    /// @inheritdoc ICLFactory
    address[] public override bb;

    int24[] private an;

    constructor(address m) {
        bv = msg.sender;
        ag = msg.sender;
        r = msg.sender;
        p = msg.sender;
        q = m;
        t = 100_000;
        u = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        ab(1, 100);
        ab(50, 500);
        ab(100, 500);
        ab(200, 3_000);
        ab(2_000, 10_000);
    }

    function ae(address am) external {
        require(msg.sender == bv);
        as = IGaugeManager(am);
    }

    /// @inheritdoc ICLFactory
    function az(address bo, address bu, int24 av, uint160 au)
        external
        override
        returns (address bx)
    {
        require(bo != bu);
        (address bp, address bm) = bo < bu ? (bo, bu) : (bu, bo);
        require(bp != address(0));
        require(ad[av] != 0);
        require(bf[bp][bm][av] == address(0));
        bx = Clones.w({
            bn: q,
            bw: ba(abi.bq(bp, bm, av))
        });
        CLPool(bx).ax({
            bd: address(this),
            bh: bp,
            bg: bm,
            at: av,
            am: address(as),
            ap: au
        });
        bb.push(bx);
        bi[bx] = true;
        bf[bp][bm][av] = bx;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        bf[bm][bp][av] = bx;
        emit PoolCreated(bp, bm, av, bx);
    }

    /// @inheritdoc ICLFactory
    function bc(address bs) external override {
        address aw = bv;
        require(msg.sender == aw);
        require(bs != address(0));
        emit OwnerChanged(aw, bs);
        bv = bs;
    }

    /// @inheritdoc ICLFactory
    function aa(address af) external override {
        address h = ag;
        require(msg.sender == h);
        require(af != address(0));
        ag = af;
        emit SwapFeeManagerChanged(h, af);
    }

    /// @inheritdoc ICLFactory
    function d(address o) external override {
        address b = r;
        require(msg.sender == b);
        require(o != address(0));
        r = o;
        emit UnstakedFeeManagerChanged(b, o);
    }

    /// @inheritdoc ICLFactory
    function ac(address al) external override {
        require(msg.sender == ag);
        require(al != address(0));
        address ar = ao;
        ao = al;
        emit SwapFeeModuleChanged(ar, al);
    }

    /// @inheritdoc ICLFactory
    function i(address s) external override {
        require(msg.sender == r);
        require(s != address(0));
        address ar = z;
        z = s;
        emit UnstakedFeeModuleChanged(ar, s);
    }

    /// @inheritdoc ICLFactory
    function e(uint24 n) external override {
        require(msg.sender == r);
        require(n <= 500_000);
        uint24 aj = t;
        t = n;
        emit DefaultUnstakedFeeChanged(aj, n);
    }

    function g(address x) external override {
        require(msg.sender == p);
        require(x != address(0));
        y = x;
    }

    function f(address l) external override {
        require(msg.sender == p);
        require(l != address(0));
        p = l;
    }

    /// @inheritdoc ICLFactory
    function ay(address bx) external view override returns (uint24) {
        if (ao != address(0)) {
            (bool bk, bytes memory data) = ao.a(
                200_000, 32, abi.v(IFeeModule.br.selector, bx)
            );
            if (bk) {
                uint24 by = abi.bt(data, (uint24));
                if (by <= 100_000) {
                    return by;
                }
            }
        }
        return ad[CLPool(bx).av()];
    }

    /// @inheritdoc ICLFactory
    function ai(address bx) external view override returns (uint24) {

        if (!as.j(bx)) {
            return 0;
        }
        if (z != address(0)) {
            (bool bk, bytes memory data) = z.a(
                200_000, 32, abi.v(IFeeModule.br.selector, bx)
            );
            if (bk) {
                uint24 by = abi.bt(data, (uint24));
                if (by <= 1_000_000) {
                    return by;
                }
            }
        }
        return t;
    }

    function ah(address bx) external view override returns (uint24) {
        // if the gauge is alive, return 0, protocol fee is only for inactive gauges
        if (as.j(bx)) {
            return 0;
        }

        if (y != address(0)) {
            (bool bk, bytes memory data) = y.a(
                200_000, 32, abi.v(IFeeModule.br.selector, bx)
            );
            if (bk) {
                uint24 by = abi.bt(data, (uint24));
                if (by <= 500_000) {
                    return by;
                }
            }
        }
        return u;
    }

    /// @inheritdoc ICLFactory
    function ab(int24 av, uint24 by) public override {
        require(msg.sender == bv);
        require(by > 0 && by <= 100_000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that

        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(av > 0 && av < 16384);
        require(ad[av] == 0);

        ad[av] = by;
        an.push(av);
        emit TickSpacingEnabled(av, by);
    }

    function c() external  {
        require(msg.sender == bv);

        for (uint256 i = 0; i < bb.length; i++) {
            CLPool(bb[i]).k(msg.sender);
        }
    }

    function k(address bx) external returns (uint128 bj, uint128 be) {
        require(msg.sender == bv);
        (bj, be) = CLPool(bx).k(msg.sender);
    }

    /// @inheritdoc ICLFactory
    function aq() external view override returns (int24[] memory) {
        return an;
    }

    /// @inheritdoc ICLFactory
    function ak() external view override returns (uint256) {
        return bb.length;
    }

    /// @inheritdoc ICLFactory
    function bl(address bx) external view override returns (bool) {
        return bi[bx];
    }
}