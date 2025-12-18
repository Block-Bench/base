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
        this._0x977e1b.selector ^ this._0xa91a28.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xb36e53("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xb36e53("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0xa4eb19, address _0x975fd4);

    error VoteRemovalForbidden(uint256 _0xa4eb19, address _0x975fd4);


    function _0x2a99af(
        IDAO _0x516e1c,
        ILockManager _0x190136,
        VotingSettings calldata _0xc1bfaa,
        IPlugin.TargetConfig calldata _0x885ae2,
        bytes calldata _0xda25e2
    ) external _0x517e8c _0x903acc(1) {
        __MajorityVotingBase_init(_0x516e1c, _0xc1bfaa, _0x885ae2, _0xda25e2);
        __LockToGovernBase_init(_0x190136);

        emit MembershipContractAnnounced({_0x0a8c40: address(_0x190136._0xef33c6())});
    }


    function _0x05865a(bytes4 _0x8c404e)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x8c404e == LOCK_TO_VOTE_INTERFACE_ID || _0x8c404e == type(ILockToVote)._0xc3735f
            || super._0x05865a(_0x8c404e);
    }


    function _0xda5817() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function _0xa91a28(
        bytes calldata _0xa7d0d2,
        Action[] memory _0x549372,
        uint64 _0xdd4f93,
        uint64 _0x7b1bd4,
        bytes memory _0xe77ad8
    ) external _0x4ea18a(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0xa4eb19) {
        uint256 _0xdc4422;

        if (_0xe77ad8.length != 0) {
            (_0xdc4422) = abi._0x18ce72(_0xe77ad8, (uint256));
        }

        if (_0x82d804() == 0) {
            revert NoVotingPower();
        }


        (_0xdd4f93, _0x7b1bd4) = _0x2dae52(_0xdd4f93, _0x7b1bd4);

        _0xa4eb19 = _0x56a8c8(_0xb36e53(abi._0xd06449(_0x549372, _0xa7d0d2)));

        if (_0x33f29f(_0xa4eb19)) {
            revert ProposalAlreadyExists(_0xa4eb19);
        }


        Proposal storage _0x76234e = _0x34405a[_0xa4eb19];

        _0x76234e._0xc6a006._0xbd9cbe = _0xbd9cbe();
        _0x76234e._0xc6a006._0x80aa1e = _0x80aa1e();
        _0x76234e._0xc6a006._0xf5a3b3 = _0xdd4f93;
        _0x76234e._0xc6a006._0x8a3fbb = _0x7b1bd4;
        _0x76234e._0xc6a006._0x4f12f7 = _0x4f12f7();
        _0x76234e._0xc6a006._0x73bbd9 = _0x73bbd9();

        _0x76234e._0x509fd5 = _0x4324b1();


        if (_0xdc4422 != 0) {
            _0x76234e._0x9ca96c = _0xdc4422;
        }

        for (uint256 i; i < _0x549372.length;) {
            _0x76234e._0xc311aa.push(_0x549372[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0xa4eb19, _0xe857c8(), _0xdd4f93, _0x7b1bd4, _0xa7d0d2, _0x549372, _0xdc4422);

        _0xa81c49._0xa3a77e(_0xa4eb19);
    }


    function _0x9e4a6c(uint256 _0xcdb6bc, address _0x300c93, VoteOption _0x6fb618) public view returns (bool) {
        if (!_0x33f29f(_0xcdb6bc)) {
            revert NonexistentProposal(_0xcdb6bc);
        }

        Proposal storage _0x76234e = _0x34405a[_0xcdb6bc];
        return _0x7b5192(_0x76234e, _0x300c93, _0x6fb618, _0xa81c49._0xc425dd(_0x300c93));
    }


    function _0xe433fc(uint256 _0xcdb6bc, address _0x300c93, VoteOption _0x6fb618, uint256 _0x53aec2)
        public
        override
        _0x4ea18a(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x76234e = _0x34405a[_0xcdb6bc];

        if (!_0x7b5192(_0x76234e, _0x300c93, _0x6fb618, _0x53aec2)) {
            revert VoteCastForbidden(_0xcdb6bc, _0x300c93);
        }


        if (_0x6fb618 == _0x76234e._0xa565ef[_0x300c93]._0xfb8c64) {

            if (_0x53aec2 == _0x76234e._0xa565ef[_0x300c93]._0x0184de) return;


            uint256 _0xb15846 = _0x53aec2 - _0x76234e._0xa565ef[_0x300c93]._0x0184de;
            _0x76234e._0xa565ef[_0x300c93]._0x0184de = _0x53aec2;

            if (_0x76234e._0xa565ef[_0x300c93]._0xfb8c64 == VoteOption.Yes) {
                _0x76234e._0xdca5cf._0x5ab9b2 += _0xb15846;
            } else if (_0x76234e._0xa565ef[_0x300c93]._0xfb8c64 == VoteOption.No) {
                _0x76234e._0xdca5cf._0x323f3a += _0xb15846;
            } else {

                _0x76234e._0xdca5cf._0x518278 += _0xb15846;
            }
        } else {


            if (_0x76234e._0xa565ef[_0x300c93]._0x0184de > 0) {

                if (_0x76234e._0xa565ef[_0x300c93]._0xfb8c64 == VoteOption.Yes) {
                    _0x76234e._0xdca5cf._0x5ab9b2 -= _0x76234e._0xa565ef[_0x300c93]._0x0184de;
                } else if (_0x76234e._0xa565ef[_0x300c93]._0xfb8c64 == VoteOption.No) {
                    _0x76234e._0xdca5cf._0x323f3a -= _0x76234e._0xa565ef[_0x300c93]._0x0184de;
                } else {

                    _0x76234e._0xdca5cf._0x518278 -= _0x76234e._0xa565ef[_0x300c93]._0x0184de;
                }
            }


            if (_0x6fb618 == VoteOption.Yes) {
                _0x76234e._0xdca5cf._0x5ab9b2 += _0x53aec2;
            } else if (_0x6fb618 == VoteOption.No) {
                _0x76234e._0xdca5cf._0x323f3a += _0x53aec2;
            } else {

                _0x76234e._0xdca5cf._0x518278 += _0x53aec2;
            }
            _0x76234e._0xa565ef[_0x300c93]._0xfb8c64 = _0x6fb618;
            _0x76234e._0xa565ef[_0x300c93]._0x0184de = _0x53aec2;
        }

        emit VoteCast(_0xcdb6bc, _0x300c93, _0x6fb618, _0x53aec2);

        if (_0x76234e._0xc6a006._0xbd9cbe == VotingMode.EarlyExecution) {
            _0x73708f(_0xcdb6bc, _0xe857c8());
        }
    }


    function _0x9eaefa(uint256 _0xcdb6bc, address _0x300c93) external _0x4ea18a(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x76234e = _0x34405a[_0xcdb6bc];
        if (!_0x438313(_0x76234e)) {
            revert VoteRemovalForbidden(_0xcdb6bc, _0x300c93);
        } else if (_0x76234e._0xc6a006._0xbd9cbe != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0xcdb6bc, _0x300c93);
        } else if (_0x76234e._0xa565ef[_0x300c93]._0x0184de == 0) {

            return;
        }


        if (_0x76234e._0xa565ef[_0x300c93]._0xfb8c64 == VoteOption.Yes) {
            _0x76234e._0xdca5cf._0x5ab9b2 -= _0x76234e._0xa565ef[_0x300c93]._0x0184de;
        } else if (_0x76234e._0xa565ef[_0x300c93]._0xfb8c64 == VoteOption.No) {
            _0x76234e._0xdca5cf._0x323f3a -= _0x76234e._0xa565ef[_0x300c93]._0x0184de;
        }

        else if (_0x76234e._0xa565ef[_0x300c93]._0xfb8c64 == VoteOption.Abstain) {
            _0x76234e._0xdca5cf._0x518278 -= _0x76234e._0xa565ef[_0x300c93]._0x0184de;
        }
        _0x76234e._0xa565ef[_0x300c93]._0x0184de = 0;

        emit VoteCleared(_0xcdb6bc, _0x300c93);
    }


    function _0x9c0269(uint256 _0xcdb6bc) external view returns (bool) {
        Proposal storage _0x76234e = _0x34405a[_0xcdb6bc];
        return _0x438313(_0x76234e);
    }


    function _0x977e1b() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x977e1b();
    }


    function _0x82d804() public view override returns (uint256) {
        return IERC20(_0xa81c49._0xef33c6())._0xc9d4de();
    }


    function _0xb7aa93(uint256 _0xcdb6bc, address _0x300c93) public view returns (uint256) {
        return _0x34405a[_0xcdb6bc]._0xa565ef[_0x300c93]._0x0184de;
    }


    function _0x7b5192(Proposal storage _0x76234e, address _0x300c93, VoteOption _0x6fb618, uint256 _0x53aec2)
        internal
        view
        returns (bool)
    {
        uint256 _0x25e6ef = _0x76234e._0xa565ef[_0x300c93]._0x0184de;


        if (!_0x438313(_0x76234e)) {
            return false;
        } else if (_0x6fb618 == VoteOption.None) {
            return false;
        }

        else if (_0x76234e._0xc6a006._0xbd9cbe != VotingMode.VoteReplacement) {

            if (_0x53aec2 <= _0x25e6ef) {
                return false;
            }

            else if (
                _0x76234e._0xa565ef[_0x300c93]._0xfb8c64 != VoteOption.None
                    && _0x6fb618 != _0x76234e._0xa565ef[_0x300c93]._0xfb8c64
            ) {
                return false;
            }
        }

        else {

            if (_0x53aec2 == 0 || _0x53aec2 < _0x25e6ef) {
                return false;
            }

            else if (_0x53aec2 == _0x25e6ef && _0x6fb618 == _0x76234e._0xa565ef[_0x300c93]._0xfb8c64) {
                return false;
            }
        }

        return true;
    }

    function _0x73708f(uint256 _0xcdb6bc, address _0x2eda9c) internal {
        if (!_0x470806(_0xcdb6bc)) {
            return;
        } else if (!_0xf6847c()._0x00025a(address(this), _0x2eda9c, EXECUTE_PROPOSAL_PERMISSION_ID, _0xa5c489())) {
            return;
        }

        _0xcc8b67(_0xcdb6bc);
    }

    function _0xcc8b67(uint256 _0xcdb6bc) internal override {
        super._0xcc8b67(_0xcdb6bc);


        _0xa81c49._0xc37204(_0xcdb6bc);
    }


    uint256[50] private __gap;
}