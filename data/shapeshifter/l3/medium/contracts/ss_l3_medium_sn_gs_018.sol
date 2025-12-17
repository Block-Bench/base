// SPDX-License-Identifier: AGPL-3.0-or-later
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

    /// @notice The [ERC-165](https://eips.ethereum.org/EIPS/eip-165) interface ID of the contract.
    bytes4 internal constant LOCK_TO_VOTE_INTERFACE_ID =
        this._0x8f6290.selector ^ this._0x96acb0.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x562d70("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x562d70("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x108bf8, address _0xa8831a);

    error VoteRemovalForbidden(uint256 _0x108bf8, address _0xa8831a);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x2f65c3(
        IDAO _0x149e36,
        ILockManager _0xbc51e4,
        VotingSettings calldata _0x2cec61,
        IPlugin.TargetConfig calldata _0x6bb9f4,
        bytes calldata _0xcc8473
    ) external _0x36516a _0x769004(1) {
        __MajorityVotingBase_init(_0x149e36, _0x2cec61, _0x6bb9f4, _0xcc8473);
        __LockToGovernBase_init(_0xbc51e4);

        emit MembershipContractAnnounced({_0x2560f1: address(_0xbc51e4._0xcf96ca())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0xd8a802(bytes4 _0x5fe3ad)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x5fe3ad == LOCK_TO_VOTE_INTERFACE_ID || _0x5fe3ad == type(ILockToVote)._0xa9e5ed
            || super._0xd8a802(_0x5fe3ad);
    }

    /// @inheritdoc IProposal
    function _0x597e65() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0x96acb0(
        bytes calldata _0xb2379c,
        Action[] memory _0xb4d5d6,
        uint64 _0xf70ca1,
        uint64 _0xc1a21b,
        bytes memory _0x5fac18
    ) external _0x111d7c(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x108bf8) {
        uint256 _0x6c4a01;

        if (_0x5fac18.length != 0) {
            (_0x6c4a01) = abi._0xee5277(_0x5fac18, (uint256));
        }

        if (_0x7b8be1() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0xf70ca1, _0xc1a21b) = _0xf742e6(_0xf70ca1, _0xc1a21b);

        _0x108bf8 = _0xa7a8f1(_0x562d70(abi._0x222b3a(_0xb4d5d6, _0xb2379c)));

        if (_0x345d3b(_0x108bf8)) {
            revert ProposalAlreadyExists(_0x108bf8);
        }

        // Store proposal related information
        Proposal storage _0xcd4f7e = _0xf5bc57[_0x108bf8];

        _0xcd4f7e._0x1d07fe._0x87a0e9 = _0x87a0e9();
        _0xcd4f7e._0x1d07fe._0x264e4a = _0x264e4a();
        _0xcd4f7e._0x1d07fe._0xfb6d8d = _0xf70ca1;
        _0xcd4f7e._0x1d07fe._0x0be217 = _0xc1a21b;
        _0xcd4f7e._0x1d07fe._0x76ebbe = _0x76ebbe();
        _0xcd4f7e._0x1d07fe._0x89456c = _0x89456c();

        _0xcd4f7e._0x1f947b = _0xb0965c();

        // Reduce costs
        if (_0x6c4a01 != 0) {
            _0xcd4f7e._0x60d1b2 = _0x6c4a01;
        }

        for (uint256 i; i < _0xb4d5d6.length;) {
            _0xcd4f7e._0x6f4e7e.push(_0xb4d5d6[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x108bf8, _0xfe2c09(), _0xf70ca1, _0xc1a21b, _0xb2379c, _0xb4d5d6, _0x6c4a01);

        _0x742228._0x2e89e1(_0x108bf8);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0xc41067(uint256 _0x0c25c1, address _0xdc2e58, VoteOption _0x3d4ffb) public view returns (bool) {
        if (!_0x345d3b(_0x0c25c1)) {
            revert NonexistentProposal(_0x0c25c1);
        }

        Proposal storage _0xcd4f7e = _0xf5bc57[_0x0c25c1];
        return _0xb8cc53(_0xcd4f7e, _0xdc2e58, _0x3d4ffb, _0x742228._0x7dbfb5(_0xdc2e58));
    }

    /// @inheritdoc ILockToVote
    function _0xe2b95f(uint256 _0x0c25c1, address _0xdc2e58, VoteOption _0x3d4ffb, uint256 _0x5f960d)
        public
        override
        _0x111d7c(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0xcd4f7e = _0xf5bc57[_0x0c25c1];

        if (!_0xb8cc53(_0xcd4f7e, _0xdc2e58, _0x3d4ffb, _0x5f960d)) {
            revert VoteCastForbidden(_0x0c25c1, _0xdc2e58);
        }

        // Same vote
        if (_0x3d4ffb == _0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6) {
            // Same value, nothing to do
            if (_0x5f960d == _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0x49d1e2 = _0x5f960d - _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;
            _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026 = _0x5f960d;

            if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 == VoteOption.Yes) {
                _0xcd4f7e._0xce78bf._0x5d6ed5 += _0x49d1e2;
            } else if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 == VoteOption.No) {
                _0xcd4f7e._0xce78bf._0xb4ebd5 += _0x49d1e2;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0xcd4f7e._0xce78bf._0xe5429e += _0x49d1e2;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026 > 0) {
                // Undo that vote
                if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 == VoteOption.Yes) {
                    _0xcd4f7e._0xce78bf._0x5d6ed5 -= _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;
                } else if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 == VoteOption.No) {
                    _0xcd4f7e._0xce78bf._0xb4ebd5 -= _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0xcd4f7e._0xce78bf._0xe5429e -= _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;
                }
            }

            // Register the new vote
            if (_0x3d4ffb == VoteOption.Yes) {
                _0xcd4f7e._0xce78bf._0x5d6ed5 += _0x5f960d;
            } else if (_0x3d4ffb == VoteOption.No) {
                _0xcd4f7e._0xce78bf._0xb4ebd5 += _0x5f960d;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0xcd4f7e._0xce78bf._0xe5429e += _0x5f960d;
            }
            _0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 = _0x3d4ffb;
            _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026 = _0x5f960d;
        }

        emit VoteCast(_0x0c25c1, _0xdc2e58, _0x3d4ffb, _0x5f960d);

        if (_0xcd4f7e._0x1d07fe._0x87a0e9 == VotingMode.EarlyExecution) {
            _0xe76c53(_0x0c25c1, _0xfe2c09());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x33168a(uint256 _0x0c25c1, address _0xdc2e58) external _0x111d7c(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0xcd4f7e = _0xf5bc57[_0x0c25c1];
        if (!_0x5e363d(_0xcd4f7e)) {
            revert VoteRemovalForbidden(_0x0c25c1, _0xdc2e58);
        } else if (_0xcd4f7e._0x1d07fe._0x87a0e9 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x0c25c1, _0xdc2e58);
        } else if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 == VoteOption.Yes) {
            _0xcd4f7e._0xce78bf._0x5d6ed5 -= _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;
        } else if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 == VoteOption.No) {
            _0xcd4f7e._0xce78bf._0xb4ebd5 -= _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 == VoteOption.Abstain) {
            _0xcd4f7e._0xce78bf._0xe5429e -= _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;
        }
        _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026 = 0;

        emit VoteCleared(_0x0c25c1, _0xdc2e58);
    }

    /// @inheritdoc ILockToGovernBase
    function _0xb42d04(uint256 _0x0c25c1) external view returns (bool) {
        Proposal storage _0xcd4f7e = _0xf5bc57[_0x0c25c1];
        return _0x5e363d(_0xcd4f7e);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x8f6290() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x8f6290();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x7b8be1() public view override returns (uint256) {
        return IERC20(_0x742228._0xcf96ca())._0x3649b4();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x7f18b0(uint256 _0x0c25c1, address _0xdc2e58) public view returns (uint256) {
        return _0xf5bc57[_0x0c25c1]._0x58a145[_0xdc2e58]._0x6b3026;
    }

    // Internal helpers

    function _0xb8cc53(Proposal storage _0xcd4f7e, address _0xdc2e58, VoteOption _0x3d4ffb, uint256 _0x5f960d)
        internal
        view
        returns (bool)
    {
        uint256 _0xf6e702 = _0xcd4f7e._0x58a145[_0xdc2e58]._0x6b3026;

        // The proposal vote hasn't started or has already ended.
        if (!_0x5e363d(_0xcd4f7e)) {
            return false;
        } else if (_0x3d4ffb == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0xcd4f7e._0x1d07fe._0x87a0e9 != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x5f960d <= _0xf6e702) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6 != VoteOption.None
                    && _0x3d4ffb != _0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x5f960d == 0 || _0x5f960d < _0xf6e702) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x5f960d == _0xf6e702 && _0x3d4ffb == _0xcd4f7e._0x58a145[_0xdc2e58]._0x5a85c6) {
                return false;
            }
        }

        return true;
    }

    function _0xe76c53(uint256 _0x0c25c1, address _0xb7d187) internal {
        if (!_0x4d7509(_0x0c25c1)) {
            return;
        } else if (!_0x33d9fc()._0xa61cf1(address(this), _0xb7d187, EXECUTE_PROPOSAL_PERMISSION_ID, _0x8bd298())) {
            return;
        }

        _0x891b7d(_0x0c25c1);
    }

    function _0x891b7d(uint256 _0x0c25c1) internal override {
        super._0x891b7d(_0x0c25c1);

        // Notify the LockManager to stop tracking this proposal ID
        _0x742228._0x3d7c32(_0x0c25c1);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
