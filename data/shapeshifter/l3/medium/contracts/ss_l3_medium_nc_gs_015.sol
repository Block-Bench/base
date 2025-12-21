pragma solidity ^0.8.13;

import {ILockManager, LockManagerSettings, PluginMode} from "../interfaces/ILockManager.sol";
import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockToVote} from "../interfaces/ILockToVote.sol";
import {IMajorityVoting} from "../interfaces/IMajorityVoting.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


abstract contract LockManagerBase is ILockManager {
    using EnumerableSet for EnumerableSet.UintSet;


    LockManagerSettings public _0xa4a31d;


    ILockToGovernBase public _0x655892;


    mapping(address => uint256) private _0x48263d;


    EnumerableSet.UintSet internal _0xf043d5;


    event BalanceLocked(address _0x0bffbf, uint256 _0x875c72);


    event BalanceUnlocked(address _0x0bffbf, uint256 _0x875c72);


    event ProposalEnded(uint256 _0x9c6505);


    error InvalidPluginAddress();


    error NoBalance();


    error LocksStillActive();


    error InvalidPlugin();


    error InvalidPluginMode();


    error SetPluginAddressForbidden();


    constructor(LockManagerSettings memory _0x406c73) {
        _0xa4a31d._0x2164cd = _0x406c73._0x2164cd;
    }


    function _0x627da1(uint256 _0xf675b3) public view virtual returns (uint256) {
        return _0xf043d5._0xf07d50(_0xf675b3);
    }


    function _0x669d85() public view virtual returns (uint256) {
        return _0xf043d5.length();
    }


    function _0xf48ed1() public virtual {
        _0x06fb79(_0x202035());
    }


    function _0xf48ed1(uint256 _0x28cc94) public virtual {
        _0x06fb79(_0x28cc94);
    }


    function _0x5a9319(uint256 _0x6293a7, IMajorityVoting.VoteOption _0x714015) public virtual {
        if (_0xa4a31d._0x2164cd != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x06fb79(_0x202035());
        _0x015d34(_0x6293a7, _0x714015);
    }


    function _0x5a9319(uint256 _0x6293a7, IMajorityVoting.VoteOption _0x714015, uint256 _0x28cc94) public virtual {
        if (_0xa4a31d._0x2164cd != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x06fb79(_0x28cc94);
        _0x015d34(_0x6293a7, _0x714015);
    }


    function _0xe0de3d(uint256 _0x6293a7, IMajorityVoting.VoteOption _0x714015) public virtual {
        if (_0xa4a31d._0x2164cd != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x015d34(_0x6293a7, _0x714015);
    }


    function _0x62bf4a(address _0xde4487) public view virtual returns (uint256) {
        return _0x48263d[_0xde4487];
    }


    function _0xfd32a5(uint256 _0x6293a7, address _0x9b781b, IMajorityVoting.VoteOption _0x714015)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(_0x655892))._0xfd32a5(_0x6293a7, _0x9b781b, _0x714015);
    }


    function _0xa4e296() public virtual {
        uint256 _0x17a4e8 = _0x62bf4a(msg.sender);
        if (_0x17a4e8 == 0) {
            revert NoBalance();
        }


        _0xb86a66();


        _0x48263d[msg.sender] = 0;


        _0x85cd1e(msg.sender, _0x17a4e8);
        emit BalanceUnlocked(msg.sender, _0x17a4e8);
    }


    function _0xbb8b70(uint256 _0x6293a7) public virtual {
        if (msg.sender != address(_0x655892)) {
            revert InvalidPluginAddress();
        }


        _0xf043d5._0x244d05(_0x6293a7);
    }


    function _0x12cfa7(uint256 _0x6293a7) public virtual {
        if (msg.sender != address(_0x655892)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(_0x6293a7);
        _0xf043d5._0x3ec8b0(_0x6293a7);
    }


    function _0x6c9c78(ILockToGovernBase _0x1e317a) public virtual {
        if (address(_0x655892) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(_0x1e317a))._0xcb1443(type(ILockToGovernBase)._0x922e7e)) {
            revert InvalidPlugin();
        }

        else if (
            _0xa4a31d._0x2164cd == PluginMode.Voting
                && !IERC165(address(_0x1e317a))._0xcb1443(type(ILockToVote)._0x922e7e)
        ) {
            revert InvalidPlugin();
        }

        _0x655892 = _0x1e317a;
    }


    function _0x202035() internal view virtual returns (uint256);


    function _0x06fb79(uint256 _0x28cc94) internal virtual {
        if (_0x28cc94 == 0) {
            revert NoBalance();
        }


        _0x03d967(_0x28cc94);

        _0x48263d[msg.sender] += _0x28cc94;
        emit BalanceLocked(msg.sender, _0x28cc94);
    }


    function _0x03d967(uint256 _0x28cc94) internal virtual;


    function _0x85cd1e(address _0x08b225, uint256 _0x28cc94) internal virtual;

    function _0x015d34(uint256 _0x6293a7, IMajorityVoting.VoteOption _0x714015) internal virtual {
        uint256 _0x80255d = _0x62bf4a(msg.sender);


        ILockToVote(address(_0x655892))._0xe0de3d(_0x6293a7, msg.sender, _0x714015, _0x80255d);
    }

    function _0xb86a66() internal virtual {
        uint256 _0xfa0f5d = _0xf043d5.length();
        for (uint256 _0x9d4224; _0x9d4224 < _0xfa0f5d;) {
            uint256 _0x6293a7 = _0xf043d5._0xf07d50(_0x9d4224);
            if (!_0x655892._0xeb268b(_0x6293a7)) {
                _0xf043d5._0x3ec8b0(_0x6293a7);
                _0xfa0f5d = _0xf043d5.length();


                if (_0x9d4224 == _0xfa0f5d) {
                    return;
                }


                continue;
            }

            if (_0x655892._0xf65bca(_0x6293a7, msg.sender) > 0) {
                ILockToVote(address(_0x655892))._0xa1a07d(_0x6293a7, msg.sender);
            }

            unchecked {
                _0x9d4224++;
            }
        }
    }
}