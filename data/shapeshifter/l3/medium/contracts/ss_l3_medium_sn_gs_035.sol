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
    address public immutable _0x13adc6;

    uint256 internal _0x0f5600;

    constructor(
        bool _0x7b201b,
        address _0x92edbb,
        address _0xd01545,
        address _0x266d28,
        uint256 _0x1260d2,
        uint32 _0x83f386,
        address _0xdb9362,
        uint16 _0x8bb118,
        uint16 _0xfd0f46
    ) Locker(_0x7b201b, _0x92edbb, _0xd01545, _0x83f386, _0xdb9362, _0x8bb118, _0xfd0f46) {
        _0x13adc6 = _0x266d28;
        _0x0f5600 = _0x1260d2;
        (_0x0bbb3d, _0x59bb54) = IV2Pool(_0x4fda1d)._0xc6faa7();
    }

    /// @inheritdoc Locker
    function _0xd49c2d(address _0x82efb0) external override(Locker, ILocker) _0x8f5ea5 _0xc4726c returns (uint256) {
        if (msg.sender != _0xe98364) revert NotFactory();

        delete _0xfc1fa6;
        delete _0x0fec15;

        IERC20(_0x4fda1d)._0x0b3fe9({_0xf99a12: _0x82efb0, value: _0x0f5600});

        /// @dev Refund locked balances
        uint256 _0xa4b23e = IERC20(_0x0bbb3d)._0xd58f7f({_0xb9f2ac: address(this)});
        if (_0xa4b23e > 0) IERC20(_0x0bbb3d)._0x0b3fe9({_0xf99a12: _0x82efb0, value: _0xa4b23e});
        _0xa4b23e = IERC20(_0x59bb54)._0xd58f7f({_0xb9f2ac: address(this)});
        if (_0xa4b23e > 0) IERC20(_0x59bb54)._0x0b3fe9({_0xf99a12: _0x82efb0, value: _0xa4b23e});

        emit Unlocked({_0x0ca4bd: _0x82efb0});
        return _0x0f5600;
    }

    /// @inheritdoc Locker
    function _0x96b824() external override(Locker, ILocker) _0xc4726c _0x68a3f9 _0x8f5ea5 _0x6ffd64 {
        if (_0xfc1fa6) revert AlreadyStaked();
        _0xfc1fa6 = true;

        _0x22a611({_0x82efb0: _0x0b8830()});

        IERC20(_0x4fda1d)._0xc0dcd5({_0x456ffe: address(_0x62051e), value: _0x0f5600});
        _0x62051e._0x66270d({_0xd880f8: _0x0f5600});
        emit Staked();
    }

    /// @inheritdoc Locker
    function _0xc3bb37(uint256 _0x787907, uint256 _0x5401f8, uint256 _0x912d32, uint256 _0x56c8cb)
        external
        override(ILocker, Locker)
        _0xc4726c
        _0x68a3f9
        _0x8f5ea5
        returns (uint256)
    {
        if (_0x787907 == 0 && _0x5401f8 == 0) revert ZeroAmount();

        uint256 _0x6d94a1 = _0x5d8fda({_0x730d4b: _0x0bbb3d, _0x88f420: _0x787907});
        uint256 _0x5c933b = _0x5d8fda({_0x730d4b: _0x59bb54, _0x88f420: _0x5401f8});

        IERC20(_0x0bbb3d)._0x644d1b({_0x456ffe: _0x13adc6, value: _0x787907});
        IERC20(_0x59bb54)._0x644d1b({_0x456ffe: _0x13adc6, value: _0x5401f8});

        (uint256 _0xa1f22a, uint256 _0xfcde73, uint256 _0x346b24) = IV2Router(_0x13adc6)._0x33bb93({
            _0xc5a315: _0x0bbb3d,
            _0xecb177: _0x59bb54,
            _0x2bd855: IV2Pool(_0x4fda1d)._0x2bd855(),
            _0x5aec30: _0x787907,
            _0xf7d6ca: _0x5401f8,
            _0x29b6a6: _0x912d32,
            _0xbc335c: _0x56c8cb,
            _0xf99a12: address(this),
            _0x5d0776: block.timestamp
        });

        IERC20(_0x0bbb3d)._0x644d1b({_0x456ffe: _0x13adc6, value: 0});
        IERC20(_0x59bb54)._0x644d1b({_0x456ffe: _0x13adc6, value: 0});

        address _0x0ca4bd = _0x0b8830();
        _0xd27ac4({_0x730d4b: _0x0bbb3d, _0x82efb0: _0x0ca4bd, _0x138abb: _0x6d94a1});
        _0xd27ac4({_0x730d4b: _0x59bb54, _0x82efb0: _0x0ca4bd, _0x138abb: _0x5c933b});

        if (_0xfc1fa6) {
            IERC20(_0x4fda1d)._0xc0dcd5({_0x456ffe: address(_0x62051e), value: _0x346b24});
            _0x62051e._0x66270d({_0xd880f8: _0x346b24});
        }

        _0x0f5600 += _0x346b24;

        emit LiquidityIncreased({_0x5a5453: _0xa1f22a, _0xa35c4c: _0xfcde73, _0x346b24: _0x346b24});
        return _0x346b24;
    }

    function _0x3cbdc9() internal override returns (uint256 _0x6b41aa, uint256 _0x82493a) {
        (_0x6b41aa, _0x82493a) = IV2Pool(_0x4fda1d)._0xefe78d();

        uint256 _0x891db6 = _0x3fbf38({_0x5640b2: _0x6b41aa, _0x730d4b: _0x0bbb3d});
        uint256 _0x3bfb63 = _0x3fbf38({_0x5640b2: _0x82493a, _0x730d4b: _0x59bb54});
        _0x6b41aa -= _0x891db6;
        _0x82493a -= _0x3bfb63;

        if (_0x891db6 > 0 || _0x3bfb63 > 0) {
            emit FeesClaimed({_0x0ca4bd: _0x935abd, _0x6b41aa: _0x891db6, _0x82493a: _0x3bfb63});
        }
    }

    function _0x1858ad() internal override returns (uint256 _0x479a4d) {
        uint256 _0xec2ce6 = IERC20(_0xa4cbb1)._0xd58f7f({_0xb9f2ac: address(this)});
        _0x62051e._0x3de3a3({_0xb9f2ac: address(this)});
        uint256 _0x3692a2 = IERC20(_0xa4cbb1)._0xd58f7f({_0xb9f2ac: address(this)});

        _0x479a4d = _0x3692a2 - _0xec2ce6;
        uint256 _0x1e598d = _0x3fbf38({_0x5640b2: _0x479a4d, _0x730d4b: _0xa4cbb1});
        _0x479a4d -= _0x1e598d;

        if (_0x1e598d > 0) {
            emit RewardsClaimed({_0x0ca4bd: _0x935abd, _0x479a4d: _0x1e598d});
        }
    }

    function _0xd880f8() public view override(ILocker, Locker) returns (uint256) {
        return _0x0f5600;
    }
}