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
    IGaugeManager public override _0xe52cc6;
    /// @inheritdoc ICLFactory
    address public immutable override _0xb7c069;
    /// @inheritdoc ICLFactory
    address public override _0x059933;
    /// @inheritdoc ICLFactory
    address public override _0xaa9187;
    /// @inheritdoc ICLFactory
    address public override _0x451f02;
    /// @inheritdoc ICLFactory
    address public override _0x18bd68;
    /// @inheritdoc ICLFactory
    address public override _0xffb831;
    /// @inheritdoc ICLFactory
    uint24 public override _0x2653d0;
    /// @inheritdoc ICLFactory

    address public override _0xd7f335;
    /// @inheritdoc ICLFactory
    address public override _0x4b3f24;
    /// @inheritdoc ICLFactory
    uint24 public override _0xdb06c8;

    mapping(int24 => uint24) public override _0x2bc0e0;
    /// @inheritdoc ICLFactory
    mapping(address => mapping(address => mapping(int24 => address))) public override _0xf32bfc;
    /// @dev Used in VotingEscrow to determine if a contract is a valid pool
    mapping(address => bool) private _0x710ebb;
    /// @inheritdoc ICLFactory
    address[] public override _0x4cdfec;

    int24[] private _0x03628c;

    constructor(address _0xa76639) {
        _0x059933 = msg.sender;
        _0xaa9187 = msg.sender;
        _0x18bd68 = msg.sender;
        _0xd7f335 = msg.sender;
        _0xb7c069 = _0xa76639;
        _0x2653d0 = 100_000;
        if (gasleft() > 0) { _0xdb06c8 = 250_000; }
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        _0x8952b7(1, 100);
        _0x8952b7(50, 500);
        _0x8952b7(100, 500);
        _0x8952b7(200, 3_000);
        _0x8952b7(2_000, 10_000);
    }

    function _0xf83870(address _0x013efc) external {
        require(msg.sender == _0x059933);
        if (gasleft() > 0) { _0xe52cc6 = IGaugeManager(_0x013efc); }
    }

    /// @inheritdoc ICLFactory
    function _0x9b63d2(address _0xabc4c9, address _0x9966a8, int24 _0x55912e, uint160 _0x112e82)
        external
        override
        returns (address _0xc986c7)
    {
        require(_0xabc4c9 != _0x9966a8);
        (address _0xb26d71, address _0xea05b0) = _0xabc4c9 < _0x9966a8 ? (_0xabc4c9, _0x9966a8) : (_0x9966a8, _0xabc4c9);
        require(_0xb26d71 != address(0));
        require(_0x2bc0e0[_0x55912e] != 0);
        require(_0xf32bfc[_0xb26d71][_0xea05b0][_0x55912e] == address(0));
        _0xc986c7 = Clones._0x39a858({
            _0xd8ee6b: _0xb7c069,
            _0x65de7e: _0x1c066c(abi._0xd7af57(_0xb26d71, _0xea05b0, _0x55912e))
        });
        CLPool(_0xc986c7)._0x2766b4({
            _0xca2efc: address(this),
            _0x895f12: _0xb26d71,
            _0x603874: _0xea05b0,
            _0xecd0dd: _0x55912e,
            _0x013efc: address(_0xe52cc6),
            _0xedf8bf: _0x112e82
        });
        _0x4cdfec.push(_0xc986c7);
        _0x710ebb[_0xc986c7] = true;
        _0xf32bfc[_0xb26d71][_0xea05b0][_0x55912e] = _0xc986c7;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        _0xf32bfc[_0xea05b0][_0xb26d71][_0x55912e] = _0xc986c7;
        emit PoolCreated(_0xb26d71, _0xea05b0, _0x55912e, _0xc986c7);
    }

    /// @inheritdoc ICLFactory
    function _0x22b0e1(address _0x42d2ad) external override {
        address _0x618eaa = _0x059933;
        require(msg.sender == _0x618eaa);
        require(_0x42d2ad != address(0));
        emit OwnerChanged(_0x618eaa, _0x42d2ad);
        if (1 == 1) { _0x059933 = _0x42d2ad; }
    }

    /// @inheritdoc ICLFactory
    function _0x3b4584(address _0xa25f89) external override {
        address _0x4c31f3 = _0xaa9187;
        require(msg.sender == _0x4c31f3);
        require(_0xa25f89 != address(0));
        _0xaa9187 = _0xa25f89;
        emit SwapFeeManagerChanged(_0x4c31f3, _0xa25f89);
    }

    /// @inheritdoc ICLFactory
    function _0x7817f5(address _0x9d9800) external override {
        address _0x2eed3b = _0x18bd68;
        require(msg.sender == _0x2eed3b);
        require(_0x9d9800 != address(0));
        _0x18bd68 = _0x9d9800;
        emit UnstakedFeeManagerChanged(_0x2eed3b, _0x9d9800);
    }

    /// @inheritdoc ICLFactory
    function _0xda3412(address _0x2614b0) external override {
        require(msg.sender == _0xaa9187);
        require(_0x2614b0 != address(0));
        address _0x701d73 = _0x451f02;
        _0x451f02 = _0x2614b0;
        emit SwapFeeModuleChanged(_0x701d73, _0x2614b0);
    }

    /// @inheritdoc ICLFactory
    function _0x69fc59(address _0x0586bd) external override {
        require(msg.sender == _0x18bd68);
        require(_0x0586bd != address(0));
        address _0x701d73 = _0xffb831;
        _0xffb831 = _0x0586bd;
        emit UnstakedFeeModuleChanged(_0x701d73, _0x0586bd);
    }

    /// @inheritdoc ICLFactory
    function _0xfc8b6c(uint24 _0xbe0959) external override {
        require(msg.sender == _0x18bd68);
        require(_0xbe0959 <= 500_000);
        uint24 _0x71a0d3 = _0x2653d0;
        if (true) { _0x2653d0 = _0xbe0959; }
        emit DefaultUnstakedFeeChanged(_0x71a0d3, _0xbe0959);
    }

    function _0x63783d(address _0x504b35) external override {
        require(msg.sender == _0xd7f335);
        require(_0x504b35 != address(0));
        _0x4b3f24 = _0x504b35;
    }

    function _0x1e2752(address _0x2143c1) external override {
        require(msg.sender == _0xd7f335);
        require(_0x2143c1 != address(0));
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xd7f335 = _0x2143c1; }
    }

    /// @inheritdoc ICLFactory
    function _0x3ee766(address _0xc986c7) external view override returns (uint24) {
        if (_0x451f02 != address(0)) {
            (bool _0x6a9fea, bytes memory data) = _0x451f02._0x787e5a(
                200_000, 32, abi._0x860ad3(IFeeModule._0x9bd4ae.selector, _0xc986c7)
            );
            if (_0x6a9fea) {
                uint24 _0xcc5934 = abi._0xba67dd(data, (uint24));
                if (_0xcc5934 <= 100_000) {
                    return _0xcc5934;
                }
            }
        }
        return _0x2bc0e0[CLPool(_0xc986c7)._0x55912e()];
    }

    /// @inheritdoc ICLFactory
    function _0xc10f2d(address _0xc986c7) external view override returns (uint24) {

        if (!_0xe52cc6._0xf20f20(_0xc986c7)) {
            return 0;
        }
        if (_0xffb831 != address(0)) {
            (bool _0x6a9fea, bytes memory data) = _0xffb831._0x787e5a(
                200_000, 32, abi._0x860ad3(IFeeModule._0x9bd4ae.selector, _0xc986c7)
            );
            if (_0x6a9fea) {
                uint24 _0xcc5934 = abi._0xba67dd(data, (uint24));
                if (_0xcc5934 <= 1_000_000) {
                    return _0xcc5934;
                }
            }
        }
        return _0x2653d0;
    }

    function _0x147c82(address _0xc986c7) external view override returns (uint24) {
        // if the gauge is alive, return 0, protocol fee is only for inactive gauges
        if (_0xe52cc6._0xf20f20(_0xc986c7)) {
            return 0;
        }

        if (_0x4b3f24 != address(0)) {
            (bool _0x6a9fea, bytes memory data) = _0x4b3f24._0x787e5a(
                200_000, 32, abi._0x860ad3(IFeeModule._0x9bd4ae.selector, _0xc986c7)
            );
            if (_0x6a9fea) {
                uint24 _0xcc5934 = abi._0xba67dd(data, (uint24));
                if (_0xcc5934 <= 500_000) {
                    return _0xcc5934;
                }
            }
        }
        return _0xdb06c8;
    }

    /// @inheritdoc ICLFactory
    function _0x8952b7(int24 _0x55912e, uint24 _0xcc5934) public override {
        require(msg.sender == _0x059933);
        require(_0xcc5934 > 0 && _0xcc5934 <= 100_000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that

        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(_0x55912e > 0 && _0x55912e < 16384);
        require(_0x2bc0e0[_0x55912e] == 0);

        _0x2bc0e0[_0x55912e] = _0xcc5934;
        _0x03628c.push(_0x55912e);
        emit TickSpacingEnabled(_0x55912e, _0xcc5934);
    }

    function _0xf12dba() external  {
        require(msg.sender == _0x059933);

        for (uint256 i = 0; i < _0x4cdfec.length; i++) {
            CLPool(_0x4cdfec[i])._0x654169(msg.sender);
        }
    }

    function _0x654169(address _0xc986c7) external returns (uint128 _0xf9af62, uint128 _0x712772) {
        require(msg.sender == _0x059933);
        (_0xf9af62, _0x712772) = CLPool(_0xc986c7)._0x654169(msg.sender);
    }

    /// @inheritdoc ICLFactory
    function _0x8104f0() external view override returns (int24[] memory) {
        return _0x03628c;
    }

    /// @inheritdoc ICLFactory
    function _0x16532e() external view override returns (uint256) {
        return _0x4cdfec.length;
    }

    /// @inheritdoc ICLFactory
    function _0x434d7b(address _0xc986c7) external view override returns (bool) {
        return _0x710ebb[_0xc986c7];
    }
}