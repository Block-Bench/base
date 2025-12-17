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
        this._0x5774f3.selector ^ this._0xd38687.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xdc56a8("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xdc56a8("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x19fbf7, address _0xa7c3a7);

    error VoteRemovalForbidden(uint256 _0x19fbf7, address _0xa7c3a7);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0xd9d971(
        IDAO _0x080646,
        ILockManager _0x8da029,
        VotingSettings calldata _0x6722fc,
        IPlugin.TargetConfig calldata _0x961199,
        bytes calldata _0x726c70
    ) external _0x8d2f91 _0xfb7e51(1) {
        // Placeholder for future logic
        // Placeholder for future logic
        __MajorityVotingBase_init(_0x080646, _0x6722fc, _0x961199, _0x726c70);
        __LockToGovernBase_init(_0x8da029);

        emit MembershipContractAnnounced({_0x8b1def: address(_0x8da029._0xa9e908())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0xd36c86(bytes4 _0x587156)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        bool _flag3 = false;
        bool _flag4 = false;
        return _0x587156 == LOCK_TO_VOTE_INTERFACE_ID || _0x587156 == type(ILockToVote)._0x90c273
            || super._0xd36c86(_0x587156);
    }

    /// @inheritdoc IProposal
    function _0xd8701a() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0xd38687(
        bytes calldata _0xbac8f5,
        Action[] memory _0xf27e27,
        uint64 _0x7dbd1a,
        uint64 _0xc7d879,
        bytes memory _0xe8461d
    ) external _0x20505a(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x19fbf7) {
        uint256 _0x96aaac;

        if (_0xe8461d.length != 0) {
            (_0x96aaac) = abi._0xf1d42b(_0xe8461d, (uint256));
        }

        if (_0xc7a3d6() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x7dbd1a, _0xc7d879) = _0xda7573(_0x7dbd1a, _0xc7d879);

        _0x19fbf7 = _0x2112c6(_0xdc56a8(abi._0x913bd1(_0xf27e27, _0xbac8f5)));

        if (_0x7c0ddb(_0x19fbf7)) {
            revert ProposalAlreadyExists(_0x19fbf7);
        }

        // Store proposal related information
        Proposal storage _0x0a81e2 = _0x83ae78[_0x19fbf7];

        _0x0a81e2._0x90b24f._0xf3849c = _0xf3849c();
        _0x0a81e2._0x90b24f._0x3f3404 = _0x3f3404();
        _0x0a81e2._0x90b24f._0xefd224 = _0x7dbd1a;
        _0x0a81e2._0x90b24f._0x4349b5 = _0xc7d879;
        _0x0a81e2._0x90b24f._0xf3263f = _0xf3263f();
        _0x0a81e2._0x90b24f._0xe91abe = _0xe91abe();

        _0x0a81e2._0x230818 = _0xbd910c();

        // Reduce costs
        if (_0x96aaac != 0) {
            _0x0a81e2._0x8df0ba = _0x96aaac;
        }

        for (uint256 i; i < _0xf27e27.length;) {
            _0x0a81e2._0x8bdcec.push(_0xf27e27[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x19fbf7, _0x94ca1b(), _0x7dbd1a, _0xc7d879, _0xbac8f5, _0xf27e27, _0x96aaac);

        _0xff69d3._0x4a0bc9(_0x19fbf7);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0xb2ec59(uint256 _0x44e96c, address _0xae3fcb, VoteOption _0x16bd0a) public view returns (bool) {
        if (!_0x7c0ddb(_0x44e96c)) {
            revert NonexistentProposal(_0x44e96c);
        }

        Proposal storage _0x0a81e2 = _0x83ae78[_0x44e96c];
        return _0x57b7ea(_0x0a81e2, _0xae3fcb, _0x16bd0a, _0xff69d3._0xde5e8e(_0xae3fcb));
    }

    /// @inheritdoc ILockToVote
    function _0x49ed41(uint256 _0x44e96c, address _0xae3fcb, VoteOption _0x16bd0a, uint256 _0x8a0930)
        public
        override
        _0x20505a(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x0a81e2 = _0x83ae78[_0x44e96c];

        if (!_0x57b7ea(_0x0a81e2, _0xae3fcb, _0x16bd0a, _0x8a0930)) {
            revert VoteCastForbidden(_0x44e96c, _0xae3fcb);
        }

        // Same vote
        if (_0x16bd0a == _0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3) {
            // Same value, nothing to do
            if (_0x8a0930 == _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0xe71137 = _0x8a0930 - _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;
            _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743 = _0x8a0930;

            if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 == VoteOption.Yes) {
                _0x0a81e2._0xc4b6ad._0x4848c9 += _0xe71137;
            } else if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 == VoteOption.No) {
                _0x0a81e2._0xc4b6ad._0x7ef10c += _0xe71137;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x0a81e2._0xc4b6ad._0x8cbc2e += _0xe71137;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743 > 0) {
                // Undo that vote
                if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 == VoteOption.Yes) {
                    _0x0a81e2._0xc4b6ad._0x4848c9 -= _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;
                } else if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 == VoteOption.No) {
                    _0x0a81e2._0xc4b6ad._0x7ef10c -= _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x0a81e2._0xc4b6ad._0x8cbc2e -= _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;
                }
            }

            // Register the new vote
            if (_0x16bd0a == VoteOption.Yes) {
                _0x0a81e2._0xc4b6ad._0x4848c9 += _0x8a0930;
            } else if (_0x16bd0a == VoteOption.No) {
                _0x0a81e2._0xc4b6ad._0x7ef10c += _0x8a0930;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x0a81e2._0xc4b6ad._0x8cbc2e += _0x8a0930;
            }
            _0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 = _0x16bd0a;
            _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743 = _0x8a0930;
        }

        emit VoteCast(_0x44e96c, _0xae3fcb, _0x16bd0a, _0x8a0930);

        if (_0x0a81e2._0x90b24f._0xf3849c == VotingMode.EarlyExecution) {
            _0x7545fa(_0x44e96c, _0x94ca1b());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x715d8c(uint256 _0x44e96c, address _0xae3fcb) external _0x20505a(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x0a81e2 = _0x83ae78[_0x44e96c];
        if (!_0x4f9109(_0x0a81e2)) {
            revert VoteRemovalForbidden(_0x44e96c, _0xae3fcb);
        } else if (_0x0a81e2._0x90b24f._0xf3849c != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x44e96c, _0xae3fcb);
        } else if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 == VoteOption.Yes) {
            _0x0a81e2._0xc4b6ad._0x4848c9 -= _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;
        } else if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 == VoteOption.No) {
            _0x0a81e2._0xc4b6ad._0x7ef10c -= _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 == VoteOption.Abstain) {
            _0x0a81e2._0xc4b6ad._0x8cbc2e -= _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;
        }
        _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743 = 0;

        emit VoteCleared(_0x44e96c, _0xae3fcb);
    }

    /// @inheritdoc ILockToGovernBase
    function _0xba7733(uint256 _0x44e96c) external view returns (bool) {
        Proposal storage _0x0a81e2 = _0x83ae78[_0x44e96c];
        return _0x4f9109(_0x0a81e2);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x5774f3() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x5774f3();
    }

    /// @inheritdoc MajorityVotingBase
    function _0xc7a3d6() public view override returns (uint256) {
        return IERC20(_0xff69d3._0xa9e908())._0x008020();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x68870f(uint256 _0x44e96c, address _0xae3fcb) public view returns (uint256) {
        return _0x83ae78[_0x44e96c]._0x5c66fb[_0xae3fcb]._0x25f743;
    }

    // Internal helpers

    function _0x57b7ea(Proposal storage _0x0a81e2, address _0xae3fcb, VoteOption _0x16bd0a, uint256 _0x8a0930)
        internal
        view
        returns (bool)
    {
        uint256 _0xe35e9d = _0x0a81e2._0x5c66fb[_0xae3fcb]._0x25f743;

        // The proposal vote hasn't started or has already ended.
        if (!_0x4f9109(_0x0a81e2)) {
            return false;
        } else if (_0x16bd0a == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x0a81e2._0x90b24f._0xf3849c != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x8a0930 <= _0xe35e9d) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3 != VoteOption.None
                    && _0x16bd0a != _0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x8a0930 == 0 || _0x8a0930 < _0xe35e9d) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x8a0930 == _0xe35e9d && _0x16bd0a == _0x0a81e2._0x5c66fb[_0xae3fcb]._0x34e9b3) {
                return false;
            }
        }

        return true;
    }

    function _0x7545fa(uint256 _0x44e96c, address _0x7bf565) internal {
        if (!_0x01df2e(_0x44e96c)) {
            return;
        } else if (!_0x015c98()._0x41b231(address(this), _0x7bf565, EXECUTE_PROPOSAL_PERMISSION_ID, _0x3fa189())) {
            return;
        }

        _0x293954(_0x44e96c);
    }

    function _0x293954(uint256 _0x44e96c) internal override {
        super._0x293954(_0x44e96c);

        // Notify the LockManager to stop tracking this proposal ID
        _0xff69d3._0x64744e(_0x44e96c);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
