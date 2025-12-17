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
    IGaugeManager public override _0x66fc68;
    /// @inheritdoc ICLFactory
    address public immutable override _0xd5ab7d;
    /// @inheritdoc ICLFactory
    address public override _0x9fccd8;
    /// @inheritdoc ICLFactory
    address public override _0x23fb19;
    /// @inheritdoc ICLFactory
    address public override _0x85370d;
    /// @inheritdoc ICLFactory
    address public override _0xd02af4;
    /// @inheritdoc ICLFactory
    address public override _0xf27de2;
    /// @inheritdoc ICLFactory
    uint24 public override _0x05ce2a;
    /// @inheritdoc ICLFactory

    address public override _0x8ededc;
    /// @inheritdoc ICLFactory
    address public override _0xcd29dc;
    /// @inheritdoc ICLFactory
    uint24 public override _0x4251d1;

    mapping(int24 => uint24) public override _0xe2e0cc;
    /// @inheritdoc ICLFactory
    mapping(address => mapping(address => mapping(int24 => address))) public override _0x4ccfc4;
    /// @dev Used in VotingEscrow to determine if a contract is a valid pool
    mapping(address => bool) private _0x18fec2;
    /// @inheritdoc ICLFactory
    address[] public override _0x2081c6;

    int24[] private _0xd061ba;

    constructor(address _0x8bccba) {
        _0x9fccd8 = msg.sender;
        _0x23fb19 = msg.sender;
        _0xd02af4 = msg.sender;
        _0x8ededc = msg.sender;
        _0xd5ab7d = _0x8bccba;
        _0x05ce2a = 100_000;
        _0x4251d1 = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        _0xbea492(1, 100);
        _0xbea492(50, 500);
        _0xbea492(100, 500);
        _0xbea492(200, 3_000);
        _0xbea492(2_000, 10_000);
    }

    function _0xb885fe(address _0x16e05a) external {
        require(msg.sender == _0x9fccd8);
        _0x66fc68 = IGaugeManager(_0x16e05a);
    }

    /// @inheritdoc ICLFactory
    function _0xaeb813(address _0x6dcf3a, address _0xc0bce5, int24 _0x4b503c, uint160 _0x0fc75a)
        external
        override
        returns (address _0xfd2625)
    {
        require(_0x6dcf3a != _0xc0bce5);
        (address _0xae46c7, address _0xa0a8bb) = _0x6dcf3a < _0xc0bce5 ? (_0x6dcf3a, _0xc0bce5) : (_0xc0bce5, _0x6dcf3a);
        require(_0xae46c7 != address(0));
        require(_0xe2e0cc[_0x4b503c] != 0);
        require(_0x4ccfc4[_0xae46c7][_0xa0a8bb][_0x4b503c] == address(0));
        _0xfd2625 = Clones._0xe56a9d({
            _0xd0fd64: _0xd5ab7d,
            _0xa5becc: _0xc985f1(abi._0xc7d1c6(_0xae46c7, _0xa0a8bb, _0x4b503c))
        });
        CLPool(_0xfd2625)._0x3d86c8({
            _0xc7eddc: address(this),
            _0x44980e: _0xae46c7,
            _0xf0e9c6: _0xa0a8bb,
            _0x09f791: _0x4b503c,
            _0x16e05a: address(_0x66fc68),
            _0x4cd60a: _0x0fc75a
        });
        _0x2081c6.push(_0xfd2625);
        _0x18fec2[_0xfd2625] = true;
        _0x4ccfc4[_0xae46c7][_0xa0a8bb][_0x4b503c] = _0xfd2625;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        _0x4ccfc4[_0xa0a8bb][_0xae46c7][_0x4b503c] = _0xfd2625;
        emit PoolCreated(_0xae46c7, _0xa0a8bb, _0x4b503c, _0xfd2625);
    }

    /// @inheritdoc ICLFactory
    function _0xf286a1(address _0x17040a) external override {
        address _0x06d683 = _0x9fccd8;
        require(msg.sender == _0x06d683);
        require(_0x17040a != address(0));
        emit OwnerChanged(_0x06d683, _0x17040a);
        _0x9fccd8 = _0x17040a;
    }

    /// @inheritdoc ICLFactory
    function _0x8c5bd7(address _0x1bd889) external override {
        address _0x7b09e3 = _0x23fb19;
        require(msg.sender == _0x7b09e3);
        require(_0x1bd889 != address(0));
        _0x23fb19 = _0x1bd889;
        emit SwapFeeManagerChanged(_0x7b09e3, _0x1bd889);
    }

    /// @inheritdoc ICLFactory
    function _0xe74356(address _0xb17141) external override {
        address _0x913af2 = _0xd02af4;
        require(msg.sender == _0x913af2);
        require(_0xb17141 != address(0));
        _0xd02af4 = _0xb17141;
        emit UnstakedFeeManagerChanged(_0x913af2, _0xb17141);
    }

    /// @inheritdoc ICLFactory
    function _0x1f6126(address _0x2dc5c6) external override {
        require(msg.sender == _0x23fb19);
        require(_0x2dc5c6 != address(0));
        address _0x7a6b9c = _0x85370d;
        _0x85370d = _0x2dc5c6;
        emit SwapFeeModuleChanged(_0x7a6b9c, _0x2dc5c6);
    }

    /// @inheritdoc ICLFactory
    function _0xfb15e6(address _0x093d0e) external override {
        require(msg.sender == _0xd02af4);
        require(_0x093d0e != address(0));
        address _0x7a6b9c = _0xf27de2;
        _0xf27de2 = _0x093d0e;
        emit UnstakedFeeModuleChanged(_0x7a6b9c, _0x093d0e);
    }

    /// @inheritdoc ICLFactory
    function _0x1f955d(uint24 _0xccb817) external override {
        require(msg.sender == _0xd02af4);
        require(_0xccb817 <= 500_000);
        uint24 _0x42a12b = _0x05ce2a;
        _0x05ce2a = _0xccb817;
        emit DefaultUnstakedFeeChanged(_0x42a12b, _0xccb817);
    }

    function _0xa33716(address _0x737898) external override {
        require(msg.sender == _0x8ededc);
        require(_0x737898 != address(0));
        _0xcd29dc = _0x737898;
    }

    function _0xf98658(address _0xc7920a) external override {
        require(msg.sender == _0x8ededc);
        require(_0xc7920a != address(0));
        _0x8ededc = _0xc7920a;
    }

    /// @inheritdoc ICLFactory
    function _0xe55d73(address _0xfd2625) external view override returns (uint24) {
        if (_0x85370d != address(0)) {
            (bool _0xaef346, bytes memory data) = _0x85370d._0x9e2cf4(
                200_000, 32, abi._0x239d04(IFeeModule._0xcdbc17.selector, _0xfd2625)
            );
            if (_0xaef346) {
                uint24 _0xd4b4e9 = abi._0x3f0d86(data, (uint24));
                if (_0xd4b4e9 <= 100_000) {
                    return _0xd4b4e9;
                }
            }
        }
        return _0xe2e0cc[CLPool(_0xfd2625)._0x4b503c()];
    }

    /// @inheritdoc ICLFactory
    function _0x3a3ab8(address _0xfd2625) external view override returns (uint24) {

        if (!_0x66fc68._0xefa626(_0xfd2625)) {
            return 0;
        }
        if (_0xf27de2 != address(0)) {
            (bool _0xaef346, bytes memory data) = _0xf27de2._0x9e2cf4(
                200_000, 32, abi._0x239d04(IFeeModule._0xcdbc17.selector, _0xfd2625)
            );
            if (_0xaef346) {
                uint24 _0xd4b4e9 = abi._0x3f0d86(data, (uint24));
                if (_0xd4b4e9 <= 1_000_000) {
                    return _0xd4b4e9;
                }
            }
        }
        return _0x05ce2a;
    }

    function _0x7033e5(address _0xfd2625) external view override returns (uint24) {
        // if the gauge is alive, return 0, protocol fee is only for inactive gauges
        if (_0x66fc68._0xefa626(_0xfd2625)) {
            return 0;
        }

        if (_0xcd29dc != address(0)) {
            (bool _0xaef346, bytes memory data) = _0xcd29dc._0x9e2cf4(
                200_000, 32, abi._0x239d04(IFeeModule._0xcdbc17.selector, _0xfd2625)
            );
            if (_0xaef346) {
                uint24 _0xd4b4e9 = abi._0x3f0d86(data, (uint24));
                if (_0xd4b4e9 <= 500_000) {
                    return _0xd4b4e9;
                }
            }
        }
        return _0x4251d1;
    }

    /// @inheritdoc ICLFactory
    function _0xbea492(int24 _0x4b503c, uint24 _0xd4b4e9) public override {
        require(msg.sender == _0x9fccd8);
        require(_0xd4b4e9 > 0 && _0xd4b4e9 <= 100_000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that

        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(_0x4b503c > 0 && _0x4b503c < 16384);
        require(_0xe2e0cc[_0x4b503c] == 0);

        _0xe2e0cc[_0x4b503c] = _0xd4b4e9;
        _0xd061ba.push(_0x4b503c);
        emit TickSpacingEnabled(_0x4b503c, _0xd4b4e9);
    }

    function _0x5de042() external  {
        require(msg.sender == _0x9fccd8);

        for (uint256 i = 0; i < _0x2081c6.length; i++) {
            CLPool(_0x2081c6[i])._0x879b1c(msg.sender);
        }
    }

    function _0x879b1c(address _0xfd2625) external returns (uint128 _0x4541e4, uint128 _0x9e5078) {
        require(msg.sender == _0x9fccd8);
        (_0x4541e4, _0x9e5078) = CLPool(_0xfd2625)._0x879b1c(msg.sender);
    }

    /// @inheritdoc ICLFactory
    function _0x6dadcb() external view override returns (int24[] memory) {
        return _0xd061ba;
    }

    /// @inheritdoc ICLFactory
    function _0xae0f6d() external view override returns (uint256) {
        return _0x2081c6.length;
    }

    /// @inheritdoc ICLFactory
    function _0x3d7bab(address _0xfd2625) external view override returns (bool) {
        return _0x18fec2[_0xfd2625];
    }
}