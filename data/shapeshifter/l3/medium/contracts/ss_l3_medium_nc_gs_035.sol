pragma solidity >=0.8.19 <0.9.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IV2Pool} from "../../external/IV2Pool.sol";
import {IV2Router} from "../../external/IV2Router.sol";
import {IV2LockerFactory} from "../../interfaces/extensions/v2/IV2LockerFactory.sol";
import {IV2Locker} from "../../interfaces/extensions/v2/IV2Locker.sol";
import {ILocker} from "../../interfaces/ILocker.sol";
import {Locker} from "../../Locker.sol";


contract V2Locker is Locker, IV2Locker {
    using SafeERC20 for IERC20;


    address public immutable _0x9e50bd;

    uint256 internal _0x784c89;

    constructor(
        bool _0x3ed5b5,
        address _0x031786,
        address _0x071c16,
        address _0x40bf79,
        uint256 _0x02f58e,
        uint32 _0xff0235,
        address _0x24a44f,
        uint16 _0x122b9c,
        uint16 _0xa71312
    ) Locker(_0x3ed5b5, _0x031786, _0x071c16, _0xff0235, _0x24a44f, _0x122b9c, _0xa71312) {
        _0x9e50bd = _0x40bf79;
        _0x784c89 = _0x02f58e;
        (_0x4f6ec8, _0x41ec84) = IV2Pool(_0x13b32d)._0x4c40c7();
    }


    function _0x402fa3(address _0x55b1db) external override(Locker, ILocker) _0xfa3324 _0xf0b8fe returns (uint256) {
        if (msg.sender != _0xeba3b6) revert NotFactory();

        delete _0xa675c2;
        delete _0xc193c3;

        IERC20(_0x13b32d)._0x22768a({_0x3d7c2f: _0x55b1db, value: _0x784c89});


        uint256 _0x7d2ff0 = IERC20(_0x4f6ec8)._0xc42ba4({_0xb88cd4: address(this)});
        if (_0x7d2ff0 > 0) IERC20(_0x4f6ec8)._0x22768a({_0x3d7c2f: _0x55b1db, value: _0x7d2ff0});
        _0x7d2ff0 = IERC20(_0x41ec84)._0xc42ba4({_0xb88cd4: address(this)});
        if (_0x7d2ff0 > 0) IERC20(_0x41ec84)._0x22768a({_0x3d7c2f: _0x55b1db, value: _0x7d2ff0});

        emit Unlocked({_0x078065: _0x55b1db});
        return _0x784c89;
    }


    function _0x072fed() external override(Locker, ILocker) _0xf0b8fe _0x9a3167 _0xfa3324 _0x2bc5a1 {
        if (_0xa675c2) revert AlreadyStaked();
        _0xa675c2 = true;

        _0xb7d1ae({_0x55b1db: _0x7c80be()});

        IERC20(_0x13b32d)._0x868644({_0x871ad3: address(_0x795b7b), value: _0x784c89});
        _0x795b7b._0x5af9f4({_0xd4c5ab: _0x784c89});
        emit Staked();
    }


    function _0xb2aac6(uint256 _0x00cdbe, uint256 _0x2b9987, uint256 _0x5902cb, uint256 _0x80bcc6)
        external
        override(ILocker, Locker)
        _0xf0b8fe
        _0x9a3167
        _0xfa3324
        returns (uint256)
    {
        if (_0x00cdbe == 0 && _0x2b9987 == 0) revert ZeroAmount();

        uint256 _0x5df828 = _0xb05c84({_0x4451b4: _0x4f6ec8, _0x2d2241: _0x00cdbe});
        uint256 _0x149c60 = _0xb05c84({_0x4451b4: _0x41ec84, _0x2d2241: _0x2b9987});

        IERC20(_0x4f6ec8)._0xc0995a({_0x871ad3: _0x9e50bd, value: _0x00cdbe});
        IERC20(_0x41ec84)._0xc0995a({_0x871ad3: _0x9e50bd, value: _0x2b9987});

        (uint256 _0x738190, uint256 _0x2440c1, uint256 _0xc4222d) = IV2Router(_0x9e50bd)._0x7b2176({
            _0xcc948c: _0x4f6ec8,
            _0x72abd2: _0x41ec84,
            _0x0a4d5f: IV2Pool(_0x13b32d)._0x0a4d5f(),
            _0x98ac3b: _0x00cdbe,
            _0xbf9101: _0x2b9987,
            _0x4f3a81: _0x5902cb,
            _0x219db3: _0x80bcc6,
            _0x3d7c2f: address(this),
            _0xed3448: block.timestamp
        });

        IERC20(_0x4f6ec8)._0xc0995a({_0x871ad3: _0x9e50bd, value: 0});
        IERC20(_0x41ec84)._0xc0995a({_0x871ad3: _0x9e50bd, value: 0});

        address _0x078065 = _0x7c80be();
        _0x86f397({_0x4451b4: _0x4f6ec8, _0x55b1db: _0x078065, _0x9daa3b: _0x5df828});
        _0x86f397({_0x4451b4: _0x41ec84, _0x55b1db: _0x078065, _0x9daa3b: _0x149c60});

        if (_0xa675c2) {
            IERC20(_0x13b32d)._0x868644({_0x871ad3: address(_0x795b7b), value: _0xc4222d});
            _0x795b7b._0x5af9f4({_0xd4c5ab: _0xc4222d});
        }

        _0x784c89 += _0xc4222d;

        emit LiquidityIncreased({_0x6e1c90: _0x738190, _0x6a98b5: _0x2440c1, _0xc4222d: _0xc4222d});
        return _0xc4222d;
    }

    function _0x0fe0fb() internal override returns (uint256 _0x7a75e8, uint256 _0x847d07) {
        (_0x7a75e8, _0x847d07) = IV2Pool(_0x13b32d)._0x97fd78();

        uint256 _0x565496 = _0xd7b041({_0x9509de: _0x7a75e8, _0x4451b4: _0x4f6ec8});
        uint256 _0x1b1892 = _0xd7b041({_0x9509de: _0x847d07, _0x4451b4: _0x41ec84});
        _0x7a75e8 -= _0x565496;
        _0x847d07 -= _0x1b1892;

        if (_0x565496 > 0 || _0x1b1892 > 0) {
            emit FeesClaimed({_0x078065: _0x2b65e0, _0x7a75e8: _0x565496, _0x847d07: _0x1b1892});
        }
    }

    function _0xd7730c() internal override returns (uint256 _0x932a09) {
        uint256 _0xbf5218 = IERC20(_0xe70de1)._0xc42ba4({_0xb88cd4: address(this)});
        _0x795b7b._0xa47501({_0xb88cd4: address(this)});
        uint256 _0xb4bea2 = IERC20(_0xe70de1)._0xc42ba4({_0xb88cd4: address(this)});

        if (gasleft() > 0) { _0x932a09 = _0xb4bea2 - _0xbf5218; }
        uint256 _0xb94835 = _0xd7b041({_0x9509de: _0x932a09, _0x4451b4: _0xe70de1});
        _0x932a09 -= _0xb94835;

        if (_0xb94835 > 0) {
            emit RewardsClaimed({_0x078065: _0x2b65e0, _0x932a09: _0xb94835});
        }
    }

    function _0xd4c5ab() public view override(ILocker, Locker) returns (uint256) {
        return _0x784c89;
    }
}