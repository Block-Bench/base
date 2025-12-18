pragma solidity ^0.8.13;

import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockToGovernBase} from "./base/LockToGovernBase.sol";
import {ILockToVote} from "./interfaces/ILockToVote.sol";
import {IDAO} from "@aragon/osx-commons-contracts/src/dao/IDAO.sol";
import {Action} from "@aragon/osx-commons-contracts/src/executors/IExecutor.sol";
import {IPlugin} from "@aragon/osx-commons-contracts/src/plugin/IPlugin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IProposal} from "@aragon/osx-commons-contracts/src/plugin/extensions/proposal/IProposal.sol";
import {ERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import {SafeCastUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MajorityVotingBase} from "./base/MajorityVotingBase.sol";
import {ILockToGovernBase} from "./interfaces/ILockToGovernBase.sol";

contract LockToVotePlugin is ILockToVote, MajorityVotingBase, LockToGovernBase {
    using SafeCastUpgradeable for uint256;


    bytes4 internal constant LOCK_TO_VOTE_INTERFACE_ID =
        this._0x7b922b.selector ^ this._0xf514cf.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xc98e71("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xc98e71("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0xe71f86, address _0xfb3840);

    error VoteRemovalForbidden(uint256 _0xe71f86, address _0xfb3840);


    function _0xff85ec(
        IDAO _0x4f364c,
        ILockManager _0x5cb8c4,
        VotingSettings calldata _0x7bf5a3,
        IPlugin.TargetConfig calldata _0xb86168,
        bytes calldata _0x575e4e
    ) external _0xf764b1 _0xb7d8e0(1) {
        __MajorityVotingBase_init(_0x4f364c, _0x7bf5a3, _0xb86168, _0x575e4e);
        __LockToGovernBase_init(_0x5cb8c4);

        emit MembershipContractAnnounced({_0x7b8b6c: address(_0x5cb8c4._0x3a3da6())});
    }


    function _0x7bba61(bytes4 _0xff054a)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0xff054a == LOCK_TO_VOTE_INTERFACE_ID || _0xff054a == type(ILockToVote)._0x370c01
            || super._0x7bba61(_0xff054a);
    }


    function _0x76caa8() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function _0xf514cf(
        bytes calldata _0x229508,
        Action[] memory _0xfe98fa,
        uint64 _0x8a9c47,
        uint64 _0x409210,
        bytes memory _0x8663e4
    ) external _0x530124(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0xe71f86) {
        uint256 _0x10a9ac;

        if (_0x8663e4.length != 0) {
            (_0x10a9ac) = abi._0xe9d116(_0x8663e4, (uint256));
        }

        if (_0xd995f2() == 0) {
            revert NoVotingPower();
        }


        (_0x8a9c47, _0x409210) = _0xe55afd(_0x8a9c47, _0x409210);

        _0xe71f86 = _0xa0fe2f(_0xc98e71(abi._0x4ad277(_0xfe98fa, _0x229508)));

        if (_0x24df5c(_0xe71f86)) {
            revert ProposalAlreadyExists(_0xe71f86);
        }


        Proposal storage _0xae50c8 = _0xd78e8c[_0xe71f86];

        _0xae50c8._0x9011f3._0x9fb387 = _0x9fb387();
        _0xae50c8._0x9011f3._0xb0162f = _0xb0162f();
        _0xae50c8._0x9011f3._0xc6575c = _0x8a9c47;
        _0xae50c8._0x9011f3._0x06cf18 = _0x409210;
        _0xae50c8._0x9011f3._0x2f976e = _0x2f976e();
        _0xae50c8._0x9011f3._0x2cdb4d = _0x2cdb4d();

        _0xae50c8._0x30d9a3 = _0x5e4934();


        if (_0x10a9ac != 0) {
            _0xae50c8._0x4d0aa8 = _0x10a9ac;
        }

        for (uint256 i; i < _0xfe98fa.length;) {
            _0xae50c8._0x51454a.push(_0xfe98fa[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0xe71f86, _0x5cb470(), _0x8a9c47, _0x409210, _0x229508, _0xfe98fa, _0x10a9ac);

        _0xa2b6f0._0x691ade(_0xe71f86);
    }


    function _0xec9863(uint256 _0x477ee8, address _0xee35a9, VoteOption _0x9b0ded) public view returns (bool) {
        if (!_0x24df5c(_0x477ee8)) {
            revert NonexistentProposal(_0x477ee8);
        }

        Proposal storage _0xae50c8 = _0xd78e8c[_0x477ee8];
        return _0xbd8483(_0xae50c8, _0xee35a9, _0x9b0ded, _0xa2b6f0._0x43e1a6(_0xee35a9));
    }


    function _0x37ac6a(uint256 _0x477ee8, address _0xee35a9, VoteOption _0x9b0ded, uint256 _0xb49191)
        public
        override
        _0x530124(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0xae50c8 = _0xd78e8c[_0x477ee8];

        if (!_0xbd8483(_0xae50c8, _0xee35a9, _0x9b0ded, _0xb49191)) {
            revert VoteCastForbidden(_0x477ee8, _0xee35a9);
        }


        if (_0x9b0ded == _0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7) {

            if (_0xb49191 == _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769) return;


            uint256 _0xfdf832 = _0xb49191 - _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;
            _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769 = _0xb49191;

            if (_0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 == VoteOption.Yes) {
                _0xae50c8._0x6b5195._0x3d32a9 += _0xfdf832;
            } else if (_0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 == VoteOption.No) {
                _0xae50c8._0x6b5195._0xb59e89 += _0xfdf832;
            } else {

                _0xae50c8._0x6b5195._0x52bf15 += _0xfdf832;
            }
        } else {


            if (_0xae50c8._0x64b6bc[_0xee35a9]._0xb56769 > 0) {

                if (_0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 == VoteOption.Yes) {
                    _0xae50c8._0x6b5195._0x3d32a9 -= _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;
                } else if (_0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 == VoteOption.No) {
                    _0xae50c8._0x6b5195._0xb59e89 -= _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;
                } else {

                    _0xae50c8._0x6b5195._0x52bf15 -= _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;
                }
            }


            if (_0x9b0ded == VoteOption.Yes) {
                _0xae50c8._0x6b5195._0x3d32a9 += _0xb49191;
            } else if (_0x9b0ded == VoteOption.No) {
                _0xae50c8._0x6b5195._0xb59e89 += _0xb49191;
            } else {

                _0xae50c8._0x6b5195._0x52bf15 += _0xb49191;
            }
            _0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 = _0x9b0ded;
            _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769 = _0xb49191;
        }

        emit VoteCast(_0x477ee8, _0xee35a9, _0x9b0ded, _0xb49191);

        if (_0xae50c8._0x9011f3._0x9fb387 == VotingMode.EarlyExecution) {
            _0x4c0cf6(_0x477ee8, _0x5cb470());
        }
    }


    function _0xe13a3f(uint256 _0x477ee8, address _0xee35a9) external _0x530124(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0xae50c8 = _0xd78e8c[_0x477ee8];
        if (!_0x26d365(_0xae50c8)) {
            revert VoteRemovalForbidden(_0x477ee8, _0xee35a9);
        } else if (_0xae50c8._0x9011f3._0x9fb387 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x477ee8, _0xee35a9);
        } else if (_0xae50c8._0x64b6bc[_0xee35a9]._0xb56769 == 0) {

            return;
        }


        if (_0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 == VoteOption.Yes) {
            _0xae50c8._0x6b5195._0x3d32a9 -= _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;
        } else if (_0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 == VoteOption.No) {
            _0xae50c8._0x6b5195._0xb59e89 -= _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;
        }

        else if (_0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 == VoteOption.Abstain) {
            _0xae50c8._0x6b5195._0x52bf15 -= _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;
        }
        _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769 = 0;

        emit VoteCleared(_0x477ee8, _0xee35a9);
    }


    function _0xcbdf0a(uint256 _0x477ee8) external view returns (bool) {
        Proposal storage _0xae50c8 = _0xd78e8c[_0x477ee8];
        return _0x26d365(_0xae50c8);
    }


    function _0x7b922b() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x7b922b();
    }


    function _0xd995f2() public view override returns (uint256) {
        return IERC20(_0xa2b6f0._0x3a3da6())._0xfddec4();
    }


    function _0x18249c(uint256 _0x477ee8, address _0xee35a9) public view returns (uint256) {
        return _0xd78e8c[_0x477ee8]._0x64b6bc[_0xee35a9]._0xb56769;
    }


    function _0xbd8483(Proposal storage _0xae50c8, address _0xee35a9, VoteOption _0x9b0ded, uint256 _0xb49191)
        internal
        view
        returns (bool)
    {
        uint256 _0x864354 = _0xae50c8._0x64b6bc[_0xee35a9]._0xb56769;


        if (!_0x26d365(_0xae50c8)) {
            return false;
        } else if (_0x9b0ded == VoteOption.None) {
            return false;
        }

        else if (_0xae50c8._0x9011f3._0x9fb387 != VotingMode.VoteReplacement) {

            if (_0xb49191 <= _0x864354) {
                return false;
            }

            else if (
                _0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7 != VoteOption.None
                    && _0x9b0ded != _0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7
            ) {
                return false;
            }
        }

        else {

            if (_0xb49191 == 0 || _0xb49191 < _0x864354) {
                return false;
            }

            else if (_0xb49191 == _0x864354 && _0x9b0ded == _0xae50c8._0x64b6bc[_0xee35a9]._0x6d2de7) {
                return false;
            }
        }

        return true;
    }

    function _0x4c0cf6(uint256 _0x477ee8, address _0x6b01ee) internal {
        if (!_0x739335(_0x477ee8)) {
            return;
        } else if (!_0x182e14()._0x3c60b5(address(this), _0x6b01ee, EXECUTE_PROPOSAL_PERMISSION_ID, _0x414a6a())) {
            return;
        }

        _0x98579b(_0x477ee8);
    }

    function _0x98579b(uint256 _0x477ee8) internal override {
        super._0x98579b(_0x477ee8);


        _0xa2b6f0._0x0af201(_0x477ee8);
    }


    uint256[50] private __gap;
}