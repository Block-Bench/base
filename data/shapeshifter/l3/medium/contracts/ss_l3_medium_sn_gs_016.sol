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
        this._0x206ed5.selector ^ this._0x39bd9d.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xc5fa4b("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xc5fa4b("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x930e1c, address _0xd0dbaa);

    error VoteRemovalForbidden(uint256 _0x930e1c, address _0xd0dbaa);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x721c50(
        IDAO _0x37bb24,
        ILockManager _0x56297f,
        VotingSettings calldata _0xbff2bd,
        IPlugin.TargetConfig calldata _0x501d6a,
        bytes calldata _0xe04c3d
    ) external _0x94cbfa _0x2500be(1) {
        __MajorityVotingBase_init(_0x37bb24, _0xbff2bd, _0x501d6a, _0xe04c3d);
        __LockToGovernBase_init(_0x56297f);

        emit MembershipContractAnnounced({_0xe51fc4: address(_0x56297f._0x6e6467())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0x6ccd1e(bytes4 _0xa86692)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0xa86692 == LOCK_TO_VOTE_INTERFACE_ID || _0xa86692 == type(ILockToVote)._0xb01ae1
            || super._0x6ccd1e(_0xa86692);
    }

    /// @inheritdoc IProposal
    function _0x560fce() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0x39bd9d(
        bytes calldata _0xed482f,
        Action[] memory _0x718be1,
        uint64 _0xefdd90,
        uint64 _0x36f1d2,
        bytes memory _0x3c49ef
    ) external _0xb17ed3(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x930e1c) {
        uint256 _0x9e799d;

        if (_0x3c49ef.length != 0) {
            (_0x9e799d) = abi._0x551a9a(_0x3c49ef, (uint256));
        }

        if (_0x3f39d5() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0xefdd90, _0x36f1d2) = _0x7e4956(_0xefdd90, _0x36f1d2);

        _0x930e1c = _0xe2d2b3(_0xc5fa4b(abi._0x7b86aa(_0x718be1, _0xed482f)));

        if (_0x9351fb(_0x930e1c)) {
            revert ProposalAlreadyExists(_0x930e1c);
        }

        // Store proposal related information
        Proposal storage _0x61563e = _0x85c361[_0x930e1c];

        _0x61563e._0x4dc395._0x013def = _0x013def();
        _0x61563e._0x4dc395._0x4e5283 = _0x4e5283();
        _0x61563e._0x4dc395._0x1b5750 = _0xefdd90;
        _0x61563e._0x4dc395._0xf14fb4 = _0x36f1d2;
        _0x61563e._0x4dc395._0xa6b83a = _0xa6b83a();
        _0x61563e._0x4dc395._0x6ba993 = _0x6ba993();

        _0x61563e._0xf9a001 = _0x35e98b();

        // Reduce costs
        if (_0x9e799d != 0) {
            _0x61563e._0xcba4df = _0x9e799d;
        }

        for (uint256 i; i < _0x718be1.length;) {
            _0x61563e._0x940cbd.push(_0x718be1[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x930e1c, _0x5a2b8e(), _0xefdd90, _0x36f1d2, _0xed482f, _0x718be1, _0x9e799d);

        _0x6cee3b._0x50f7db(_0x930e1c);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0x5ec5d7(uint256 _0xa8dbf1, address _0x9e57d8, VoteOption _0xcbdd9d) public view returns (bool) {
        if (!_0x9351fb(_0xa8dbf1)) {
            revert NonexistentProposal(_0xa8dbf1);
        }

        Proposal storage _0x61563e = _0x85c361[_0xa8dbf1];
        return _0x7cea10(_0x61563e, _0x9e57d8, _0xcbdd9d, _0x6cee3b._0x6b9d89(_0x9e57d8));
    }

    /// @inheritdoc ILockToVote
    function _0x23dd44(uint256 _0xa8dbf1, address _0x9e57d8, VoteOption _0xcbdd9d, uint256 _0x1a806d)
        public
        override
        _0xb17ed3(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x61563e = _0x85c361[_0xa8dbf1];

        if (!_0x7cea10(_0x61563e, _0x9e57d8, _0xcbdd9d, _0x1a806d)) {
            revert VoteCastForbidden(_0xa8dbf1, _0x9e57d8);
        }

        // Same vote
        if (_0xcbdd9d == _0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1) {
            // Same value, nothing to do
            if (_0x1a806d == _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0x4a25d4 = _0x1a806d - _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;
            _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665 = _0x1a806d;

            if (_0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 == VoteOption.Yes) {
                _0x61563e._0x3cd3c7._0x6caa6d += _0x4a25d4;
            } else if (_0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 == VoteOption.No) {
                _0x61563e._0x3cd3c7._0x714380 += _0x4a25d4;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x61563e._0x3cd3c7._0xbbd8a1 += _0x4a25d4;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665 > 0) {
                // Undo that vote
                if (_0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 == VoteOption.Yes) {
                    _0x61563e._0x3cd3c7._0x6caa6d -= _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;
                } else if (_0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 == VoteOption.No) {
                    _0x61563e._0x3cd3c7._0x714380 -= _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x61563e._0x3cd3c7._0xbbd8a1 -= _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;
                }
            }

            // Register the new vote
            if (_0xcbdd9d == VoteOption.Yes) {
                _0x61563e._0x3cd3c7._0x6caa6d += _0x1a806d;
            } else if (_0xcbdd9d == VoteOption.No) {
                _0x61563e._0x3cd3c7._0x714380 += _0x1a806d;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x61563e._0x3cd3c7._0xbbd8a1 += _0x1a806d;
            }
            _0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 = _0xcbdd9d;
            _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665 = _0x1a806d;
        }

        emit VoteCast(_0xa8dbf1, _0x9e57d8, _0xcbdd9d, _0x1a806d);

        if (_0x61563e._0x4dc395._0x013def == VotingMode.EarlyExecution) {
            _0x97123f(_0xa8dbf1, _0x5a2b8e());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x22efe0(uint256 _0xa8dbf1, address _0x9e57d8) external _0xb17ed3(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x61563e = _0x85c361[_0xa8dbf1];
        if (!_0x590eeb(_0x61563e)) {
            revert VoteRemovalForbidden(_0xa8dbf1, _0x9e57d8);
        } else if (_0x61563e._0x4dc395._0x013def != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0xa8dbf1, _0x9e57d8);
        } else if (_0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 == VoteOption.Yes) {
            _0x61563e._0x3cd3c7._0x6caa6d -= _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;
        } else if (_0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 == VoteOption.No) {
            _0x61563e._0x3cd3c7._0x714380 -= _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 == VoteOption.Abstain) {
            _0x61563e._0x3cd3c7._0xbbd8a1 -= _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;
        }
        _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665 = 0;

        emit VoteCleared(_0xa8dbf1, _0x9e57d8);
    }

    /// @inheritdoc ILockToGovernBase
    function _0xb2e69e(uint256 _0xa8dbf1) external view returns (bool) {
        Proposal storage _0x61563e = _0x85c361[_0xa8dbf1];
        return _0x590eeb(_0x61563e);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x206ed5() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x206ed5();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x3f39d5() public view override returns (uint256) {
        return IERC20(_0x6cee3b._0x6e6467())._0x753e21();
    }

    /// @inheritdoc ILockToGovernBase
    function _0xe05778(uint256 _0xa8dbf1, address _0x9e57d8) public view returns (uint256) {
        return _0x85c361[_0xa8dbf1]._0x57a3c7[_0x9e57d8]._0xfb2665;
    }

    // Internal helpers

    function _0x7cea10(Proposal storage _0x61563e, address _0x9e57d8, VoteOption _0xcbdd9d, uint256 _0x1a806d)
        internal
        view
        returns (bool)
    {
        uint256 _0x09e3b9 = _0x61563e._0x57a3c7[_0x9e57d8]._0xfb2665;

        // The proposal vote hasn't started or has already ended.
        if (!_0x590eeb(_0x61563e)) {
            return false;
        } else if (_0xcbdd9d == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x61563e._0x4dc395._0x013def != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x1a806d <= _0x09e3b9) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1 != VoteOption.None
                    && _0xcbdd9d != _0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x1a806d == 0 || _0x1a806d < _0x09e3b9) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x1a806d == _0x09e3b9 && _0xcbdd9d == _0x61563e._0x57a3c7[_0x9e57d8]._0x4a73d1) {
                return false;
            }
        }

        return true;
    }

    function _0x97123f(uint256 _0xa8dbf1, address _0xc211ed) internal {
        if (!_0x3a06dc(_0xa8dbf1)) {
            return;
        } else if (!_0x2f1940()._0x7b7fd2(address(this), _0xc211ed, EXECUTE_PROPOSAL_PERMISSION_ID, _0xeb3422())) {
            return;
        }

        _0x90c23e(_0xa8dbf1);
    }

    function _0x90c23e(uint256 _0xa8dbf1) internal override {
        super._0x90c23e(_0xa8dbf1);

        // Notify the LockManager to stop tracking this proposal ID
        _0x6cee3b._0xb9f6bc(_0xa8dbf1);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
