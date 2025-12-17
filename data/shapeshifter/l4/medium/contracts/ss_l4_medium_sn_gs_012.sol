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
        this._0xf3da05.selector ^ this._0x2d9668.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x540c74("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x540c74("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x8c2b0f, address _0x8ed3f4);

    error VoteRemovalForbidden(uint256 _0x8c2b0f, address _0x8ed3f4);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x4a4cec(
        IDAO _0xc10fdc,
        ILockManager _0xd240d6,
        VotingSettings calldata _0xf2cea6,
        IPlugin.TargetConfig calldata _0x0c9599,
        bytes calldata _0xc6b7ef
    ) external _0xc5a337 _0x1f05c7(1) {
        // Placeholder for future logic
        // Placeholder for future logic
        __MajorityVotingBase_init(_0xc10fdc, _0xf2cea6, _0x0c9599, _0xc6b7ef);
        __LockToGovernBase_init(_0xd240d6);

        emit MembershipContractAnnounced({_0xa7ab3b: address(_0xd240d6._0x96ec55())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0x8fd1ab(bytes4 _0x6f6449)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        if (false) { revert(); }
        if (false) { revert(); }
        return _0x6f6449 == LOCK_TO_VOTE_INTERFACE_ID || _0x6f6449 == type(ILockToVote)._0xd226f5
            || super._0x8fd1ab(_0x6f6449);
    }

    /// @inheritdoc IProposal
    function _0xf13b8b() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0x2d9668(
        bytes calldata _0xd3f13c,
        Action[] memory _0x9b032f,
        uint64 _0xcf8488,
        uint64 _0x8844df,
        bytes memory _0x6d8c07
    ) external _0x7c9a77(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x8c2b0f) {
        uint256 _0x2fd843;

        if (_0x6d8c07.length != 0) {
            (_0x2fd843) = abi._0x441ead(_0x6d8c07, (uint256));
        }

        if (_0xd436e2() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0xcf8488, _0x8844df) = _0x261fe4(_0xcf8488, _0x8844df);

        _0x8c2b0f = _0x0de2b5(_0x540c74(abi._0x11520e(_0x9b032f, _0xd3f13c)));

        if (_0x7ee6bf(_0x8c2b0f)) {
            revert ProposalAlreadyExists(_0x8c2b0f);
        }

        // Store proposal related information
        Proposal storage _0x466f09 = _0xa8d22f[_0x8c2b0f];

        _0x466f09._0x33af98._0xec22b1 = _0xec22b1();
        _0x466f09._0x33af98._0xcb81a6 = _0xcb81a6();
        _0x466f09._0x33af98._0x9f3511 = _0xcf8488;
        _0x466f09._0x33af98._0xb1c0fd = _0x8844df;
        _0x466f09._0x33af98._0x5680b0 = _0x5680b0();
        _0x466f09._0x33af98._0x6762a0 = _0x6762a0();

        _0x466f09._0xb61a10 = _0x964e1a();

        // Reduce costs
        if (_0x2fd843 != 0) {
            _0x466f09._0x0f782c = _0x2fd843;
        }

        for (uint256 i; i < _0x9b032f.length;) {
            _0x466f09._0x298e26.push(_0x9b032f[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x8c2b0f, _0x34f20a(), _0xcf8488, _0x8844df, _0xd3f13c, _0x9b032f, _0x2fd843);

        _0xf5a104._0x382c2d(_0x8c2b0f);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0x51a7a5(uint256 _0x1807c8, address _0x9c8ea7, VoteOption _0x1a589d) public view returns (bool) {
        if (!_0x7ee6bf(_0x1807c8)) {
            revert NonexistentProposal(_0x1807c8);
        }

        Proposal storage _0x466f09 = _0xa8d22f[_0x1807c8];
        return _0x5909f3(_0x466f09, _0x9c8ea7, _0x1a589d, _0xf5a104._0x5e4d25(_0x9c8ea7));
    }

    /// @inheritdoc ILockToVote
    function _0xe180c5(uint256 _0x1807c8, address _0x9c8ea7, VoteOption _0x1a589d, uint256 _0x298297)
        public
        override
        _0x7c9a77(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x466f09 = _0xa8d22f[_0x1807c8];

        if (!_0x5909f3(_0x466f09, _0x9c8ea7, _0x1a589d, _0x298297)) {
            revert VoteCastForbidden(_0x1807c8, _0x9c8ea7);
        }

        // Same vote
        if (_0x1a589d == _0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00) {
            // Same value, nothing to do
            if (_0x298297 == _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0xe598aa = _0x298297 - _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
            _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c = _0x298297;

            if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 == VoteOption.Yes) {
                _0x466f09._0xac6a7c._0xfcddb9 += _0xe598aa;
            } else if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 == VoteOption.No) {
                _0x466f09._0xac6a7c._0x835676 += _0xe598aa;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x466f09._0xac6a7c._0xefa164 += _0xe598aa;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c > 0) {
                // Undo that vote
                if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 == VoteOption.Yes) {
                    _0x466f09._0xac6a7c._0xfcddb9 -= _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
                } else if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 == VoteOption.No) {
                    _0x466f09._0xac6a7c._0x835676 -= _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x466f09._0xac6a7c._0xefa164 -= _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
                }
            }

            // Register the new vote
            if (_0x1a589d == VoteOption.Yes) {
                _0x466f09._0xac6a7c._0xfcddb9 += _0x298297;
            } else if (_0x1a589d == VoteOption.No) {
                _0x466f09._0xac6a7c._0x835676 += _0x298297;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x466f09._0xac6a7c._0xefa164 += _0x298297;
            }
            _0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 = _0x1a589d;
            _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c = _0x298297;
        }

        emit VoteCast(_0x1807c8, _0x9c8ea7, _0x1a589d, _0x298297);

        if (_0x466f09._0x33af98._0xec22b1 == VotingMode.EarlyExecution) {
            _0x32229c(_0x1807c8, _0x34f20a());
        }
    }

    /// @inheritdoc ILockToVote
    function _0xc9006a(uint256 _0x1807c8, address _0x9c8ea7) external _0x7c9a77(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x466f09 = _0xa8d22f[_0x1807c8];
        if (!_0x870635(_0x466f09)) {
            revert VoteRemovalForbidden(_0x1807c8, _0x9c8ea7);
        } else if (_0x466f09._0x33af98._0xec22b1 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x1807c8, _0x9c8ea7);
        } else if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 == VoteOption.Yes) {
            _0x466f09._0xac6a7c._0xfcddb9 -= _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
        } else if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 == VoteOption.No) {
            _0x466f09._0xac6a7c._0x835676 -= _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 == VoteOption.Abstain) {
            _0x466f09._0xac6a7c._0xefa164 -= _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
        }
        _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c = 0;

        emit VoteCleared(_0x1807c8, _0x9c8ea7);
    }

    /// @inheritdoc ILockToGovernBase
    function _0x234e38(uint256 _0x1807c8) external view returns (bool) {
        Proposal storage _0x466f09 = _0xa8d22f[_0x1807c8];
        return _0x870635(_0x466f09);
    }

    /// @inheritdoc MajorityVotingBase
    function _0xf3da05() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0xf3da05();
    }

    /// @inheritdoc MajorityVotingBase
    function _0xd436e2() public view override returns (uint256) {
        return IERC20(_0xf5a104._0x96ec55())._0x59e08e();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x9fb1d6(uint256 _0x1807c8, address _0x9c8ea7) public view returns (uint256) {
        return _0xa8d22f[_0x1807c8]._0xf8e1fa[_0x9c8ea7]._0xbacf3c;
    }

    // Internal helpers

    function _0x5909f3(Proposal storage _0x466f09, address _0x9c8ea7, VoteOption _0x1a589d, uint256 _0x298297)
        internal
        view
        returns (bool)
    {
        uint256 _0x1426fb = _0x466f09._0xf8e1fa[_0x9c8ea7]._0xbacf3c;

        // The proposal vote hasn't started or has already ended.
        if (!_0x870635(_0x466f09)) {
            return false;
        } else if (_0x1a589d == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x466f09._0x33af98._0xec22b1 != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x298297 <= _0x1426fb) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00 != VoteOption.None
                    && _0x1a589d != _0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x298297 == 0 || _0x298297 < _0x1426fb) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x298297 == _0x1426fb && _0x1a589d == _0x466f09._0xf8e1fa[_0x9c8ea7]._0x731b00) {
                return false;
            }
        }

        return true;
    }

    function _0x32229c(uint256 _0x1807c8, address _0x1cf859) internal {
        if (!_0xf54abd(_0x1807c8)) {
            return;
        } else if (!_0x825a6b()._0x61a916(address(this), _0x1cf859, EXECUTE_PROPOSAL_PERMISSION_ID, _0x3e037c())) {
            return;
        }

        _0xf84c20(_0x1807c8);
    }

    function _0xf84c20(uint256 _0x1807c8) internal override {
        super._0xf84c20(_0x1807c8);

        // Notify the LockManager to stop tracking this proposal ID
        _0xf5a104._0xc8fffd(_0x1807c8);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
