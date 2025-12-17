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
    address public immutable _0xcd2abc;

    uint256 internal _0x2a4256;

    constructor(
        bool _0x1da32b,
        address _0x8078b2,
        address _0xc2547a,
        address _0x5db15b,
        uint256 _0x0ac698,
        uint32 _0xe1a132,
        address _0xcd8055,
        uint16 _0x9c6a35,
        uint16 _0x996877
    ) Locker(_0x1da32b, _0x8078b2, _0xc2547a, _0xe1a132, _0xcd8055, _0x9c6a35, _0x996877) {
        _0xcd2abc = _0x5db15b;
        _0x2a4256 = _0x0ac698;
        (_0x413649, _0x902baf) = IV2Pool(_0x907ee5)._0x3ed049();
    }

    /// @inheritdoc Locker
    function _0xac1b42(address _0xbacc01) external override(Locker, ILocker) _0xb9826f _0x8a690a returns (uint256) {
        if (msg.sender != _0xbddedd) revert NotFactory();

        delete _0x8fc5e5;
        delete _0x4aeb62;

        IERC20(_0x907ee5)._0x830903({_0x563d3a: _0xbacc01, value: _0x2a4256});

        /// @dev Refund locked balances
        uint256 _0x87336f = IERC20(_0x413649)._0x63c6fd({_0x37636f: address(this)});
        if (_0x87336f > 0) IERC20(_0x413649)._0x830903({_0x563d3a: _0xbacc01, value: _0x87336f});
        _0x87336f = IERC20(_0x902baf)._0x63c6fd({_0x37636f: address(this)});
        if (_0x87336f > 0) IERC20(_0x902baf)._0x830903({_0x563d3a: _0xbacc01, value: _0x87336f});

        emit Unlocked({_0x7786ea: _0xbacc01});
        return _0x2a4256;
    }

    /// @inheritdoc Locker
    function _0xbed625() external override(Locker, ILocker) _0x8a690a _0xe04a79 _0xb9826f _0xab2074 {
        if (_0x8fc5e5) revert AlreadyStaked();
        _0x8fc5e5 = true;

        _0xbd0bc7({_0xbacc01: _0x255db8()});

        IERC20(_0x907ee5)._0xdfdb8e({_0x600331: address(_0x02f7df), value: _0x2a4256});
        _0x02f7df._0x67ebcf({_0x490af9: _0x2a4256});
        emit Staked();
    }

    /// @inheritdoc Locker
    function _0x2b82ed(uint256 _0xdb617a, uint256 _0x25c229, uint256 _0xcbc981, uint256 _0x405e6d)
        external
        override(ILocker, Locker)
        _0x8a690a
        _0xe04a79
        _0xb9826f
        returns (uint256)
    {
        if (_0xdb617a == 0 && _0x25c229 == 0) revert ZeroAmount();

        uint256 _0x004003 = _0xaffd3e({_0x69a91b: _0x413649, _0x8375d6: _0xdb617a});
        uint256 _0x560c56 = _0xaffd3e({_0x69a91b: _0x902baf, _0x8375d6: _0x25c229});

        IERC20(_0x413649)._0x3d1475({_0x600331: _0xcd2abc, value: _0xdb617a});
        IERC20(_0x902baf)._0x3d1475({_0x600331: _0xcd2abc, value: _0x25c229});

        (uint256 _0x7249f8, uint256 _0x60e6d4, uint256 _0x809e78) = IV2Router(_0xcd2abc)._0xe7da00({
            _0xb1e815: _0x413649,
            _0xcb6089: _0x902baf,
            _0x6bde1b: IV2Pool(_0x907ee5)._0x6bde1b(),
            _0xe4dad8: _0xdb617a,
            _0xadd846: _0x25c229,
            _0x3548cc: _0xcbc981,
            _0xd8b93a: _0x405e6d,
            _0x563d3a: address(this),
            _0xf99c92: block.timestamp
        });

        IERC20(_0x413649)._0x3d1475({_0x600331: _0xcd2abc, value: 0});
        IERC20(_0x902baf)._0x3d1475({_0x600331: _0xcd2abc, value: 0});

        address _0x7786ea = _0x255db8();
        _0x982670({_0x69a91b: _0x413649, _0xbacc01: _0x7786ea, _0x136733: _0x004003});
        _0x982670({_0x69a91b: _0x902baf, _0xbacc01: _0x7786ea, _0x136733: _0x560c56});

        if (_0x8fc5e5) {
            IERC20(_0x907ee5)._0xdfdb8e({_0x600331: address(_0x02f7df), value: _0x809e78});
            _0x02f7df._0x67ebcf({_0x490af9: _0x809e78});
        }

        _0x2a4256 += _0x809e78;

        emit LiquidityIncreased({_0x74ae4c: _0x7249f8, _0x1c55c8: _0x60e6d4, _0x809e78: _0x809e78});
        return _0x809e78;
    }

    function _0xb32439() internal override returns (uint256 _0x1ef99b, uint256 _0x28359b) {
        (_0x1ef99b, _0x28359b) = IV2Pool(_0x907ee5)._0xf019af();

        uint256 _0x58430b = _0xd7d04d({_0x057c10: _0x1ef99b, _0x69a91b: _0x413649});
        uint256 _0x985d81 = _0xd7d04d({_0x057c10: _0x28359b, _0x69a91b: _0x902baf});
        _0x1ef99b -= _0x58430b;
        _0x28359b -= _0x985d81;

        if (_0x58430b > 0 || _0x985d81 > 0) {
            emit FeesClaimed({_0x7786ea: _0x4bd414, _0x1ef99b: _0x58430b, _0x28359b: _0x985d81});
        }
    }

    function _0xc2ca54() internal override returns (uint256 _0x8e7a4a) {
        uint256 _0xdf63b4 = IERC20(_0xb67e95)._0x63c6fd({_0x37636f: address(this)});
        _0x02f7df._0x9c8a93({_0x37636f: address(this)});
        uint256 _0x92bf9d = IERC20(_0xb67e95)._0x63c6fd({_0x37636f: address(this)});

        _0x8e7a4a = _0x92bf9d - _0xdf63b4;
        uint256 _0x4dcb58 = _0xd7d04d({_0x057c10: _0x8e7a4a, _0x69a91b: _0xb67e95});
        _0x8e7a4a -= _0x4dcb58;

        if (_0x4dcb58 > 0) {
            emit RewardsClaimed({_0x7786ea: _0x4bd414, _0x8e7a4a: _0x4dcb58});
        }
    }

    function _0x490af9() public view override(ILocker, Locker) returns (uint256) {
        return _0x2a4256;
    }
}