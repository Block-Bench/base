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
    address public immutable _0x8059be;

    uint256 internal _0xe6f629;

    constructor(
        bool _0xfdcf57,
        address _0x9df8af,
        address _0xb8dcd0,
        address _0x08842c,
        uint256 _0x78055a,
        uint32 _0xc0991d,
        address _0x4fbeab,
        uint16 _0xf5a051,
        uint16 _0x418972
    ) Locker(_0xfdcf57, _0x9df8af, _0xb8dcd0, _0xc0991d, _0x4fbeab, _0xf5a051, _0x418972) {
        _0x8059be = _0x08842c;
        _0xe6f629 = _0x78055a;
        (_0xb6e158, _0xa5ee45) = IV2Pool(_0xb0561e)._0x6c4ff4();
    }

    /// @inheritdoc Locker
    function _0x5aa38d(address _0x375c96) external override(Locker, ILocker) _0xe8fb1c _0x942d69 returns (uint256) {
        if (msg.sender != _0x8bc67b) revert NotFactory();

        delete _0x35ccf8;
        delete _0xcb5630;

        IERC20(_0xb0561e)._0x7c6a72({_0x7c4b9b: _0x375c96, value: _0xe6f629});

        /// @dev Refund locked balances
        uint256 _0x72ea2b = IERC20(_0xb6e158)._0xb2904e({_0xe65317: address(this)});
        if (_0x72ea2b > 0) IERC20(_0xb6e158)._0x7c6a72({_0x7c4b9b: _0x375c96, value: _0x72ea2b});
        _0x72ea2b = IERC20(_0xa5ee45)._0xb2904e({_0xe65317: address(this)});
        if (_0x72ea2b > 0) IERC20(_0xa5ee45)._0x7c6a72({_0x7c4b9b: _0x375c96, value: _0x72ea2b});

        emit Unlocked({_0xcb4542: _0x375c96});
        return _0xe6f629;
    }

    /// @inheritdoc Locker
    function _0xe4ffb5() external override(Locker, ILocker) _0x942d69 _0xf460cc _0xe8fb1c _0x29f63a {
        if (_0x35ccf8) revert AlreadyStaked();
        _0x35ccf8 = true;

        _0x4b70c2({_0x375c96: _0x76d8e4()});

        IERC20(_0xb0561e)._0xc9d31d({_0x70bb32: address(_0x198508), value: _0xe6f629});
        _0x198508._0x6d957f({_0xb9030c: _0xe6f629});
        emit Staked();
    }

    /// @inheritdoc Locker
    function _0x0cf01f(uint256 _0xdcc873, uint256 _0x351b17, uint256 _0x954e43, uint256 _0xda44c0)
        external
        override(ILocker, Locker)
        _0x942d69
        _0xf460cc
        _0xe8fb1c
        returns (uint256)
    {
        if (_0xdcc873 == 0 && _0x351b17 == 0) revert ZeroAmount();

        uint256 _0x95fd03 = _0x89cdbd({_0xa1a3b9: _0xb6e158, _0x8d5f46: _0xdcc873});
        uint256 _0x131e67 = _0x89cdbd({_0xa1a3b9: _0xa5ee45, _0x8d5f46: _0x351b17});

        IERC20(_0xb6e158)._0xa8a792({_0x70bb32: _0x8059be, value: _0xdcc873});
        IERC20(_0xa5ee45)._0xa8a792({_0x70bb32: _0x8059be, value: _0x351b17});

        (uint256 _0x448d64, uint256 _0x4f2793, uint256 _0x0cca21) = IV2Router(_0x8059be)._0x06d524({
            _0xfd0650: _0xb6e158,
            _0x422b4a: _0xa5ee45,
            _0xcab807: IV2Pool(_0xb0561e)._0xcab807(),
            _0xecacdb: _0xdcc873,
            _0x76f8f7: _0x351b17,
            _0x33f42b: _0x954e43,
            _0x5804c8: _0xda44c0,
            _0x7c4b9b: address(this),
            _0x83731b: block.timestamp
        });

        IERC20(_0xb6e158)._0xa8a792({_0x70bb32: _0x8059be, value: 0});
        IERC20(_0xa5ee45)._0xa8a792({_0x70bb32: _0x8059be, value: 0});

        address _0xcb4542 = _0x76d8e4();
        _0x9deb94({_0xa1a3b9: _0xb6e158, _0x375c96: _0xcb4542, _0x0f15bc: _0x95fd03});
        _0x9deb94({_0xa1a3b9: _0xa5ee45, _0x375c96: _0xcb4542, _0x0f15bc: _0x131e67});

        if (_0x35ccf8) {
            IERC20(_0xb0561e)._0xc9d31d({_0x70bb32: address(_0x198508), value: _0x0cca21});
            _0x198508._0x6d957f({_0xb9030c: _0x0cca21});
        }

        _0xe6f629 += _0x0cca21;

        emit LiquidityIncreased({_0x3cba66: _0x448d64, _0x60f228: _0x4f2793, _0x0cca21: _0x0cca21});
        return _0x0cca21;
    }

    function _0xc49f2b() internal override returns (uint256 _0x9f535b, uint256 _0x491141) {
        (_0x9f535b, _0x491141) = IV2Pool(_0xb0561e)._0x1b429d();

        uint256 _0x8a7636 = _0xf3c575({_0x1c0651: _0x9f535b, _0xa1a3b9: _0xb6e158});
        uint256 _0x946582 = _0xf3c575({_0x1c0651: _0x491141, _0xa1a3b9: _0xa5ee45});
        _0x9f535b -= _0x8a7636;
        _0x491141 -= _0x946582;

        if (_0x8a7636 > 0 || _0x946582 > 0) {
            emit FeesClaimed({_0xcb4542: _0x73faa9, _0x9f535b: _0x8a7636, _0x491141: _0x946582});
        }
    }

    function _0x593168() internal override returns (uint256 _0x57a0cb) {
        uint256 _0x0d8fcf = IERC20(_0x9962a9)._0xb2904e({_0xe65317: address(this)});
        _0x198508._0x2af2d0({_0xe65317: address(this)});
        uint256 _0xc72224 = IERC20(_0x9962a9)._0xb2904e({_0xe65317: address(this)});

        _0x57a0cb = _0xc72224 - _0x0d8fcf;
        uint256 _0x311fc2 = _0xf3c575({_0x1c0651: _0x57a0cb, _0xa1a3b9: _0x9962a9});
        _0x57a0cb -= _0x311fc2;

        if (_0x311fc2 > 0) {
            emit RewardsClaimed({_0xcb4542: _0x73faa9, _0x57a0cb: _0x311fc2});
        }
    }

    function _0xb9030c() public view override(ILocker, Locker) returns (uint256) {
        return _0xe6f629;
    }
}