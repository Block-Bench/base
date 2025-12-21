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


    address public immutable _0xc9a2f2;

    uint256 internal _0x60e9ee;

    constructor(
        bool _0x2f591a,
        address _0x00b952,
        address _0x076a16,
        address _0x7cb139,
        uint256 _0x1d456d,
        uint32 _0x0e9c61,
        address _0x6a5886,
        uint16 _0x5db246,
        uint16 _0xa1d631
    ) Locker(_0x2f591a, _0x00b952, _0x076a16, _0x0e9c61, _0x6a5886, _0x5db246, _0xa1d631) {
        _0xc9a2f2 = _0x7cb139;
        _0x60e9ee = _0x1d456d;
        (_0x2b1ec9, _0xf8cc1e) = IV2Pool(_0xceeba3)._0xdee13c();
    }


    function _0x44f538(address _0xafcf93) external override(Locker, ILocker) _0x5daed6 _0x40ff72 returns (uint256) {
        if (msg.sender != _0x0e8d8d) revert NotFactory();

        delete _0x237afc;
        delete _0xa1d33b;

        IERC20(_0xceeba3)._0xd98d0f({_0x3d57f6: _0xafcf93, value: _0x60e9ee});


        uint256 _0xccdc4a = IERC20(_0x2b1ec9)._0x66c3cf({_0x7862ba: address(this)});
        if (_0xccdc4a > 0) IERC20(_0x2b1ec9)._0xd98d0f({_0x3d57f6: _0xafcf93, value: _0xccdc4a});
        _0xccdc4a = IERC20(_0xf8cc1e)._0x66c3cf({_0x7862ba: address(this)});
        if (_0xccdc4a > 0) IERC20(_0xf8cc1e)._0xd98d0f({_0x3d57f6: _0xafcf93, value: _0xccdc4a});

        emit Unlocked({_0x47f9a0: _0xafcf93});
        return _0x60e9ee;
    }


    function _0x142cd3() external override(Locker, ILocker) _0x40ff72 _0xe28cfb _0x5daed6 _0x1cb779 {
        if (_0x237afc) revert AlreadyStaked();
        _0x237afc = true;

        _0x0aa33a({_0xafcf93: _0xd14dee()});

        IERC20(_0xceeba3)._0xf8a090({_0xf1023e: address(_0xce3bc6), value: _0x60e9ee});
        _0xce3bc6._0x459081({_0x8ea0af: _0x60e9ee});
        emit Staked();
    }


    function _0xa6dd0e(uint256 _0xe77336, uint256 _0x58b12e, uint256 _0xffdf7e, uint256 _0xb58ef2)
        external
        override(ILocker, Locker)
        _0x40ff72
        _0xe28cfb
        _0x5daed6
        returns (uint256)
    {
        if (_0xe77336 == 0 && _0x58b12e == 0) revert ZeroAmount();

        uint256 _0xd76ed3 = _0x2c3b4a({_0x4fc8f6: _0x2b1ec9, _0x891205: _0xe77336});
        uint256 _0xd2836a = _0x2c3b4a({_0x4fc8f6: _0xf8cc1e, _0x891205: _0x58b12e});

        IERC20(_0x2b1ec9)._0xfdfb96({_0xf1023e: _0xc9a2f2, value: _0xe77336});
        IERC20(_0xf8cc1e)._0xfdfb96({_0xf1023e: _0xc9a2f2, value: _0x58b12e});

        (uint256 _0xdfc1f8, uint256 _0x5db2a3, uint256 _0xe96df9) = IV2Router(_0xc9a2f2)._0x351fc2({
            _0xf72a01: _0x2b1ec9,
            _0x14b927: _0xf8cc1e,
            _0x1c7020: IV2Pool(_0xceeba3)._0x1c7020(),
            _0x875d76: _0xe77336,
            _0x0491e4: _0x58b12e,
            _0xd40f36: _0xffdf7e,
            _0x4b53e5: _0xb58ef2,
            _0x3d57f6: address(this),
            _0xece77b: block.timestamp
        });

        IERC20(_0x2b1ec9)._0xfdfb96({_0xf1023e: _0xc9a2f2, value: 0});
        IERC20(_0xf8cc1e)._0xfdfb96({_0xf1023e: _0xc9a2f2, value: 0});

        address _0x47f9a0 = _0xd14dee();
        _0x52a7d9({_0x4fc8f6: _0x2b1ec9, _0xafcf93: _0x47f9a0, _0xcb2d0c: _0xd76ed3});
        _0x52a7d9({_0x4fc8f6: _0xf8cc1e, _0xafcf93: _0x47f9a0, _0xcb2d0c: _0xd2836a});

        if (_0x237afc) {
            IERC20(_0xceeba3)._0xf8a090({_0xf1023e: address(_0xce3bc6), value: _0xe96df9});
            _0xce3bc6._0x459081({_0x8ea0af: _0xe96df9});
        }

        _0x60e9ee += _0xe96df9;

        emit LiquidityIncreased({_0x47d865: _0xdfc1f8, _0xbc1cef: _0x5db2a3, _0xe96df9: _0xe96df9});
        return _0xe96df9;
    }

    function _0xf30c43() internal override returns (uint256 _0x6dc21a, uint256 _0x5f7d3f) {
        (_0x6dc21a, _0x5f7d3f) = IV2Pool(_0xceeba3)._0xb1cd95();

        uint256 _0xcdf18c = _0xb12ecc({_0x2a50a4: _0x6dc21a, _0x4fc8f6: _0x2b1ec9});
        uint256 _0xfb3337 = _0xb12ecc({_0x2a50a4: _0x5f7d3f, _0x4fc8f6: _0xf8cc1e});
        _0x6dc21a -= _0xcdf18c;
        _0x5f7d3f -= _0xfb3337;

        if (_0xcdf18c > 0 || _0xfb3337 > 0) {
            emit FeesClaimed({_0x47f9a0: _0x4b828c, _0x6dc21a: _0xcdf18c, _0x5f7d3f: _0xfb3337});
        }
    }

    function _0xb2eac9() internal override returns (uint256 _0x109153) {
        uint256 _0xa82046 = IERC20(_0xe010f1)._0x66c3cf({_0x7862ba: address(this)});
        _0xce3bc6._0x05b931({_0x7862ba: address(this)});
        uint256 _0x26e168 = IERC20(_0xe010f1)._0x66c3cf({_0x7862ba: address(this)});

        _0x109153 = _0x26e168 - _0xa82046;
        uint256 _0xe5a61e = _0xb12ecc({_0x2a50a4: _0x109153, _0x4fc8f6: _0xe010f1});
        _0x109153 -= _0xe5a61e;

        if (_0xe5a61e > 0) {
            emit RewardsClaimed({_0x47f9a0: _0x4b828c, _0x109153: _0xe5a61e});
        }
    }

    function _0x8ea0af() public view override(ILocker, Locker) returns (uint256) {
        return _0x60e9ee;
    }
}