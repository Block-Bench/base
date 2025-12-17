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
        this._0x10ed43.selector ^ this._0x66ac4c.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x32d0c1("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x32d0c1("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x3bbf80, address _0xd182b2);

    error VoteRemovalForbidden(uint256 _0x3bbf80, address _0xd182b2);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0xb86194(
        IDAO _0x72def4,
        ILockManager _0xb5e478,
        VotingSettings calldata _0x21c33e,
        IPlugin.TargetConfig calldata _0x967f71,
        bytes calldata _0x901579
    ) external _0xb2dd6b _0x2e0072(1) {
        __MajorityVotingBase_init(_0x72def4, _0x21c33e, _0x967f71, _0x901579);
        __LockToGovernBase_init(_0xb5e478);

        emit MembershipContractAnnounced({_0x74130c: address(_0xb5e478._0x69cc27())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0x11382d(bytes4 _0x59967c)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x59967c == LOCK_TO_VOTE_INTERFACE_ID || _0x59967c == type(ILockToVote)._0x4ef6b1
            || super._0x11382d(_0x59967c);
    }

    /// @inheritdoc IProposal
    function _0x465fdc() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0x66ac4c(
        bytes calldata _0x1a3c6b,
        Action[] memory _0x57f626,
        uint64 _0x187649,
        uint64 _0x362e37,
        bytes memory _0x784526
    ) external _0x345a7e(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x3bbf80) {
        uint256 _0x6d6883;

        if (_0x784526.length != 0) {
            (_0x6d6883) = abi._0xe23003(_0x784526, (uint256));
        }

        if (_0x2c1e50() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x187649, _0x362e37) = _0x967078(_0x187649, _0x362e37);

        _0x3bbf80 = _0x343043(_0x32d0c1(abi._0x5e66ac(_0x57f626, _0x1a3c6b)));

        if (_0x1fe55e(_0x3bbf80)) {
            revert ProposalAlreadyExists(_0x3bbf80);
        }

        // Store proposal related information
        Proposal storage _0xc1996a = _0x176087[_0x3bbf80];

        _0xc1996a._0xadf6b4._0xef210b = _0xef210b();
        _0xc1996a._0xadf6b4._0x38e97d = _0x38e97d();
        _0xc1996a._0xadf6b4._0x197451 = _0x187649;
        _0xc1996a._0xadf6b4._0xc34607 = _0x362e37;
        _0xc1996a._0xadf6b4._0xf36d5b = _0xf36d5b();
        _0xc1996a._0xadf6b4._0xc67fb0 = _0xc67fb0();

        _0xc1996a._0x5a3094 = _0x0859ec();

        // Reduce costs
        if (_0x6d6883 != 0) {
            _0xc1996a._0x1da272 = _0x6d6883;
        }

        for (uint256 i; i < _0x57f626.length;) {
            _0xc1996a._0x11f939.push(_0x57f626[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x3bbf80, _0x6574a1(), _0x187649, _0x362e37, _0x1a3c6b, _0x57f626, _0x6d6883);

        _0xef432e._0x2c25be(_0x3bbf80);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0xf06d42(uint256 _0x72468b, address _0x87a35f, VoteOption _0x919faa) public view returns (bool) {
        if (!_0x1fe55e(_0x72468b)) {
            revert NonexistentProposal(_0x72468b);
        }

        Proposal storage _0xc1996a = _0x176087[_0x72468b];
        return _0x9e1ef6(_0xc1996a, _0x87a35f, _0x919faa, _0xef432e._0x9c546a(_0x87a35f));
    }

    /// @inheritdoc ILockToVote
    function _0x164e48(uint256 _0x72468b, address _0x87a35f, VoteOption _0x919faa, uint256 _0xc7a007)
        public
        override
        _0x345a7e(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0xc1996a = _0x176087[_0x72468b];

        if (!_0x9e1ef6(_0xc1996a, _0x87a35f, _0x919faa, _0xc7a007)) {
            revert VoteCastForbidden(_0x72468b, _0x87a35f);
        }

        // Same vote
        if (_0x919faa == _0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a) {
            // Same value, nothing to do
            if (_0xc7a007 == _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0xa31c0a = _0xc7a007 - _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;
            _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0 = _0xc7a007;

            if (_0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a == VoteOption.Yes) {
                _0xc1996a._0xddc670._0xbc7eac += _0xa31c0a;
            } else if (_0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a == VoteOption.No) {
                _0xc1996a._0xddc670._0xc00348 += _0xa31c0a;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0xc1996a._0xddc670._0xb3ff89 += _0xa31c0a;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0 > 0) {
                // Undo that vote
                if (_0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a == VoteOption.Yes) {
                    _0xc1996a._0xddc670._0xbc7eac -= _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;
                } else if (_0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a == VoteOption.No) {
                    _0xc1996a._0xddc670._0xc00348 -= _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0xc1996a._0xddc670._0xb3ff89 -= _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;
                }
            }

            // Register the new vote
            if (_0x919faa == VoteOption.Yes) {
                _0xc1996a._0xddc670._0xbc7eac += _0xc7a007;
            } else if (_0x919faa == VoteOption.No) {
                _0xc1996a._0xddc670._0xc00348 += _0xc7a007;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0xc1996a._0xddc670._0xb3ff89 += _0xc7a007;
            }
            _0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a = _0x919faa;
            _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0 = _0xc7a007;
        }

        emit VoteCast(_0x72468b, _0x87a35f, _0x919faa, _0xc7a007);

        if (_0xc1996a._0xadf6b4._0xef210b == VotingMode.EarlyExecution) {
            _0xcb28b6(_0x72468b, _0x6574a1());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x184b9a(uint256 _0x72468b, address _0x87a35f) external _0x345a7e(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0xc1996a = _0x176087[_0x72468b];
        if (!_0x617f0b(_0xc1996a)) {
            revert VoteRemovalForbidden(_0x72468b, _0x87a35f);
        } else if (_0xc1996a._0xadf6b4._0xef210b != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x72468b, _0x87a35f);
        } else if (_0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0 == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a == VoteOption.Yes) {
            _0xc1996a._0xddc670._0xbc7eac -= _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;
        } else if (_0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a == VoteOption.No) {
            _0xc1996a._0xddc670._0xc00348 -= _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a == VoteOption.Abstain) {
            _0xc1996a._0xddc670._0xb3ff89 -= _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;
        }
        _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0 = 0;

        emit VoteCleared(_0x72468b, _0x87a35f);
    }

    /// @inheritdoc ILockToGovernBase
    function _0x3bf222(uint256 _0x72468b) external view returns (bool) {
        Proposal storage _0xc1996a = _0x176087[_0x72468b];
        return _0x617f0b(_0xc1996a);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x10ed43() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x10ed43();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x2c1e50() public view override returns (uint256) {
        return IERC20(_0xef432e._0x69cc27())._0xd4b5b6();
    }

    /// @inheritdoc ILockToGovernBase
    function _0x64b89e(uint256 _0x72468b, address _0x87a35f) public view returns (uint256) {
        return _0x176087[_0x72468b]._0xb164bd[_0x87a35f]._0x1d3cb0;
    }

    // Internal helpers

    function _0x9e1ef6(Proposal storage _0xc1996a, address _0x87a35f, VoteOption _0x919faa, uint256 _0xc7a007)
        internal
        view
        returns (bool)
    {
        uint256 _0xeb4ef3 = _0xc1996a._0xb164bd[_0x87a35f]._0x1d3cb0;

        // The proposal vote hasn't started or has already ended.
        if (!_0x617f0b(_0xc1996a)) {
            return false;
        } else if (_0x919faa == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0xc1996a._0xadf6b4._0xef210b != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0xc7a007 <= _0xeb4ef3) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a != VoteOption.None
                    && _0x919faa != _0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0xc7a007 == 0 || _0xc7a007 < _0xeb4ef3) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0xc7a007 == _0xeb4ef3 && _0x919faa == _0xc1996a._0xb164bd[_0x87a35f]._0xb3e90a) {
                return false;
            }
        }

        return true;
    }

    function _0xcb28b6(uint256 _0x72468b, address _0xeb0aad) internal {
        if (!_0xb4baaf(_0x72468b)) {
            return;
        } else if (!_0xd56997()._0x07b8f0(address(this), _0xeb0aad, EXECUTE_PROPOSAL_PERMISSION_ID, _0xd691b2())) {
            return;
        }

        _0x1bdaa4(_0x72468b);
    }

    function _0x1bdaa4(uint256 _0x72468b) internal override {
        super._0x1bdaa4(_0x72468b);

        // Notify the LockManager to stop tracking this proposal ID
        _0xef432e._0x3c41a5(_0x72468b);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
