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
        this._0x5a9083.selector ^ this._0xb5021a.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xe87147("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xe87147("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x40db93, address _0xf18d07);

    error VoteRemovalForbidden(uint256 _0x40db93, address _0xf18d07);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0xacf5ea(
        IDAO _0x91b21f,
        ILockManager _0xae109b,
        VotingSettings calldata _0x7860f8,
        IPlugin.TargetConfig calldata _0x260134,
        bytes calldata _0x7e538b
    ) external _0x7e4ae3 _0xbdecc9(1) {
        __MajorityVotingBase_init(_0x91b21f, _0x7860f8, _0x260134, _0x7e538b);
        __LockToGovernBase_init(_0xae109b);

        emit MembershipContractAnnounced({_0xab327d: address(_0xae109b._0x62b800())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0xe1bee4(bytes4 _0xd9a130)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0xd9a130 == LOCK_TO_VOTE_INTERFACE_ID || _0xd9a130 == type(ILockToVote)._0xaf950d
            || super._0xe1bee4(_0xd9a130);
    }

    /// @inheritdoc IProposal
    function _0x933821() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0xb5021a(
        bytes calldata _0x82696e,
        Action[] memory _0x698e0c,
        uint64 _0x5bae81,
        uint64 _0x6fd8d2,
        bytes memory _0xc8192e
    ) external _0xcaa580(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x40db93) {
        uint256 _0x5a9ab9;

        if (_0xc8192e.length != 0) {
            (_0x5a9ab9) = abi._0x35e858(_0xc8192e, (uint256));
        }

        if (_0x7d6e3f() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x5bae81, _0x6fd8d2) = _0x874a24(_0x5bae81, _0x6fd8d2);

        _0x40db93 = _0x47133b(_0xe87147(abi._0xf31978(_0x698e0c, _0x82696e)));

        if (_0x4e3117(_0x40db93)) {
            revert ProposalAlreadyExists(_0x40db93);
        }

        // Store proposal related information
        Proposal storage _0x76ec9a = _0xde62bc[_0x40db93];

        _0x76ec9a._0x6ac56b._0xc09d2e = _0xc09d2e();
        _0x76ec9a._0x6ac56b._0xcd2aec = _0xcd2aec();
        _0x76ec9a._0x6ac56b._0x214599 = _0x5bae81;
        _0x76ec9a._0x6ac56b._0x8b26ff = _0x6fd8d2;
        _0x76ec9a._0x6ac56b._0x18b422 = _0x18b422();
        _0x76ec9a._0x6ac56b._0x9ba35d = _0x9ba35d();

        _0x76ec9a._0x83e14a = _0xb4924e();

        // Reduce costs
        if (_0x5a9ab9 != 0) {
            _0x76ec9a._0xb43875 = _0x5a9ab9;
        }

        for (uint256 i; i < _0x698e0c.length;) {
            _0x76ec9a._0x1cf768.push(_0x698e0c[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x40db93, _0xb45899(), _0x5bae81, _0x6fd8d2, _0x82696e, _0x698e0c, _0x5a9ab9);

        _0x8b3f24._0x419568(_0x40db93);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0x2e452f(uint256 _0xfe72fa, address _0x377fad, VoteOption _0x537990) public view returns (bool) {
        if (!_0x4e3117(_0xfe72fa)) {
            revert NonexistentProposal(_0xfe72fa);
        }

        Proposal storage _0x76ec9a = _0xde62bc[_0xfe72fa];
        return _0x93a609(_0x76ec9a, _0x377fad, _0x537990, _0x8b3f24._0xfd0913(_0x377fad));
    }

    /// @inheritdoc ILockToVote
    function _0x43b086(uint256 _0xfe72fa, address _0x377fad, VoteOption _0x537990, uint256 _0x08862c)
        public
        override
        _0xcaa580(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x76ec9a = _0xde62bc[_0xfe72fa];

        if (!_0x93a609(_0x76ec9a, _0x377fad, _0x537990, _0x08862c)) {
            revert VoteCastForbidden(_0xfe72fa, _0x377fad);
        }

        // Same vote
        if (_0x537990 == _0x76ec9a._0x193f34[_0x377fad]._0xbf001c) {
            // Same value, nothing to do
            if (_0x08862c == _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0xff7522 = _0x08862c - _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;
            _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5 = _0x08862c;

            if (_0x76ec9a._0x193f34[_0x377fad]._0xbf001c == VoteOption.Yes) {
                _0x76ec9a._0x14cd0e._0xd9020c += _0xff7522;
            } else if (_0x76ec9a._0x193f34[_0x377fad]._0xbf001c == VoteOption.No) {
                _0x76ec9a._0x14cd0e._0x2b37a1 += _0xff7522;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x76ec9a._0x14cd0e._0xe04d07 += _0xff7522;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x76ec9a._0x193f34[_0x377fad]._0x2f95a5 > 0) {
                // Undo that vote
                if (_0x76ec9a._0x193f34[_0x377fad]._0xbf001c == VoteOption.Yes) {
                    _0x76ec9a._0x14cd0e._0xd9020c -= _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;
                } else if (_0x76ec9a._0x193f34[_0x377fad]._0xbf001c == VoteOption.No) {
                    _0x76ec9a._0x14cd0e._0x2b37a1 -= _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x76ec9a._0x14cd0e._0xe04d07 -= _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;
                }
            }

            // Register the new vote
            if (_0x537990 == VoteOption.Yes) {
                _0x76ec9a._0x14cd0e._0xd9020c += _0x08862c;
            } else if (_0x537990 == VoteOption.No) {
                _0x76ec9a._0x14cd0e._0x2b37a1 += _0x08862c;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x76ec9a._0x14cd0e._0xe04d07 += _0x08862c;
            }
            _0x76ec9a._0x193f34[_0x377fad]._0xbf001c = _0x537990;
            _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5 = _0x08862c;
        }

        emit VoteCast(_0xfe72fa, _0x377fad, _0x537990, _0x08862c);

        if (_0x76ec9a._0x6ac56b._0xc09d2e == VotingMode.EarlyExecution) {
            _0x19b149(_0xfe72fa, _0xb45899());
        }
    }

    /// @inheritdoc ILockToVote
    function _0xa1b0c9(uint256 _0xfe72fa, address _0x377fad) external _0xcaa580(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x76ec9a = _0xde62bc[_0xfe72fa];
        if (!_0x2b6fb9(_0x76ec9a)) {
            revert VoteRemovalForbidden(_0xfe72fa, _0x377fad);
        } else if (_0x76ec9a._0x6ac56b._0xc09d2e != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0xfe72fa, _0x377fad);
        } else if (_0x76ec9a._0x193f34[_0x377fad]._0x2f95a5 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x76ec9a._0x193f34[_0x377fad]._0xbf001c == VoteOption.Yes) {
            _0x76ec9a._0x14cd0e._0xd9020c -= _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;
        } else if (_0x76ec9a._0x193f34[_0x377fad]._0xbf001c == VoteOption.No) {
            _0x76ec9a._0x14cd0e._0x2b37a1 -= _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x76ec9a._0x193f34[_0x377fad]._0xbf001c == VoteOption.Abstain) {
            _0x76ec9a._0x14cd0e._0xe04d07 -= _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;
        }
        _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5 = 0;

        emit VoteCleared(_0xfe72fa, _0x377fad);
    }

    /// @inheritdoc ILockToGovernBase
    function _0xcad5da(uint256 _0xfe72fa) external view returns (bool) {
        Proposal storage _0x76ec9a = _0xde62bc[_0xfe72fa];
        return _0x2b6fb9(_0x76ec9a);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x5a9083() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x5a9083();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x7d6e3f() public view override returns (uint256) {
        return IERC20(_0x8b3f24._0x62b800())._0xc40b4c();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x836b5e(uint256 _0xfe72fa, address _0x377fad) public view returns (uint256) {
        return _0xde62bc[_0xfe72fa]._0x193f34[_0x377fad]._0x2f95a5;
    }

    // Internal helpers

    function _0x93a609(Proposal storage _0x76ec9a, address _0x377fad, VoteOption _0x537990, uint256 _0x08862c)
        internal
        view
        returns (bool)
    {
        uint256 _0x770132 = _0x76ec9a._0x193f34[_0x377fad]._0x2f95a5;

        // The proposal vote hasn't started or has already ended.
        if (!_0x2b6fb9(_0x76ec9a)) {
            return false;
        } else if (_0x537990 == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x76ec9a._0x6ac56b._0xc09d2e != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x08862c <= _0x770132) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x76ec9a._0x193f34[_0x377fad]._0xbf001c != VoteOption.None
                    && _0x537990 != _0x76ec9a._0x193f34[_0x377fad]._0xbf001c
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x08862c == 0 || _0x08862c < _0x770132) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x08862c == _0x770132 && _0x537990 == _0x76ec9a._0x193f34[_0x377fad]._0xbf001c) {
                return false;
            }
        }

        return true;
    }

    function _0x19b149(uint256 _0xfe72fa, address _0x2ebcc5) internal {
        if (!_0x9a0a3f(_0xfe72fa)) {
            return;
        } else if (!_0x84617c()._0x56129b(address(this), _0x2ebcc5, EXECUTE_PROPOSAL_PERMISSION_ID, _0x69f109())) {
            return;
        }

        _0x5dc56d(_0xfe72fa);
    }

    function _0x5dc56d(uint256 _0xfe72fa) internal override {
        super._0x5dc56d(_0xfe72fa);

        // Notify the LockManager to stop tracking this proposal ID
        _0x8b3f24._0xc5cdbf(_0xfe72fa);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
