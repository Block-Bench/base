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
        this._0x7766cb.selector ^ this._0x3a8093.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x3e6437("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x3e6437("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x386491, address _0x14985d);

    error VoteRemovalForbidden(uint256 _0x386491, address _0x14985d);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function _0x215c46(
        IDAO _0x279827,
        ILockManager _0x26285c,
        VotingSettings calldata _0x6594c9,
        IPlugin.TargetConfig calldata _0x085ab0,
        bytes calldata _0x8da0b2
    ) external _0x98a46d _0xbf6f90(1) {
        __MajorityVotingBase_init(_0x279827, _0x6594c9, _0x085ab0, _0x8da0b2);
        __LockToGovernBase_init(_0x26285c);

        emit MembershipContractAnnounced({_0x447213: address(_0x26285c._0x9ad714())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function _0x7eabb6(bytes4 _0x745f55)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x745f55 == LOCK_TO_VOTE_INTERFACE_ID || _0x745f55 == type(ILockToVote)._0x808e3e
            || super._0x7eabb6(_0x745f55);
    }

    /// @inheritdoc IProposal
    function _0xd44974() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function _0x3a8093(
        bytes calldata _0xd90be6,
        Action[] memory _0x631cf0,
        uint64 _0x573b1c,
        uint64 _0x33fdc0,
        bytes memory _0x8e1ebf
    ) external _0x0fb871(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x386491) {
        uint256 _0x9985ef;

        if (_0x8e1ebf.length != 0) {
            (_0x9985ef) = abi._0x8af0fb(_0x8e1ebf, (uint256));
        }

        if (_0x7653b8() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (_0x573b1c, _0x33fdc0) = _0x284c2c(_0x573b1c, _0x33fdc0);

        _0x386491 = _0x30844a(_0x3e6437(abi._0xbd8730(_0x631cf0, _0xd90be6)));

        if (_0x43b84b(_0x386491)) {
            revert ProposalAlreadyExists(_0x386491);
        }

        // Store proposal related information
        Proposal storage _0x7bffec = _0x0d21fb[_0x386491];

        _0x7bffec._0xbe1a59._0x9dd648 = _0x9dd648();
        _0x7bffec._0xbe1a59._0x21e483 = _0x21e483();
        _0x7bffec._0xbe1a59._0xfc8d1d = _0x573b1c;
        _0x7bffec._0xbe1a59._0xf7d0a9 = _0x33fdc0;
        _0x7bffec._0xbe1a59._0x9fdf26 = _0x9fdf26();
        _0x7bffec._0xbe1a59._0x932b7f = _0x932b7f();

        _0x7bffec._0xcbf1f1 = _0xb86f8b();

        // Reduce costs
        if (_0x9985ef != 0) {
            _0x7bffec._0xf2c673 = _0x9985ef;
        }

        for (uint256 i; i < _0x631cf0.length;) {
            _0x7bffec._0x501b3d.push(_0x631cf0[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x386491, _0xcf9696(), _0x573b1c, _0x33fdc0, _0xd90be6, _0x631cf0, _0x9985ef);

        _0x5ffa1f._0x838b58(_0x386491);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function _0xdd56b9(uint256 _0xc89dc5, address _0xee5392, VoteOption _0x3ca184) public view returns (bool) {
        if (!_0x43b84b(_0xc89dc5)) {
            revert NonexistentProposal(_0xc89dc5);
        }

        Proposal storage _0x7bffec = _0x0d21fb[_0xc89dc5];
        return _0x817a0f(_0x7bffec, _0xee5392, _0x3ca184, _0x5ffa1f._0x4cbe2c(_0xee5392));
    }

    /// @inheritdoc ILockToVote
    function _0x1b039d(uint256 _0xc89dc5, address _0xee5392, VoteOption _0x3ca184, uint256 _0x611160)
        public
        override
        _0x0fb871(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x7bffec = _0x0d21fb[_0xc89dc5];

        if (!_0x817a0f(_0x7bffec, _0xee5392, _0x3ca184, _0x611160)) {
            revert VoteCastForbidden(_0xc89dc5, _0xee5392);
        }

        // Same vote
        if (_0x3ca184 == _0x7bffec._0xe9bc78[_0xee5392]._0xab36c1) {
            // Same value, nothing to do
            if (_0x611160 == _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 _0x76ce0a = _0x611160 - _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;
            _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f = _0x611160;

            if (_0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 == VoteOption.Yes) {
                _0x7bffec._0x5ceca0._0xc12d85 += _0x76ce0a;
            } else if (_0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 == VoteOption.No) {
                _0x7bffec._0x5ceca0._0xdd5112 += _0x76ce0a;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                _0x7bffec._0x5ceca0._0x76e66c += _0x76ce0a;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (_0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f > 0) {
                // Undo that vote
                if (_0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 == VoteOption.Yes) {
                    _0x7bffec._0x5ceca0._0xc12d85 -= _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;
                } else if (_0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 == VoteOption.No) {
                    _0x7bffec._0x5ceca0._0xdd5112 -= _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    _0x7bffec._0x5ceca0._0x76e66c -= _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;
                }
            }

            // Register the new vote
            if (_0x3ca184 == VoteOption.Yes) {
                _0x7bffec._0x5ceca0._0xc12d85 += _0x611160;
            } else if (_0x3ca184 == VoteOption.No) {
                _0x7bffec._0x5ceca0._0xdd5112 += _0x611160;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                _0x7bffec._0x5ceca0._0x76e66c += _0x611160;
            }
            _0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 = _0x3ca184;
            _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f = _0x611160;
        }

        emit VoteCast(_0xc89dc5, _0xee5392, _0x3ca184, _0x611160);

        if (_0x7bffec._0xbe1a59._0x9dd648 == VotingMode.EarlyExecution) {
            _0xf2b13d(_0xc89dc5, _0xcf9696());
        }
    }

    /// @inheritdoc ILockToVote
    function _0x36a2cf(uint256 _0xc89dc5, address _0xee5392) external _0x0fb871(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x7bffec = _0x0d21fb[_0xc89dc5];
        if (!_0x431f41(_0x7bffec)) {
            revert VoteRemovalForbidden(_0xc89dc5, _0xee5392);
        } else if (_0x7bffec._0xbe1a59._0x9dd648 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0xc89dc5, _0xee5392);
        } else if (_0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (_0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 == VoteOption.Yes) {
            _0x7bffec._0x5ceca0._0xc12d85 -= _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;
        } else if (_0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 == VoteOption.No) {
            _0x7bffec._0x5ceca0._0xdd5112 -= _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (_0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 == VoteOption.Abstain) {
            _0x7bffec._0x5ceca0._0x76e66c -= _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;
        }
        _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f = 0;

        emit VoteCleared(_0xc89dc5, _0xee5392);
    }

    /// @inheritdoc ILockToGovernBase
    function _0xbeb454(uint256 _0xc89dc5) external view returns (bool) {
        Proposal storage _0x7bffec = _0x0d21fb[_0xc89dc5];
        return _0x431f41(_0x7bffec);
    }

    /// @inheritdoc MajorityVotingBase
    function _0x7766cb() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x7766cb();
    }

    /// @inheritdoc MajorityVotingBase
    function _0x7653b8() public view override returns (uint256) {
        return IERC20(_0x5ffa1f._0x9ad714())._0xc19f0e();
    }

    /// @inheritdoc ILockToGovernBase
    function _0xa699b9(uint256 _0xc89dc5, address _0xee5392) public view returns (uint256) {
        return _0x0d21fb[_0xc89dc5]._0xe9bc78[_0xee5392]._0x1b7d2f;
    }

    // Internal helpers

    function _0x817a0f(Proposal storage _0x7bffec, address _0xee5392, VoteOption _0x3ca184, uint256 _0x611160)
        internal
        view
        returns (bool)
    {
        uint256 _0x3f7ccf = _0x7bffec._0xe9bc78[_0xee5392]._0x1b7d2f;

        // The proposal vote hasn't started or has already ended.
        if (!_0x431f41(_0x7bffec)) {
            return false;
        } else if (_0x3ca184 == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (_0x7bffec._0xbe1a59._0x9dd648 != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (_0x611160 <= _0x3f7ccf) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                _0x7bffec._0xe9bc78[_0xee5392]._0xab36c1 != VoteOption.None
                    && _0x3ca184 != _0x7bffec._0xe9bc78[_0xee5392]._0xab36c1
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (_0x611160 == 0 || _0x611160 < _0x3f7ccf) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (_0x611160 == _0x3f7ccf && _0x3ca184 == _0x7bffec._0xe9bc78[_0xee5392]._0xab36c1) {
                return false;
            }
        }

        return true;
    }

    function _0xf2b13d(uint256 _0xc89dc5, address _0x05012b) internal {
        if (!_0x198ab9(_0xc89dc5)) {
            return;
        } else if (!_0x16bfe6()._0x5ac755(address(this), _0x05012b, EXECUTE_PROPOSAL_PERMISSION_ID, _0x4b5622())) {
            return;
        }

        _0x9784a2(_0xc89dc5);
    }

    function _0x9784a2(uint256 _0xc89dc5) internal override {
        super._0x9784a2(_0xc89dc5);

        // Notify the LockManager to stop tracking this proposal ID
        _0x5ffa1f._0xec0beb(_0xc89dc5);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
