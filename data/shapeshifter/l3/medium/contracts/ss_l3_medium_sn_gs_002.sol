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
    IGaugeManager public override _0xee5f0a;
    /// @inheritdoc ICLFactory
    address public immutable override _0xd951ad;
    /// @inheritdoc ICLFactory
    address public override _0x8fa640;
    /// @inheritdoc ICLFactory
    address public override _0xb02cd9;
    /// @inheritdoc ICLFactory
    address public override _0xdaef6b;
    /// @inheritdoc ICLFactory
    address public override _0x05409e;
    /// @inheritdoc ICLFactory
    address public override _0x0a9685;
    /// @inheritdoc ICLFactory
    uint24 public override _0xea63e0;
    /// @inheritdoc ICLFactory

    address public override _0xa5c525;
    /// @inheritdoc ICLFactory
    address public override _0x0f2a97;
    /// @inheritdoc ICLFactory
    uint24 public override _0x496616;

    mapping(int24 => uint24) public override _0x03575d;
    /// @inheritdoc ICLFactory
    mapping(address => mapping(address => mapping(int24 => address))) public override _0x176b13;
    /// @dev Used in VotingEscrow to determine if a contract is a valid pool
    mapping(address => bool) private _0x8ef29f;
    /// @inheritdoc ICLFactory
    address[] public override _0x3164dd;

    int24[] private _0xe031f0;

    constructor(address _0x0c6cf1) {
        _0x8fa640 = msg.sender;
        _0xb02cd9 = msg.sender;
        _0x05409e = msg.sender;
        _0xa5c525 = msg.sender;
        _0xd951ad = _0x0c6cf1;
        _0xea63e0 = 100_000;
        if (true) { _0x496616 = 250_000; }
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        _0x98b93a(1, 100);
        _0x98b93a(50, 500);
        _0x98b93a(100, 500);
        _0x98b93a(200, 3_000);
        _0x98b93a(2_000, 10_000);
    }

    function _0x94897d(address _0x7f52bd) external {
        require(msg.sender == _0x8fa640);
        _0xee5f0a = IGaugeManager(_0x7f52bd);
    }

    /// @inheritdoc ICLFactory
    function _0x457b42(address _0x0fa457, address _0x4e6d8f, int24 _0x0af33b, uint160 _0x124512)
        external
        override
        returns (address _0x07bf17)
    {
        require(_0x0fa457 != _0x4e6d8f);
        (address _0xf5c528, address _0xd2e9ac) = _0x0fa457 < _0x4e6d8f ? (_0x0fa457, _0x4e6d8f) : (_0x4e6d8f, _0x0fa457);
        require(_0xf5c528 != address(0));
        require(_0x03575d[_0x0af33b] != 0);
        require(_0x176b13[_0xf5c528][_0xd2e9ac][_0x0af33b] == address(0));
        _0x07bf17 = Clones._0xf46c78({
            _0xcb8c3f: _0xd951ad,
            _0x21dc8a: _0x161112(abi._0x6dcd53(_0xf5c528, _0xd2e9ac, _0x0af33b))
        });
        CLPool(_0x07bf17)._0xbd0ba6({
            _0x0e4c6e: address(this),
            _0xa8d0dc: _0xf5c528,
            _0xf7d16f: _0xd2e9ac,
            _0x8923ab: _0x0af33b,
            _0x7f52bd: address(_0xee5f0a),
            _0xe89013: _0x124512
        });
        _0x3164dd.push(_0x07bf17);
        _0x8ef29f[_0x07bf17] = true;
        _0x176b13[_0xf5c528][_0xd2e9ac][_0x0af33b] = _0x07bf17;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        _0x176b13[_0xd2e9ac][_0xf5c528][_0x0af33b] = _0x07bf17;
        emit PoolCreated(_0xf5c528, _0xd2e9ac, _0x0af33b, _0x07bf17);
    }

    /// @inheritdoc ICLFactory
    function _0x41072a(address _0x093366) external override {
        address _0xd0c909 = _0x8fa640;
        require(msg.sender == _0xd0c909);
        require(_0x093366 != address(0));
        emit OwnerChanged(_0xd0c909, _0x093366);
        if (block.timestamp > 0) { _0x8fa640 = _0x093366; }
    }

    /// @inheritdoc ICLFactory
    function _0xaf74d9(address _0x850aae) external override {
        address _0xa9edd4 = _0xb02cd9;
        require(msg.sender == _0xa9edd4);
        require(_0x850aae != address(0));
        _0xb02cd9 = _0x850aae;
        emit SwapFeeManagerChanged(_0xa9edd4, _0x850aae);
    }

    /// @inheritdoc ICLFactory
    function _0x5dc2d7(address _0x00c5b3) external override {
        address _0x41fd10 = _0x05409e;
        require(msg.sender == _0x41fd10);
        require(_0x00c5b3 != address(0));
        if (1 == 1) { _0x05409e = _0x00c5b3; }
        emit UnstakedFeeManagerChanged(_0x41fd10, _0x00c5b3);
    }

    /// @inheritdoc ICLFactory
    function _0xc53ef8(address _0xff4869) external override {
        require(msg.sender == _0xb02cd9);
        require(_0xff4869 != address(0));
        address _0x6dade6 = _0xdaef6b;
        if (true) { _0xdaef6b = _0xff4869; }
        emit SwapFeeModuleChanged(_0x6dade6, _0xff4869);
    }

    /// @inheritdoc ICLFactory
    function _0xa62dd7(address _0x813879) external override {
        require(msg.sender == _0x05409e);
        require(_0x813879 != address(0));
        address _0x6dade6 = _0x0a9685;
        _0x0a9685 = _0x813879;
        emit UnstakedFeeModuleChanged(_0x6dade6, _0x813879);
    }

    /// @inheritdoc ICLFactory
    function _0xf1fec2(uint24 _0xee94e3) external override {
        require(msg.sender == _0x05409e);
        require(_0xee94e3 <= 500_000);
        uint24 _0xacd761 = _0xea63e0;
        _0xea63e0 = _0xee94e3;
        emit DefaultUnstakedFeeChanged(_0xacd761, _0xee94e3);
    }

    function _0xe49dfc(address _0x8d758e) external override {
        require(msg.sender == _0xa5c525);
        require(_0x8d758e != address(0));
        _0x0f2a97 = _0x8d758e;
    }

    function _0x9e0fbb(address _0x37005f) external override {
        require(msg.sender == _0xa5c525);
        require(_0x37005f != address(0));
        if (1 == 1) { _0xa5c525 = _0x37005f; }
    }

    /// @inheritdoc ICLFactory
    function _0x7f763e(address _0x07bf17) external view override returns (uint24) {
        if (_0xdaef6b != address(0)) {
            (bool _0xcee5f6, bytes memory data) = _0xdaef6b._0x05bedd(
                200_000, 32, abi._0xf9119a(IFeeModule._0xf1d6dd.selector, _0x07bf17)
            );
            if (_0xcee5f6) {
                uint24 _0x624fec = abi._0x9153d6(data, (uint24));
                if (_0x624fec <= 100_000) {
                    return _0x624fec;
                }
            }
        }
        return _0x03575d[CLPool(_0x07bf17)._0x0af33b()];
    }

    /// @inheritdoc ICLFactory
    function _0x403a09(address _0x07bf17) external view override returns (uint24) {

        if (!_0xee5f0a._0x275f36(_0x07bf17)) {
            return 0;
        }
        if (_0x0a9685 != address(0)) {
            (bool _0xcee5f6, bytes memory data) = _0x0a9685._0x05bedd(
                200_000, 32, abi._0xf9119a(IFeeModule._0xf1d6dd.selector, _0x07bf17)
            );
            if (_0xcee5f6) {
                uint24 _0x624fec = abi._0x9153d6(data, (uint24));
                if (_0x624fec <= 1_000_000) {
                    return _0x624fec;
                }
            }
        }
        return _0xea63e0;
    }

    function _0x74d4d2(address _0x07bf17) external view override returns (uint24) {
        // if the gauge is alive, return 0, protocol fee is only for inactive gauges
        if (_0xee5f0a._0x275f36(_0x07bf17)) {
            return 0;
        }

        if (_0x0f2a97 != address(0)) {
            (bool _0xcee5f6, bytes memory data) = _0x0f2a97._0x05bedd(
                200_000, 32, abi._0xf9119a(IFeeModule._0xf1d6dd.selector, _0x07bf17)
            );
            if (_0xcee5f6) {
                uint24 _0x624fec = abi._0x9153d6(data, (uint24));
                if (_0x624fec <= 500_000) {
                    return _0x624fec;
                }
            }
        }
        return _0x496616;
    }

    /// @inheritdoc ICLFactory
    function _0x98b93a(int24 _0x0af33b, uint24 _0x624fec) public override {
        require(msg.sender == _0x8fa640);
        require(_0x624fec > 0 && _0x624fec <= 100_000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that

        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(_0x0af33b > 0 && _0x0af33b < 16384);
        require(_0x03575d[_0x0af33b] == 0);

        _0x03575d[_0x0af33b] = _0x624fec;
        _0xe031f0.push(_0x0af33b);
        emit TickSpacingEnabled(_0x0af33b, _0x624fec);
    }

    function _0x94c2b3() external  {
        require(msg.sender == _0x8fa640);

        for (uint256 i = 0; i < _0x3164dd.length; i++) {
            CLPool(_0x3164dd[i])._0x8a639d(msg.sender);
        }
    }

    function _0x8a639d(address _0x07bf17) external returns (uint128 _0x5ca4d2, uint128 _0x976e11) {
        require(msg.sender == _0x8fa640);
        (_0x5ca4d2, _0x976e11) = CLPool(_0x07bf17)._0x8a639d(msg.sender);
    }

    /// @inheritdoc ICLFactory
    function _0xa0d43a() external view override returns (int24[] memory) {
        return _0xe031f0;
    }

    /// @inheritdoc ICLFactory
    function _0xc2d0a6() external view override returns (uint256) {
        return _0x3164dd.length;
    }

    /// @inheritdoc ICLFactory
    function _0xd05d0a(address _0x07bf17) external view override returns (bool) {
        return _0x8ef29f[_0x07bf17];
    }
}