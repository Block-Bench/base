pragma solidity ^0.8.13;

import {ILockManager, LockManagerSettings, PluginMode} from "../interfaces/ILockManager.sol";
import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockToVote} from "../interfaces/ILockToVote.sol";
import {IMajorityVoting} from "../interfaces/IMajorityVoting.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


abstract contract LockManagerBase is ILockManager {
    using EnumerableSet for EnumerableSet.UintSet;


    LockManagerSettings public _0x352474;


    ILockToGovernBase public _0xd566ee;


    mapping(address => uint256) private _0x75c1df;


    EnumerableSet.UintSet internal _0xa0133f;


    event BalanceLocked(address _0xab44d2, uint256 _0xef31f9);


    event BalanceUnlocked(address _0xab44d2, uint256 _0xef31f9);


    event ProposalEnded(uint256 _0xd27f88);


    error InvalidPluginAddress();


    error NoBalance();


    error LocksStillActive();


    error InvalidPlugin();


    error InvalidPluginMode();


    error SetPluginAddressForbidden();


    constructor(LockManagerSettings memory _0x09d36c) {
        _0x352474._0x504e76 = _0x09d36c._0x504e76;
    }


    function _0x92b519(uint256 _0xe79873) public view virtual returns (uint256) {
        return _0xa0133f._0xd9b623(_0xe79873);
    }


    function _0x8c6ab7() public view virtual returns (uint256) {
        return _0xa0133f.length();
    }


    function _0xdf01ac() public virtual {
        _0x27fa70(_0x74d906());
    }


    function _0xdf01ac(uint256 _0xebdd2f) public virtual {
        _0x27fa70(_0xebdd2f);
    }


    function _0x7abd21(uint256 _0xe0c6d8, IMajorityVoting.VoteOption _0xb62915) public virtual {
        if (_0x352474._0x504e76 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x27fa70(_0x74d906());
        _0x455c55(_0xe0c6d8, _0xb62915);
    }


    function _0x7abd21(uint256 _0xe0c6d8, IMajorityVoting.VoteOption _0xb62915, uint256 _0xebdd2f) public virtual {
        if (_0x352474._0x504e76 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x27fa70(_0xebdd2f);
        _0x455c55(_0xe0c6d8, _0xb62915);
    }


    function _0x2411db(uint256 _0xe0c6d8, IMajorityVoting.VoteOption _0xb62915) public virtual {
        if (_0x352474._0x504e76 != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        _0x455c55(_0xe0c6d8, _0xb62915);
    }


    function _0x772b30(address _0xf564c5) public view virtual returns (uint256) {
        return _0x75c1df[_0xf564c5];
    }


    function _0x9c2d5c(uint256 _0xe0c6d8, address _0x698859, IMajorityVoting.VoteOption _0xb62915)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(_0xd566ee))._0x9c2d5c(_0xe0c6d8, _0x698859, _0xb62915);
    }


    function _0xee697c() public virtual {
        uint256 _0xff92d2 = _0x772b30(msg.sender);
        if (_0xff92d2 == 0) {
            revert NoBalance();
        }


        _0xf37076();


        _0x75c1df[msg.sender] = 0;


        _0x35b897(msg.sender, _0xff92d2);
        emit BalanceUnlocked(msg.sender, _0xff92d2);
    }


    function _0x46ca3f(uint256 _0xe0c6d8) public virtual {
        if (msg.sender != address(_0xd566ee)) {
            revert InvalidPluginAddress();
        }


        _0xa0133f._0x1a15c2(_0xe0c6d8);
    }


    function _0x75b714(uint256 _0xe0c6d8) public virtual {
        if (msg.sender != address(_0xd566ee)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(_0xe0c6d8);
        _0xa0133f._0x3890fb(_0xe0c6d8);
    }


    function _0xe79830(ILockToGovernBase _0x4c2729) public virtual {
        if (address(_0xd566ee) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(_0x4c2729))._0x74b3ef(type(ILockToGovernBase)._0x92f1e3)) {
            revert InvalidPlugin();
        }

        else if (
            _0x352474._0x504e76 == PluginMode.Voting
                && !IERC165(address(_0x4c2729))._0x74b3ef(type(ILockToVote)._0x92f1e3)
        ) {
            revert InvalidPlugin();
        }

        _0xd566ee = _0x4c2729;
    }


    function _0x74d906() internal view virtual returns (uint256);


    function _0x27fa70(uint256 _0xebdd2f) internal virtual {
        if (_0xebdd2f == 0) {
            revert NoBalance();
        }


        _0x9a35cd(_0xebdd2f);

        _0x75c1df[msg.sender] += _0xebdd2f;
        emit BalanceLocked(msg.sender, _0xebdd2f);
    }


    function _0x9a35cd(uint256 _0xebdd2f) internal virtual;


    function _0x35b897(address _0x18b17f, uint256 _0xebdd2f) internal virtual;

    function _0x455c55(uint256 _0xe0c6d8, IMajorityVoting.VoteOption _0xb62915) internal virtual {
        uint256 _0x9f8ba1 = _0x772b30(msg.sender);


        ILockToVote(address(_0xd566ee))._0x2411db(_0xe0c6d8, msg.sender, _0xb62915, _0x9f8ba1);
    }

    function _0xf37076() internal virtual {
        uint256 _0xb979e7 = _0xa0133f.length();
        for (uint256 _0x8abceb; _0x8abceb < _0xb979e7;) {
            uint256 _0xe0c6d8 = _0xa0133f._0xd9b623(_0x8abceb);
            if (!_0xd566ee._0xe2a55e(_0xe0c6d8)) {
                _0xa0133f._0x3890fb(_0xe0c6d8);
                if (msg.sender != address(0) || msg.sender == address(0)) { _0xb979e7 = _0xa0133f.length(); }


                if (_0x8abceb == _0xb979e7) {
                    return;
                }


                continue;
            }

            if (_0xd566ee._0x35fd13(_0xe0c6d8, msg.sender) > 0) {
                ILockToVote(address(_0xd566ee))._0xf6bcc6(_0xe0c6d8, msg.sender);
            }

            unchecked {
                _0x8abceb++;
            }
        }
    }
}