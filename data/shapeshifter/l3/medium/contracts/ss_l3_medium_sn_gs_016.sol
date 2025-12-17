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
        this._0xd9265b.selector ^ this._0xa5cdd5.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x3d1aad("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x3d1aad("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0xec3996, address _0xc9c953);

    error VoteRemovalForbidden(uint256 _0xec3996, address _0xc9c953);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x702df7(
        IDAO _0x5902b8,
        ILockManager _0xbcd401,
        VotingSettings calldata _0x32e59b,
        IPlugin.TargetConfig calldata _0x71f57a,
        bytes calldata _0x637302
    ) external _0x90db51 _0x5bd88c(1) {
        __MajorityVotingBase_init(_0x5902b8, _0x32e59b, _0x71f57a, _0x637302);
        __LockToGovernBase_init(_0xbcd401);

        emit MembershipContractAnnounced({_0x9cff11: address(_0xbcd401._0xc5e18e())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0x4adbfc(bytes4 _0x7ea1a4)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x7ea1a4 == LOCK_TO_VOTE_INTERFACE_ID || _0x7ea1a4 == type(ILockToVote)._0xf2592e
            || super._0x4adbfc(_0x7ea1a4);
    }

    /// @inheritdoc IProposal
    function _0x463d53() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0xa5cdd5(
        bytes calldata _0xaab115,
        Action[] memory _0x00e78c,
        uint64 _0x27f50d,
        uint64 _0x3d1967,
        bytes memory _0x0d6606
    ) external _0x78009e(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0xec3996) {
        uint256 _0x14577c;

        if (_0x0d6606.length != 0) {
            (_0x14577c) = abi._0x4cecce(_0x0d6606, (uint256));
        }

        if (_0x7c0d6d() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x27f50d, _0x3d1967) = _0xd6353f(_0x27f50d, _0x3d1967);

        _0xec3996 = _0x2b50b9(_0x3d1aad(abi._0x0dd26a(_0x00e78c, _0xaab115)));

        if (_0xa2889a(_0xec3996)) {
            revert ProposalAlreadyExists(_0xec3996);
        }

        // Store proposal related information
        Proposal storage _0x03bb67 = _0x00ee96[_0xec3996];

        _0x03bb67._0x1f0233._0x2fa94f = _0x2fa94f();
        _0x03bb67._0x1f0233._0xa99611 = _0xa99611();
        _0x03bb67._0x1f0233._0xefae6e = _0x27f50d;
        _0x03bb67._0x1f0233._0xf8f367 = _0x3d1967;
        _0x03bb67._0x1f0233._0xa2dd3f = _0xa2dd3f();
        _0x03bb67._0x1f0233._0xf74622 = _0xf74622();

        _0x03bb67._0x86a212 = _0x42b21a();

        // Reduce costs
        if (_0x14577c != 0) {
            _0x03bb67._0xdc4d02 = _0x14577c;
        }

        for (uint256 i; i < _0x00e78c.length;) {
            _0x03bb67._0x9af0f5.push(_0x00e78c[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0xec3996, _0x5539c0(), _0x27f50d, _0x3d1967, _0xaab115, _0x00e78c, _0x14577c);

        _0xa35adc._0x4459ca(_0xec3996);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0x0ebfb5(uint256 _0x35ae6e, address _0x3269a5, VoteOption _0x77489c) public view returns (bool) {
        if (!_0xa2889a(_0x35ae6e)) {
            revert NonexistentProposal(_0x35ae6e);
        }

        Proposal storage _0x03bb67 = _0x00ee96[_0x35ae6e];
        return _0x8dd973(_0x03bb67, _0x3269a5, _0x77489c, _0xa35adc._0xf99950(_0x3269a5));
    }

    /// @inheritdoc ILockToVote
    function _0x3ca628(uint256 _0x35ae6e, address _0x3269a5, VoteOption _0x77489c, uint256 _0xe934ce)
        public
        override
        _0x78009e(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x03bb67 = _0x00ee96[_0x35ae6e];

        if (!_0x8dd973(_0x03bb67, _0x3269a5, _0x77489c, _0xe934ce)) {
            revert VoteCastForbidden(_0x35ae6e, _0x3269a5);
        }

        // Same vote
        if (_0x77489c == _0x03bb67._0xd8adb6[_0x3269a5]._0x943107) {
            // Same value, nothing to do
            if (_0xe934ce == _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0xcbcbf8 = _0xe934ce - _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;
            _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61 = _0xe934ce;

            if (_0x03bb67._0xd8adb6[_0x3269a5]._0x943107 == VoteOption.Yes) {
                _0x03bb67._0x052bae._0xa8af7c += _0xcbcbf8;
            } else if (_0x03bb67._0xd8adb6[_0x3269a5]._0x943107 == VoteOption.No) {
                _0x03bb67._0x052bae._0xbd57af += _0xcbcbf8;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x03bb67._0x052bae._0xbbfe01 += _0xcbcbf8;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61 > 0) {
                // Undo that vote
                if (_0x03bb67._0xd8adb6[_0x3269a5]._0x943107 == VoteOption.Yes) {
                    _0x03bb67._0x052bae._0xa8af7c -= _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;
                } else if (_0x03bb67._0xd8adb6[_0x3269a5]._0x943107 == VoteOption.No) {
                    _0x03bb67._0x052bae._0xbd57af -= _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x03bb67._0x052bae._0xbbfe01 -= _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;
                }
            }

            // Register the new vote
            if (_0x77489c == VoteOption.Yes) {
                _0x03bb67._0x052bae._0xa8af7c += _0xe934ce;
            } else if (_0x77489c == VoteOption.No) {
                _0x03bb67._0x052bae._0xbd57af += _0xe934ce;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x03bb67._0x052bae._0xbbfe01 += _0xe934ce;
            }
            _0x03bb67._0xd8adb6[_0x3269a5]._0x943107 = _0x77489c;
            _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61 = _0xe934ce;
        }

        emit VoteCast(_0x35ae6e, _0x3269a5, _0x77489c, _0xe934ce);

        if (_0x03bb67._0x1f0233._0x2fa94f == VotingMode.EarlyExecution) {
            _0x8da64a(_0x35ae6e, _0x5539c0());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x26d886(uint256 _0x35ae6e, address _0x3269a5) external _0x78009e(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x03bb67 = _0x00ee96[_0x35ae6e];
        if (!_0xa37454(_0x03bb67)) {
            revert VoteRemovalForbidden(_0x35ae6e, _0x3269a5);
        } else if (_0x03bb67._0x1f0233._0x2fa94f != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x35ae6e, _0x3269a5);
        } else if (_0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x03bb67._0xd8adb6[_0x3269a5]._0x943107 == VoteOption.Yes) {
            _0x03bb67._0x052bae._0xa8af7c -= _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;
        } else if (_0x03bb67._0xd8adb6[_0x3269a5]._0x943107 == VoteOption.No) {
            _0x03bb67._0x052bae._0xbd57af -= _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x03bb67._0xd8adb6[_0x3269a5]._0x943107 == VoteOption.Abstain) {
            _0x03bb67._0x052bae._0xbbfe01 -= _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;
        }
        _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61 = 0;

        emit VoteCleared(_0x35ae6e, _0x3269a5);
    }

    /// @inheritdoc ILockToGovernBase
    function _0x3bb5e4(uint256 _0x35ae6e) external view returns (bool) {
        Proposal storage _0x03bb67 = _0x00ee96[_0x35ae6e];
        return _0xa37454(_0x03bb67);
    }

    /// @inheritdoc MajorityVotingBase
    function _0xd9265b() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0xd9265b();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x7c0d6d() public view override returns (uint256) {
        return IERC20(_0xa35adc._0xc5e18e())._0x1f073a();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x9da156(uint256 _0x35ae6e, address _0x3269a5) public view returns (uint256) {
        return _0x00ee96[_0x35ae6e]._0xd8adb6[_0x3269a5]._0xd11d61;
    }

    // Internal helpers

    function _0x8dd973(Proposal storage _0x03bb67, address _0x3269a5, VoteOption _0x77489c, uint256 _0xe934ce)
        internal
        view
        returns (bool)
    {
        uint256 _0x245e37 = _0x03bb67._0xd8adb6[_0x3269a5]._0xd11d61;

        // The proposal vote hasn't started or has already ended.
        if (!_0xa37454(_0x03bb67)) {
            return false;
        } else if (_0x77489c == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x03bb67._0x1f0233._0x2fa94f != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0xe934ce <= _0x245e37) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x03bb67._0xd8adb6[_0x3269a5]._0x943107 != VoteOption.None
                    && _0x77489c != _0x03bb67._0xd8adb6[_0x3269a5]._0x943107
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0xe934ce == 0 || _0xe934ce < _0x245e37) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0xe934ce == _0x245e37 && _0x77489c == _0x03bb67._0xd8adb6[_0x3269a5]._0x943107) {
                return false;
            }
        }

        return true;
    }

    function _0x8da64a(uint256 _0x35ae6e, address _0x7c0822) internal {
        if (!_0x084cae(_0x35ae6e)) {
            return;
        } else if (!_0xd7b841()._0xf58d1c(address(this), _0x7c0822, EXECUTE_PROPOSAL_PERMISSION_ID, _0x622e8b())) {
            return;
        }

        _0x001483(_0x35ae6e);
    }

    function _0x001483(uint256 _0x35ae6e) internal override {
        super._0x001483(_0x35ae6e);

        // Notify the LockManager to stop tracking this proposal ID
        _0xa35adc._0x6e49dc(_0x35ae6e);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
