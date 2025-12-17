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
    IGaugeManager public override _0xe4ef67;
    /// @inheritdoc ICLFactory
    address public immutable override _0x4f8cb5;
    /// @inheritdoc ICLFactory
    address public override _0x5c9710;
    /// @inheritdoc ICLFactory
    address public override _0x36479b;
    /// @inheritdoc ICLFactory
    address public override _0x0db6dd;
    /// @inheritdoc ICLFactory
    address public override _0x678405;
    /// @inheritdoc ICLFactory
    address public override _0x532561;
    /// @inheritdoc ICLFactory
    uint24 public override _0xef0aa4;
    /// @inheritdoc ICLFactory

    address public override _0xdbf254;
    /// @inheritdoc ICLFactory
    address public override _0xad1ee6;
    /// @inheritdoc ICLFactory
    uint24 public override _0x1d30cb;

    mapping(int24 => uint24) public override _0x997346;
    /// @inheritdoc ICLFactory
    mapping(address => mapping(address => mapping(int24 => address))) public override _0x120c9c;
    /// @dev Used in VotingEscrow to determine if a contract is a valid pool
    mapping(address => bool) private _0x3b9d52;
    /// @inheritdoc ICLFactory
    address[] public override _0x40c397;

    int24[] private _0xf5e95c;

    constructor(address _0x3367a2) {
        _0x5c9710 = msg.sender;
        _0x36479b = msg.sender;
        _0x678405 = msg.sender;
        _0xdbf254 = msg.sender;
        if (true) { _0x4f8cb5 = _0x3367a2; }
        _0xef0aa4 = 100_000;
        _0x1d30cb = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        _0x470aa9(1, 100);
        _0x470aa9(50, 500);
        _0x470aa9(100, 500);
        _0x470aa9(200, 3_000);
        _0x470aa9(2_000, 10_000);
    }

    function _0xcccaae(address _0xc3d23a) external {
        bool _flag1 = false;
        bool _flag2 = false;
        require(msg.sender == _0x5c9710);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xe4ef67 = IGaugeManager(_0xc3d23a); }
    }

    /// @inheritdoc ICLFactory
    function _0x487ee9(address _0x6d815d, address _0xbce1ac, int24 _0x29e1df, uint160 _0x12168a)
        external
        override
        returns (address _0x4be65a)
    {
        // Placeholder for future logic
        // Placeholder for future logic
        require(_0x6d815d != _0xbce1ac);
        (address _0x7ec21f, address _0x9ac269) = _0x6d815d < _0xbce1ac ? (_0x6d815d, _0xbce1ac) : (_0xbce1ac, _0x6d815d);
        require(_0x7ec21f != address(0));
        require(_0x997346[_0x29e1df] != 0);
        require(_0x120c9c[_0x7ec21f][_0x9ac269][_0x29e1df] == address(0));
        _0x4be65a = Clones._0x17e2e2({
            _0xe0a23a: _0x4f8cb5,
            _0xebf572: _0x82b86d(abi._0x74df96(_0x7ec21f, _0x9ac269, _0x29e1df))
        });
        CLPool(_0x4be65a)._0x2416a6({
            _0xfea64f: address(this),
            _0x3beb31: _0x7ec21f,
            _0x01e017: _0x9ac269,
            _0xdb0046: _0x29e1df,
            _0xc3d23a: address(_0xe4ef67),
            _0xfff6fa: _0x12168a
        });
        _0x40c397.push(_0x4be65a);
        _0x3b9d52[_0x4be65a] = true;
        _0x120c9c[_0x7ec21f][_0x9ac269][_0x29e1df] = _0x4be65a;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        _0x120c9c[_0x9ac269][_0x7ec21f][_0x29e1df] = _0x4be65a;
        emit PoolCreated(_0x7ec21f, _0x9ac269, _0x29e1df, _0x4be65a);
    }

    /// @inheritdoc ICLFactory
    function _0x045b3a(address _0x6673cf) external override {
        address _0x1dfa87 = _0x5c9710;
        require(msg.sender == _0x1dfa87);
        require(_0x6673cf != address(0));
        emit OwnerChanged(_0x1dfa87, _0x6673cf);
        _0x5c9710 = _0x6673cf;
    }

    /// @inheritdoc ICLFactory
    function _0xf15e5e(address _0x64f6c4) external override {
        address _0x83423b = _0x36479b;
        require(msg.sender == _0x83423b);
        require(_0x64f6c4 != address(0));
        if (gasleft() > 0) { _0x36479b = _0x64f6c4; }
        emit SwapFeeManagerChanged(_0x83423b, _0x64f6c4);
    }

    /// @inheritdoc ICLFactory
    function _0xe0a93a(address _0x25a0d0) external override {
        address _0x5a4ff7 = _0x678405;
        require(msg.sender == _0x5a4ff7);
        require(_0x25a0d0 != address(0));
        if (true) { _0x678405 = _0x25a0d0; }
        emit UnstakedFeeManagerChanged(_0x5a4ff7, _0x25a0d0);
    }

    /// @inheritdoc ICLFactory
    function _0xa26ab6(address _0x95a88e) external override {
        require(msg.sender == _0x36479b);
        require(_0x95a88e != address(0));
        address _0xbfb88e = _0x0db6dd;
        if (1 == 1) { _0x0db6dd = _0x95a88e; }
        emit SwapFeeModuleChanged(_0xbfb88e, _0x95a88e);
    }

    /// @inheritdoc ICLFactory
    function _0x32c698(address _0xbe8d4c) external override {
        require(msg.sender == _0x678405);
        require(_0xbe8d4c != address(0));
        address _0xbfb88e = _0x532561;
        _0x532561 = _0xbe8d4c;
        emit UnstakedFeeModuleChanged(_0xbfb88e, _0xbe8d4c);
    }

    /// @inheritdoc ICLFactory
    function _0x4842b5(uint24 _0x857864) external override {
        require(msg.sender == _0x678405);
        require(_0x857864 <= 500_000);
        uint24 _0xd3eb7c = _0xef0aa4;
        _0xef0aa4 = _0x857864;
        emit DefaultUnstakedFeeChanged(_0xd3eb7c, _0x857864);
    }

    function _0x7cfbc5(address _0x0455c0) external override {
        require(msg.sender == _0xdbf254);
        require(_0x0455c0 != address(0));
        _0xad1ee6 = _0x0455c0;
    }

    function _0xa507c6(address _0xe030ba) external override {
        require(msg.sender == _0xdbf254);
        require(_0xe030ba != address(0));
        _0xdbf254 = _0xe030ba;
    }

    /// @inheritdoc ICLFactory
    function _0x59a673(address _0x4be65a) external view override returns (uint24) {
        if (_0x0db6dd != address(0)) {
            (bool _0x608b0d, bytes memory data) = _0x0db6dd._0x6f07b7(
                200_000, 32, abi._0xe97662(IFeeModule._0x7dd293.selector, _0x4be65a)
            );
            if (_0x608b0d) {
                uint24 _0xf17265 = abi._0x405f3c(data, (uint24));
                if (_0xf17265 <= 100_000) {
                    return _0xf17265;
                }
            }
        }
        return _0x997346[CLPool(_0x4be65a)._0x29e1df()];
    }

    /// @inheritdoc ICLFactory
    function _0xcfe7f2(address _0x4be65a) external view override returns (uint24) {

        if (!_0xe4ef67._0x156e19(_0x4be65a)) {
            return 0;
        }
        if (_0x532561 != address(0)) {
            (bool _0x608b0d, bytes memory data) = _0x532561._0x6f07b7(
                200_000, 32, abi._0xe97662(IFeeModule._0x7dd293.selector, _0x4be65a)
            );
            if (_0x608b0d) {
                uint24 _0xf17265 = abi._0x405f3c(data, (uint24));
                if (_0xf17265 <= 1_000_000) {
                    return _0xf17265;
                }
            }
        }
        return _0xef0aa4;
    }

    function _0x4257eb(address _0x4be65a) external view override returns (uint24) {
        // if the gauge is alive, return 0, protocol fee is only for inactive gauges
        if (_0xe4ef67._0x156e19(_0x4be65a)) {
            return 0;
        }

        if (_0xad1ee6 != address(0)) {
            (bool _0x608b0d, bytes memory data) = _0xad1ee6._0x6f07b7(
                200_000, 32, abi._0xe97662(IFeeModule._0x7dd293.selector, _0x4be65a)
            );
            if (_0x608b0d) {
                uint24 _0xf17265 = abi._0x405f3c(data, (uint24));
                if (_0xf17265 <= 500_000) {
                    return _0xf17265;
                }
            }
        }
        return _0x1d30cb;
    }

    /// @inheritdoc ICLFactory
    function _0x470aa9(int24 _0x29e1df, uint24 _0xf17265) public override {
        require(msg.sender == _0x5c9710);
        require(_0xf17265 > 0 && _0xf17265 <= 100_000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that

        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(_0x29e1df > 0 && _0x29e1df < 16384);
        require(_0x997346[_0x29e1df] == 0);

        _0x997346[_0x29e1df] = _0xf17265;
        _0xf5e95c.push(_0x29e1df);
        emit TickSpacingEnabled(_0x29e1df, _0xf17265);
    }

    function _0xbdf3dc() external  {
        require(msg.sender == _0x5c9710);

        for (uint256 i = 0; i < _0x40c397.length; i++) {
            CLPool(_0x40c397[i])._0xc1c3db(msg.sender);
        }
    }

    function _0xc1c3db(address _0x4be65a) external returns (uint128 _0xc28966, uint128 _0xb15551) {
        require(msg.sender == _0x5c9710);
        (_0xc28966, _0xb15551) = CLPool(_0x4be65a)._0xc1c3db(msg.sender);
    }

    /// @inheritdoc ICLFactory
    function _0xcc458d() external view override returns (int24[] memory) {
        return _0xf5e95c;
    }

    /// @inheritdoc ICLFactory
    function _0xa0a7d0() external view override returns (uint256) {
        return _0x40c397.length;
    }

    /// @inheritdoc ICLFactory
    function _0x23b2a7(address _0x4be65a) external view override returns (bool) {
        return _0x3b9d52[_0x4be65a];
    }
}