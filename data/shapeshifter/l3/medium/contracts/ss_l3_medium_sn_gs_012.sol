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
        this._0x6f37fc.selector ^ this._0xdded6b.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xd0fcdc("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xd0fcdc("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x8e3188, address _0xbc35d3);

    error VoteRemovalForbidden(uint256 _0x8e3188, address _0xbc35d3);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x8bc2df(
        IDAO _0x22821b,
        ILockManager _0xd42d8c,
        VotingSettings calldata _0x2e3e2b,
        IPlugin.TargetConfig calldata _0x99c8ca,
        bytes calldata _0xb71175
    ) external _0xa6e5e0 _0x12f6b4(1) {
        __MajorityVotingBase_init(_0x22821b, _0x2e3e2b, _0x99c8ca, _0xb71175);
        __LockToGovernBase_init(_0xd42d8c);

        emit MembershipContractAnnounced({_0x19d064: address(_0xd42d8c._0x4c32b6())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0xda98e9(bytes4 _0x515b79)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x515b79 == LOCK_TO_VOTE_INTERFACE_ID || _0x515b79 == type(ILockToVote)._0xa021e9
            || super._0xda98e9(_0x515b79);
    }

    /// @inheritdoc IProposal
    function _0x540e56() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0xdded6b(
        bytes calldata _0xe94ae7,
        Action[] memory _0xaf3c33,
        uint64 _0xe85ae5,
        uint64 _0xebe426,
        bytes memory _0xc716bd
    ) external _0xe143ec(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x8e3188) {
        uint256 _0xbc918c;

        if (_0xc716bd.length != 0) {
            (_0xbc918c) = abi._0x7d4a11(_0xc716bd, (uint256));
        }

        if (_0x2a759b() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0xe85ae5, _0xebe426) = _0xbe7f56(_0xe85ae5, _0xebe426);

        _0x8e3188 = _0xfd530b(_0xd0fcdc(abi._0x3e2dce(_0xaf3c33, _0xe94ae7)));

        if (_0x5a6d31(_0x8e3188)) {
            revert ProposalAlreadyExists(_0x8e3188);
        }

        // Store proposal related information
        Proposal storage _0x85d638 = _0xb36b3d[_0x8e3188];

        _0x85d638._0xedb967._0x4690b4 = _0x4690b4();
        _0x85d638._0xedb967._0xca663e = _0xca663e();
        _0x85d638._0xedb967._0x7755e4 = _0xe85ae5;
        _0x85d638._0xedb967._0x8116cd = _0xebe426;
        _0x85d638._0xedb967._0xea3c57 = _0xea3c57();
        _0x85d638._0xedb967._0x2d35bb = _0x2d35bb();

        _0x85d638._0x8503e7 = _0x7636ce();

        // Reduce costs
        if (_0xbc918c != 0) {
            _0x85d638._0x4ed4f2 = _0xbc918c;
        }

        for (uint256 i; i < _0xaf3c33.length;) {
            _0x85d638._0xfabc5e.push(_0xaf3c33[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x8e3188, _0xdb61aa(), _0xe85ae5, _0xebe426, _0xe94ae7, _0xaf3c33, _0xbc918c);

        _0x074297._0x522d1d(_0x8e3188);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0xdfd18d(uint256 _0xde253d, address _0xccf85d, VoteOption _0xbd7ab0) public view returns (bool) {
        if (!_0x5a6d31(_0xde253d)) {
            revert NonexistentProposal(_0xde253d);
        }

        Proposal storage _0x85d638 = _0xb36b3d[_0xde253d];
        return _0x29d9af(_0x85d638, _0xccf85d, _0xbd7ab0, _0x074297._0x6ba702(_0xccf85d));
    }

    /// @inheritdoc ILockToVote
    function _0x60b8f9(uint256 _0xde253d, address _0xccf85d, VoteOption _0xbd7ab0, uint256 _0x0d2e79)
        public
        override
        _0xe143ec(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x85d638 = _0xb36b3d[_0xde253d];

        if (!_0x29d9af(_0x85d638, _0xccf85d, _0xbd7ab0, _0x0d2e79)) {
            revert VoteCastForbidden(_0xde253d, _0xccf85d);
        }

        // Same vote
        if (_0xbd7ab0 == _0x85d638._0x020b39[_0xccf85d]._0xb4c6ef) {
            // Same value, nothing to do
            if (_0x0d2e79 == _0x85d638._0x020b39[_0xccf85d]._0xd90be0) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0xdef05b = _0x0d2e79 - _0x85d638._0x020b39[_0xccf85d]._0xd90be0;
            _0x85d638._0x020b39[_0xccf85d]._0xd90be0 = _0x0d2e79;

            if (_0x85d638._0x020b39[_0xccf85d]._0xb4c6ef == VoteOption.Yes) {
                _0x85d638._0x3960f4._0x621a4f += _0xdef05b;
            } else if (_0x85d638._0x020b39[_0xccf85d]._0xb4c6ef == VoteOption.No) {
                _0x85d638._0x3960f4._0xdc45f9 += _0xdef05b;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x85d638._0x3960f4._0x780c1c += _0xdef05b;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x85d638._0x020b39[_0xccf85d]._0xd90be0 > 0) {
                // Undo that vote
                if (_0x85d638._0x020b39[_0xccf85d]._0xb4c6ef == VoteOption.Yes) {
                    _0x85d638._0x3960f4._0x621a4f -= _0x85d638._0x020b39[_0xccf85d]._0xd90be0;
                } else if (_0x85d638._0x020b39[_0xccf85d]._0xb4c6ef == VoteOption.No) {
                    _0x85d638._0x3960f4._0xdc45f9 -= _0x85d638._0x020b39[_0xccf85d]._0xd90be0;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x85d638._0x3960f4._0x780c1c -= _0x85d638._0x020b39[_0xccf85d]._0xd90be0;
                }
            }

            // Register the new vote
            if (_0xbd7ab0 == VoteOption.Yes) {
                _0x85d638._0x3960f4._0x621a4f += _0x0d2e79;
            } else if (_0xbd7ab0 == VoteOption.No) {
                _0x85d638._0x3960f4._0xdc45f9 += _0x0d2e79;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x85d638._0x3960f4._0x780c1c += _0x0d2e79;
            }
            _0x85d638._0x020b39[_0xccf85d]._0xb4c6ef = _0xbd7ab0;
            _0x85d638._0x020b39[_0xccf85d]._0xd90be0 = _0x0d2e79;
        }

        emit VoteCast(_0xde253d, _0xccf85d, _0xbd7ab0, _0x0d2e79);

        if (_0x85d638._0xedb967._0x4690b4 == VotingMode.EarlyExecution) {
            _0x17a091(_0xde253d, _0xdb61aa());
        }
    }

    /// @inheritdoc ILockToVote
    function _0xc011d4(uint256 _0xde253d, address _0xccf85d) external _0xe143ec(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x85d638 = _0xb36b3d[_0xde253d];
        if (!_0xbe2b84(_0x85d638)) {
            revert VoteRemovalForbidden(_0xde253d, _0xccf85d);
        } else if (_0x85d638._0xedb967._0x4690b4 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0xde253d, _0xccf85d);
        } else if (_0x85d638._0x020b39[_0xccf85d]._0xd90be0 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x85d638._0x020b39[_0xccf85d]._0xb4c6ef == VoteOption.Yes) {
            _0x85d638._0x3960f4._0x621a4f -= _0x85d638._0x020b39[_0xccf85d]._0xd90be0;
        } else if (_0x85d638._0x020b39[_0xccf85d]._0xb4c6ef == VoteOption.No) {
            _0x85d638._0x3960f4._0xdc45f9 -= _0x85d638._0x020b39[_0xccf85d]._0xd90be0;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x85d638._0x020b39[_0xccf85d]._0xb4c6ef == VoteOption.Abstain) {
            _0x85d638._0x3960f4._0x780c1c -= _0x85d638._0x020b39[_0xccf85d]._0xd90be0;
        }
        _0x85d638._0x020b39[_0xccf85d]._0xd90be0 = 0;

        emit VoteCleared(_0xde253d, _0xccf85d);
    }

    /// @inheritdoc ILockToGovernBase
    function _0xba6d92(uint256 _0xde253d) external view returns (bool) {
        Proposal storage _0x85d638 = _0xb36b3d[_0xde253d];
        return _0xbe2b84(_0x85d638);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x6f37fc() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x6f37fc();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x2a759b() public view override returns (uint256) {
        return IERC20(_0x074297._0x4c32b6())._0xa69d9a();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x155035(uint256 _0xde253d, address _0xccf85d) public view returns (uint256) {
        return _0xb36b3d[_0xde253d]._0x020b39[_0xccf85d]._0xd90be0;
    }

    // Internal helpers

    function _0x29d9af(Proposal storage _0x85d638, address _0xccf85d, VoteOption _0xbd7ab0, uint256 _0x0d2e79)
        internal
        view
        returns (bool)
    {
        uint256 _0xc63fb9 = _0x85d638._0x020b39[_0xccf85d]._0xd90be0;

        // The proposal vote hasn't started or has already ended.
        if (!_0xbe2b84(_0x85d638)) {
            return false;
        } else if (_0xbd7ab0 == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x85d638._0xedb967._0x4690b4 != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x0d2e79 <= _0xc63fb9) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x85d638._0x020b39[_0xccf85d]._0xb4c6ef != VoteOption.None
                    && _0xbd7ab0 != _0x85d638._0x020b39[_0xccf85d]._0xb4c6ef
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x0d2e79 == 0 || _0x0d2e79 < _0xc63fb9) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x0d2e79 == _0xc63fb9 && _0xbd7ab0 == _0x85d638._0x020b39[_0xccf85d]._0xb4c6ef) {
                return false;
            }
        }

        return true;
    }

    function _0x17a091(uint256 _0xde253d, address _0x7f96e1) internal {
        if (!_0x84222f(_0xde253d)) {
            return;
        } else if (!_0x8c8b85()._0x0ede68(address(this), _0x7f96e1, EXECUTE_PROPOSAL_PERMISSION_ID, _0x69d203())) {
            return;
        }

        _0x95e7c5(_0xde253d);
    }

    function _0x95e7c5(uint256 _0xde253d) internal override {
        super._0x95e7c5(_0xde253d);

        // Notify the LockManager to stop tracking this proposal ID
        _0x074297._0xc7d0be(_0xde253d);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
