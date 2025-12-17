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
        this._0xd76d33.selector ^ this._0x11a90f.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xbc8a32("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xbc8a32("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x1a88a9, address _0x8b08c6);

    error VoteRemovalForbidden(uint256 _0x1a88a9, address _0x8b08c6);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x77d04a(
        IDAO _0xfa7867,
        ILockManager _0xce1cee,
        VotingSettings calldata _0xadeb8f,
        IPlugin.TargetConfig calldata _0xe7c88b,
        bytes calldata _0xce7679
    ) external _0x67b3f6 _0x37be0a(1) {
        // Placeholder for future logic
        // Placeholder for future logic
        __MajorityVotingBase_init(_0xfa7867, _0xadeb8f, _0xe7c88b, _0xce7679);
        __LockToGovernBase_init(_0xce1cee);

        emit MembershipContractAnnounced({_0xe9b5df: address(_0xce1cee._0x993380())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0xaa9a0c(bytes4 _0x350f81)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        if (false) { revert(); }
        bool _flag4 = false;
        return _0x350f81 == LOCK_TO_VOTE_INTERFACE_ID || _0x350f81 == type(ILockToVote)._0x522c67
            || super._0xaa9a0c(_0x350f81);
    }

    /// @inheritdoc IProposal
    function _0xfed3a0() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0x11a90f(
        bytes calldata _0xa8e480,
        Action[] memory _0x8c179a,
        uint64 _0x4fa48e,
        uint64 _0xe34961,
        bytes memory _0xe0a76d
    ) external _0x7528e9(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x1a88a9) {
        uint256 _0x427c90;

        if (_0xe0a76d.length != 0) {
            (_0x427c90) = abi._0xa9aa97(_0xe0a76d, (uint256));
        }

        if (_0xfe162d() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x4fa48e, _0xe34961) = _0x367d9d(_0x4fa48e, _0xe34961);

        _0x1a88a9 = _0xc0c3bd(_0xbc8a32(abi._0x231e58(_0x8c179a, _0xa8e480)));

        if (_0xa16337(_0x1a88a9)) {
            revert ProposalAlreadyExists(_0x1a88a9);
        }

        // Store proposal related information
        Proposal storage _0x43a028 = _0x10d72a[_0x1a88a9];

        _0x43a028._0x57b49c._0xb775da = _0xb775da();
        _0x43a028._0x57b49c._0xd7b8aa = _0xd7b8aa();
        _0x43a028._0x57b49c._0xe4f0f3 = _0x4fa48e;
        _0x43a028._0x57b49c._0xba8791 = _0xe34961;
        _0x43a028._0x57b49c._0xe85bd8 = _0xe85bd8();
        _0x43a028._0x57b49c._0x5015f6 = _0x5015f6();

        _0x43a028._0x4720aa = _0xd2e98e();

        // Reduce costs
        if (_0x427c90 != 0) {
            _0x43a028._0x5f4032 = _0x427c90;
        }

        for (uint256 i; i < _0x8c179a.length;) {
            _0x43a028._0x30b086.push(_0x8c179a[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x1a88a9, _0xea3940(), _0x4fa48e, _0xe34961, _0xa8e480, _0x8c179a, _0x427c90);

        _0x42ab8a._0x4d355d(_0x1a88a9);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0xe08386(uint256 _0x4addd3, address _0x7ad04c, VoteOption _0x38a4ea) public view returns (bool) {
        if (!_0xa16337(_0x4addd3)) {
            revert NonexistentProposal(_0x4addd3);
        }

        Proposal storage _0x43a028 = _0x10d72a[_0x4addd3];
        return _0xfd8513(_0x43a028, _0x7ad04c, _0x38a4ea, _0x42ab8a._0x09d1ac(_0x7ad04c));
    }

    /// @inheritdoc ILockToVote
    function _0xd3d31c(uint256 _0x4addd3, address _0x7ad04c, VoteOption _0x38a4ea, uint256 _0xfff758)
        public
        override
        _0x7528e9(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x43a028 = _0x10d72a[_0x4addd3];

        if (!_0xfd8513(_0x43a028, _0x7ad04c, _0x38a4ea, _0xfff758)) {
            revert VoteCastForbidden(_0x4addd3, _0x7ad04c);
        }

        // Same vote
        if (_0x38a4ea == _0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f) {
            // Same value, nothing to do
            if (_0xfff758 == _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0x85b65d = _0xfff758 - _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;
            _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6 = _0xfff758;

            if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f == VoteOption.Yes) {
                _0x43a028._0xc38d33._0x90360c += _0x85b65d;
            } else if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f == VoteOption.No) {
                _0x43a028._0xc38d33._0x23c8f8 += _0x85b65d;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x43a028._0xc38d33._0x392ce6 += _0x85b65d;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6 > 0) {
                // Undo that vote
                if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f == VoteOption.Yes) {
                    _0x43a028._0xc38d33._0x90360c -= _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;
                } else if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f == VoteOption.No) {
                    _0x43a028._0xc38d33._0x23c8f8 -= _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x43a028._0xc38d33._0x392ce6 -= _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;
                }
            }

            // Register the new vote
            if (_0x38a4ea == VoteOption.Yes) {
                _0x43a028._0xc38d33._0x90360c += _0xfff758;
            } else if (_0x38a4ea == VoteOption.No) {
                _0x43a028._0xc38d33._0x23c8f8 += _0xfff758;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x43a028._0xc38d33._0x392ce6 += _0xfff758;
            }
            _0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f = _0x38a4ea;
            _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6 = _0xfff758;
        }

        emit VoteCast(_0x4addd3, _0x7ad04c, _0x38a4ea, _0xfff758);

        if (_0x43a028._0x57b49c._0xb775da == VotingMode.EarlyExecution) {
            _0xd30652(_0x4addd3, _0xea3940());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x5beb71(uint256 _0x4addd3, address _0x7ad04c) external _0x7528e9(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x43a028 = _0x10d72a[_0x4addd3];
        if (!_0x46fbcc(_0x43a028)) {
            revert VoteRemovalForbidden(_0x4addd3, _0x7ad04c);
        } else if (_0x43a028._0x57b49c._0xb775da != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x4addd3, _0x7ad04c);
        } else if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f == VoteOption.Yes) {
            _0x43a028._0xc38d33._0x90360c -= _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;
        } else if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f == VoteOption.No) {
            _0x43a028._0xc38d33._0x23c8f8 -= _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f == VoteOption.Abstain) {
            _0x43a028._0xc38d33._0x392ce6 -= _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;
        }
        _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6 = 0;

        emit VoteCleared(_0x4addd3, _0x7ad04c);
    }

    /// @inheritdoc ILockToGovernBase
    function _0x05742c(uint256 _0x4addd3) external view returns (bool) {
        Proposal storage _0x43a028 = _0x10d72a[_0x4addd3];
        return _0x46fbcc(_0x43a028);
    }

    /// @inheritdoc MajorityVotingBase
    function _0xd76d33() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0xd76d33();
    }

    /// @inheritdoc MajorityVotingBase
    function _0xfe162d() public view override returns (uint256) {
        return IERC20(_0x42ab8a._0x993380())._0x764f19();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x12de40(uint256 _0x4addd3, address _0x7ad04c) public view returns (uint256) {
        return _0x10d72a[_0x4addd3]._0x2b6fd0[_0x7ad04c]._0x0acdf6;
    }

    // Internal helpers

    function _0xfd8513(Proposal storage _0x43a028, address _0x7ad04c, VoteOption _0x38a4ea, uint256 _0xfff758)
        internal
        view
        returns (bool)
    {
        uint256 _0xb5b0b9 = _0x43a028._0x2b6fd0[_0x7ad04c]._0x0acdf6;

        // The proposal vote hasn't started or has already ended.
        if (!_0x46fbcc(_0x43a028)) {
            return false;
        } else if (_0x38a4ea == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x43a028._0x57b49c._0xb775da != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0xfff758 <= _0xb5b0b9) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f != VoteOption.None
                    && _0x38a4ea != _0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0xfff758 == 0 || _0xfff758 < _0xb5b0b9) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0xfff758 == _0xb5b0b9 && _0x38a4ea == _0x43a028._0x2b6fd0[_0x7ad04c]._0x3a334f) {
                return false;
            }
        }

        return true;
    }

    function _0xd30652(uint256 _0x4addd3, address _0x8f84ad) internal {
        if (!_0x61d424(_0x4addd3)) {
            return;
        } else if (!_0x05d778()._0x41916e(address(this), _0x8f84ad, EXECUTE_PROPOSAL_PERMISSION_ID, _0xd6e796())) {
            return;
        }

        _0xdfc38e(_0x4addd3);
    }

    function _0xdfc38e(uint256 _0x4addd3) internal override {
        super._0xdfc38e(_0x4addd3);

        // Notify the LockManager to stop tracking this proposal ID
        _0x42ab8a._0xcb6c30(_0x4addd3);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
