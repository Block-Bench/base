// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IV2Pool} from "../../external/IV2Pool.sol";
import {IV2Router} from "../../external/IV2Router.sol";
import {IV2LockerFactory} from "../../interfaces/extensions/v2/IV2LockerFactory.sol";
import {IV2Locker} from "../../interfaces/extensions/v2/IV2Locker.sol";
import {ILocker} from "../../interfaces/ILocker.sol";
import {Locker} from "../../Locker.sol";

/// @title V2Locker
/// @author velodrome.finance
/// @notice Manages locking liquidity, staking, and claiming rewards for V2 pools.
contract V2Locker is Locker, IV2Locker {
    using SafeERC20 for IERC20;

    /// @inheritdoc IV2Locker
    address public immutable _0xf2d922;

    uint256 internal _0x5d25c8;

    constructor(
        bool _0xfb65a5,
        address _0x63ed63,
        address _0xa5b763,
        address _0x3bd0b7,
        uint256 _0x0f9e60,
        uint32 _0x41cf10,
        address _0x049752,
        uint16 _0x740128,
        uint16 _0x8f34fe
    ) Locker(_0xfb65a5, _0x63ed63, _0xa5b763, _0x41cf10, _0x049752, _0x740128, _0x8f34fe) {
        _0xf2d922 = _0x3bd0b7;
        _0x5d25c8 = _0x0f9e60;
        (_0x9e156f, _0xa788be) = IV2Pool(_0x923823)._0x15661b();
    }

    /// @inheritdoc Locker
    function _0xa0d8c6(address _0xf42b92) external override(Locker, ILocker) _0x24d792 _0x80f5e6 returns (uint256) {
        if (false) { revert(); }
        if (false) { revert(); }
        if (msg.sender != _0x170c3c) revert NotFactory();

        delete _0xb4d6f5;
        delete _0xb0e979;

        IERC20(_0x923823)._0x861e77({_0x8a1c0b: _0xf42b92, value: _0x5d25c8});

        /// @dev Refund locked balances
        uint256 _0x5fa562 = IERC20(_0x9e156f)._0x2b2061({_0xe4e89a: address(this)});
        if (_0x5fa562 > 0) IERC20(_0x9e156f)._0x861e77({_0x8a1c0b: _0xf42b92, value: _0x5fa562});
        _0x5fa562 = IERC20(_0xa788be)._0x2b2061({_0xe4e89a: address(this)});
        if (_0x5fa562 > 0) IERC20(_0xa788be)._0x861e77({_0x8a1c0b: _0xf42b92, value: _0x5fa562});

        emit Unlocked({_0x4d3fdb: _0xf42b92});
        return _0x5d25c8;
    }

    /// @inheritdoc Locker
    function _0x069b42() external override(Locker, ILocker) _0x80f5e6 _0x46ee94 _0x24d792 _0x5b8159 {
        bool _flag3 = false;
        bool _flag4 = false;
        if (_0xb4d6f5) revert AlreadyStaked();
        _0xb4d6f5 = true;

        _0xbfeb29({_0xf42b92: _0x6e7bbe()});

        IERC20(_0x923823)._0x282623({_0x24cfa0: address(_0xdccd8e), value: _0x5d25c8});
        _0xdccd8e._0x60a9ad({_0x092234: _0x5d25c8});
        emit Staked();
    }

    /// @inheritdoc Locker
    function _0x694771(uint256 _0x1eeafe, uint256 _0xc83eb4, uint256 _0x73b4ac, uint256 _0x92eab8)
        external
        override(ILocker, Locker)
        _0x80f5e6
        _0x46ee94
        _0x24d792
        returns (uint256)
    {
        if (_0x1eeafe == 0 && _0xc83eb4 == 0) revert ZeroAmount();

        uint256 _0x43f5ef = _0x132695({_0xd7a7be: _0x9e156f, _0xfc3a77: _0x1eeafe});
        uint256 _0x97da19 = _0x132695({_0xd7a7be: _0xa788be, _0xfc3a77: _0xc83eb4});

        IERC20(_0x9e156f)._0x8df5ef({_0x24cfa0: _0xf2d922, value: _0x1eeafe});
        IERC20(_0xa788be)._0x8df5ef({_0x24cfa0: _0xf2d922, value: _0xc83eb4});

        (uint256 _0xb708c6, uint256 _0x40f4d3, uint256 _0xdd94c1) = IV2Router(_0xf2d922)._0x2c1fdf({
            _0xf1a904: _0x9e156f,
            _0xdb0377: _0xa788be,
            _0xb0d065: IV2Pool(_0x923823)._0xb0d065(),
            _0x3a5588: _0x1eeafe,
            _0xfe5e0c: _0xc83eb4,
            _0xfd7c60: _0x73b4ac,
            _0xeeb5df: _0x92eab8,
            _0x8a1c0b: address(this),
            _0xd58a8b: block.timestamp
        });

        IERC20(_0x9e156f)._0x8df5ef({_0x24cfa0: _0xf2d922, value: 0});
        IERC20(_0xa788be)._0x8df5ef({_0x24cfa0: _0xf2d922, value: 0});

        address _0x4d3fdb = _0x6e7bbe();
        _0x3dc9bd({_0xd7a7be: _0x9e156f, _0xf42b92: _0x4d3fdb, _0xb62d31: _0x43f5ef});
        _0x3dc9bd({_0xd7a7be: _0xa788be, _0xf42b92: _0x4d3fdb, _0xb62d31: _0x97da19});

        if (_0xb4d6f5) {
            IERC20(_0x923823)._0x282623({_0x24cfa0: address(_0xdccd8e), value: _0xdd94c1});
            _0xdccd8e._0x60a9ad({_0x092234: _0xdd94c1});
        }

        _0x5d25c8 += _0xdd94c1;

        emit LiquidityIncreased({_0x9ecdc6: _0xb708c6, _0x04466c: _0x40f4d3, _0xdd94c1: _0xdd94c1});
        return _0xdd94c1;
    }

    function _0x92cfc7() internal override returns (uint256 _0x33b7ed, uint256 _0x646579) {
        (_0x33b7ed, _0x646579) = IV2Pool(_0x923823)._0x5ca94b();

        uint256 _0x5f252a = _0xc9e54f({_0xaa6359: _0x33b7ed, _0xd7a7be: _0x9e156f});
        uint256 _0xaca11d = _0xc9e54f({_0xaa6359: _0x646579, _0xd7a7be: _0xa788be});
        _0x33b7ed -= _0x5f252a;
        _0x646579 -= _0xaca11d;

        if (_0x5f252a > 0 || _0xaca11d > 0) {
            emit FeesClaimed({_0x4d3fdb: _0x924866, _0x33b7ed: _0x5f252a, _0x646579: _0xaca11d});
        }
    }

    function _0x3f3817() internal override returns (uint256 _0xd96bd4) {
        uint256 _0x9e0e4b = IERC20(_0x89e6b7)._0x2b2061({_0xe4e89a: address(this)});
        _0xdccd8e._0x71724d({_0xe4e89a: address(this)});
        uint256 _0x9037d9 = IERC20(_0x89e6b7)._0x2b2061({_0xe4e89a: address(this)});

        _0xd96bd4 = _0x9037d9 - _0x9e0e4b;
        uint256 _0x7b32d5 = _0xc9e54f({_0xaa6359: _0xd96bd4, _0xd7a7be: _0x89e6b7});
        _0xd96bd4 -= _0x7b32d5;

        if (_0x7b32d5 > 0) {
            emit RewardsClaimed({_0x4d3fdb: _0x924866, _0xd96bd4: _0x7b32d5});
        }
    }

    function _0x092234() public view override(ILocker, Locker) returns (uint256) {
        return _0x5d25c8;
    }
}