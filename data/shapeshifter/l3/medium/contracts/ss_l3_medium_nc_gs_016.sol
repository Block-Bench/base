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
        this._0x1e21d4.selector ^ this._0x466568.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x71d647("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x71d647("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x78a3b7, address _0x452bc4);

    error VoteRemovalForbidden(uint256 _0x78a3b7, address _0x452bc4);


    function _0x99d443(
        IDAO _0x296b53,
        ILockManager _0x67b98f,
        VotingSettings calldata _0x0a0d18,
        IPlugin.TargetConfig calldata _0x8a096e,
        bytes calldata _0x2e6b9f
    ) external _0x779234 _0x012f5e(1) {
        __MajorityVotingBase_init(_0x296b53, _0x0a0d18, _0x8a096e, _0x2e6b9f);
        __LockToGovernBase_init(_0x67b98f);

        emit MembershipContractAnnounced({_0xf7024d: address(_0x67b98f._0xc0b7c2())});
    }


    function _0xa20415(bytes4 _0xe9e33f)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0xe9e33f == LOCK_TO_VOTE_INTERFACE_ID || _0xe9e33f == type(ILockToVote)._0xcc53cd
            || super._0xa20415(_0xe9e33f);
    }


    function _0x67182f() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function _0x466568(
        bytes calldata _0xb612d5,
        Action[] memory _0xe2bf52,
        uint64 _0x9d8a94,
        uint64 _0xf7e39b,
        bytes memory _0xb9c1cb
    ) external _0xddb48b(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x78a3b7) {
        uint256 _0xb22fa9;

        if (_0xb9c1cb.length != 0) {
            (_0xb22fa9) = abi._0x44ec1e(_0xb9c1cb, (uint256));
        }

        if (_0xae46f7() == 0) {
            revert NoVotingPower();
        }


        (_0x9d8a94, _0xf7e39b) = _0x6b90bf(_0x9d8a94, _0xf7e39b);

        _0x78a3b7 = _0x40c569(_0x71d647(abi._0x37756b(_0xe2bf52, _0xb612d5)));

        if (_0x82db35(_0x78a3b7)) {
            revert ProposalAlreadyExists(_0x78a3b7);
        }


        Proposal storage _0x5cc34c = _0x655b0c[_0x78a3b7];

        _0x5cc34c._0x103ad5._0x5436f0 = _0x5436f0();
        _0x5cc34c._0x103ad5._0xf89b0a = _0xf89b0a();
        _0x5cc34c._0x103ad5._0x3249cb = _0x9d8a94;
        _0x5cc34c._0x103ad5._0xc2e997 = _0xf7e39b;
        _0x5cc34c._0x103ad5._0x86ba05 = _0x86ba05();
        _0x5cc34c._0x103ad5._0x832c70 = _0x832c70();

        _0x5cc34c._0xa1d262 = _0x76dae8();


        if (_0xb22fa9 != 0) {
            _0x5cc34c._0x864bc8 = _0xb22fa9;
        }

        for (uint256 i; i < _0xe2bf52.length;) {
            _0x5cc34c._0x8754b5.push(_0xe2bf52[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x78a3b7, _0xb0c8c5(), _0x9d8a94, _0xf7e39b, _0xb612d5, _0xe2bf52, _0xb22fa9);

        _0xa25574._0x32ffd9(_0x78a3b7);
    }


    function _0xe85783(uint256 _0x32bd9a, address _0x481484, VoteOption _0x958747) public view returns (bool) {
        if (!_0x82db35(_0x32bd9a)) {
            revert NonexistentProposal(_0x32bd9a);
        }

        Proposal storage _0x5cc34c = _0x655b0c[_0x32bd9a];
        return _0xcd9258(_0x5cc34c, _0x481484, _0x958747, _0xa25574._0xa33417(_0x481484));
    }


    function _0x9d5784(uint256 _0x32bd9a, address _0x481484, VoteOption _0x958747, uint256 _0x7f7ecc)
        public
        override
        _0xddb48b(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x5cc34c = _0x655b0c[_0x32bd9a];

        if (!_0xcd9258(_0x5cc34c, _0x481484, _0x958747, _0x7f7ecc)) {
            revert VoteCastForbidden(_0x32bd9a, _0x481484);
        }


        if (_0x958747 == _0x5cc34c._0x447d00[_0x481484]._0x456df8) {

            if (_0x7f7ecc == _0x5cc34c._0x447d00[_0x481484]._0xac7611) return;


            uint256 _0xec1373 = _0x7f7ecc - _0x5cc34c._0x447d00[_0x481484]._0xac7611;
            _0x5cc34c._0x447d00[_0x481484]._0xac7611 = _0x7f7ecc;

            if (_0x5cc34c._0x447d00[_0x481484]._0x456df8 == VoteOption.Yes) {
                _0x5cc34c._0x8d4cff._0xd3f91a += _0xec1373;
            } else if (_0x5cc34c._0x447d00[_0x481484]._0x456df8 == VoteOption.No) {
                _0x5cc34c._0x8d4cff._0x0cec55 += _0xec1373;
            } else {

                _0x5cc34c._0x8d4cff._0x02517b += _0xec1373;
            }
        } else {


            if (_0x5cc34c._0x447d00[_0x481484]._0xac7611 > 0) {

                if (_0x5cc34c._0x447d00[_0x481484]._0x456df8 == VoteOption.Yes) {
                    _0x5cc34c._0x8d4cff._0xd3f91a -= _0x5cc34c._0x447d00[_0x481484]._0xac7611;
                } else if (_0x5cc34c._0x447d00[_0x481484]._0x456df8 == VoteOption.No) {
                    _0x5cc34c._0x8d4cff._0x0cec55 -= _0x5cc34c._0x447d00[_0x481484]._0xac7611;
                } else {

                    _0x5cc34c._0x8d4cff._0x02517b -= _0x5cc34c._0x447d00[_0x481484]._0xac7611;
                }
            }


            if (_0x958747 == VoteOption.Yes) {
                _0x5cc34c._0x8d4cff._0xd3f91a += _0x7f7ecc;
            } else if (_0x958747 == VoteOption.No) {
                _0x5cc34c._0x8d4cff._0x0cec55 += _0x7f7ecc;
            } else {

                _0x5cc34c._0x8d4cff._0x02517b += _0x7f7ecc;
            }
            _0x5cc34c._0x447d00[_0x481484]._0x456df8 = _0x958747;
            _0x5cc34c._0x447d00[_0x481484]._0xac7611 = _0x7f7ecc;
        }

        emit VoteCast(_0x32bd9a, _0x481484, _0x958747, _0x7f7ecc);

        if (_0x5cc34c._0x103ad5._0x5436f0 == VotingMode.EarlyExecution) {
            _0x6c9750(_0x32bd9a, _0xb0c8c5());
        }
    }


    function _0x6d513e(uint256 _0x32bd9a, address _0x481484) external _0xddb48b(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x5cc34c = _0x655b0c[_0x32bd9a];
        if (!_0xc74d3e(_0x5cc34c)) {
            revert VoteRemovalForbidden(_0x32bd9a, _0x481484);
        } else if (_0x5cc34c._0x103ad5._0x5436f0 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x32bd9a, _0x481484);
        } else if (_0x5cc34c._0x447d00[_0x481484]._0xac7611 == 0) {

            return;
        }


        if (_0x5cc34c._0x447d00[_0x481484]._0x456df8 == VoteOption.Yes) {
            _0x5cc34c._0x8d4cff._0xd3f91a -= _0x5cc34c._0x447d00[_0x481484]._0xac7611;
        } else if (_0x5cc34c._0x447d00[_0x481484]._0x456df8 == VoteOption.No) {
            _0x5cc34c._0x8d4cff._0x0cec55 -= _0x5cc34c._0x447d00[_0x481484]._0xac7611;
        }

        else if (_0x5cc34c._0x447d00[_0x481484]._0x456df8 == VoteOption.Abstain) {
            _0x5cc34c._0x8d4cff._0x02517b -= _0x5cc34c._0x447d00[_0x481484]._0xac7611;
        }
        _0x5cc34c._0x447d00[_0x481484]._0xac7611 = 0;

        emit VoteCleared(_0x32bd9a, _0x481484);
    }


    function _0x3c795c(uint256 _0x32bd9a) external view returns (bool) {
        Proposal storage _0x5cc34c = _0x655b0c[_0x32bd9a];
        return _0xc74d3e(_0x5cc34c);
    }


    function _0x1e21d4() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x1e21d4();
    }


    function _0xae46f7() public view override returns (uint256) {
        return IERC20(_0xa25574._0xc0b7c2())._0x1a4022();
    }


    function _0xbb00e3(uint256 _0x32bd9a, address _0x481484) public view returns (uint256) {
        return _0x655b0c[_0x32bd9a]._0x447d00[_0x481484]._0xac7611;
    }


    function _0xcd9258(Proposal storage _0x5cc34c, address _0x481484, VoteOption _0x958747, uint256 _0x7f7ecc)
        internal
        view
        returns (bool)
    {
        uint256 _0xd884de = _0x5cc34c._0x447d00[_0x481484]._0xac7611;


        if (!_0xc74d3e(_0x5cc34c)) {
            return false;
        } else if (_0x958747 == VoteOption.None) {
            return false;
        }

        else if (_0x5cc34c._0x103ad5._0x5436f0 != VotingMode.VoteReplacement) {

            if (_0x7f7ecc <= _0xd884de) {
                return false;
            }

            else if (
                _0x5cc34c._0x447d00[_0x481484]._0x456df8 != VoteOption.None
                    && _0x958747 != _0x5cc34c._0x447d00[_0x481484]._0x456df8
            ) {
                return false;
            }
        }

        else {

            if (_0x7f7ecc == 0 || _0x7f7ecc < _0xd884de) {
                return false;
            }

            else if (_0x7f7ecc == _0xd884de && _0x958747 == _0x5cc34c._0x447d00[_0x481484]._0x456df8) {
                return false;
            }
        }

        return true;
    }

    function _0x6c9750(uint256 _0x32bd9a, address _0x5d4d13) internal {
        if (!_0xf389a0(_0x32bd9a)) {
            return;
        } else if (!_0xd56d4c()._0xa80a7f(address(this), _0x5d4d13, EXECUTE_PROPOSAL_PERMISSION_ID, _0x90ee00())) {
            return;
        }

        _0xe5b420(_0x32bd9a);
    }

    function _0xe5b420(uint256 _0x32bd9a) internal override {
        super._0xe5b420(_0x32bd9a);


        _0xa25574._0xc618f7(_0x32bd9a);
    }


    uint256[50] private __gap;
}