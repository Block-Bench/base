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
        this.d.selector ^ this.y.selector;

    /// @notice The ID of the permission required to call the `createProposal` functions.
    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = ax("CREATE_PROPOSAL_PERMISSION");

    /// @notice The ID of the permission required to call `vote` and `clearVote`.
    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = ax("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 au, address br);

    error VoteRemovalForbidden(uint256 au, address br);

    /// @notice Initializes the component.
    /// @dev This method is required to support [ERC-1822](https://eips.ethereum.org/EIPS/eip-1822).
    /// @param _dao The IDAO interface of the associated DAO.
    /// @param _votingSettings The voting settings.
    /// @param _targetConfig Configuration for the execution target, specifying the target address and operation type
    ///     (either `Call` or `DelegateCall`). Defined by `TargetConfig` in the `IPlugin` interface,
    ///     part of the `osx-commons-contracts` package, added in build 3.
    /// @param _pluginMetadata The plugin specific information encoded in bytes.
    ///     This can also be an ipfs cid encoded in bytes.
    function ar(
        IDAO bu,
        ILockManager ag,
        VotingSettings calldata t,
        IPlugin.TargetConfig calldata ac,
        bytes calldata x
    ) external a ad(1) {
        __MajorityVotingBase_init(bu, t, ac, x);
        __LockToGovernBase_init(ag);

        emit MembershipContractAnnounced({o: address(ag.bo())});
    }

    /// @notice Checks if this or the parent contract supports an interface by its ID.
    /// @param _interfaceId The ID of the interface.
    /// @return Returns `true` if the interface is supported.
    function j(bytes4 af)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return af == LOCK_TO_VOTE_INTERFACE_ID || af == type(ILockToVote).ah
            || super.j(af);
    }

    /// @inheritdoc IProposal
    function b() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }

    /// @inheritdoc IProposal
    /// @dev Requires the `CREATE_PROPOSAL_PERMISSION_ID` permission.
    function y(
        bytes calldata aw,
        Action[] memory bf,
        uint64 av,
        uint64 be,
        bytes memory bq
    ) external bt(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 au) {
        uint256 m;

        if (bq.length != 0) {
            (m) = abi.bn(bq, (uint256));
        }

        if (i() == 0) {
            revert NoVotingPower();
        }

        /// @dev `minProposerVotingPower` is checked at the the permission condition behind auth(CREATE_PROPOSAL_PERMISSION_ID)

        (av, be) = c(av, be);

        au = k(ax(abi.bm(bf, aw)));

        if (w(au)) {
            revert ProposalAlreadyExists(au);
        }

        // Store proposal related information
        Proposal storage ay = ba[au];

        ay.ap.at = at();
        ay.ap.f = f();
        ay.ap.az = av;
        ay.ap.bk = be;
        ay.ap.g = g();
        ay.ap.l = l();

        ay.ae = q();

        // Reduce costs
        if (m != 0) {
            ay.r = m;
        }

        for (uint256 i; i < bf.length;) {
            ay.bh.push(bf[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(au, as(), av, be, aw, bf, m);

        an.u(au);
    }

    /// @inheritdoc ILockToVote
    /// @dev Reverts if the proposal with the given `_proposalId` does not exist.
    function bi(uint256 am, address bl, VoteOption aj) public view returns (bool) {
        if (!w(am)) {
            revert NonexistentProposal(am);
        }

        Proposal storage ay = ba[am];
        return bg(ay, bl, aj, an.n(bl));
    }

    /// @inheritdoc ILockToVote
    function bv(uint256 am, address bl, VoteOption aj, uint256 s)
        public
        override
        bt(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage ay = ba[am];

        if (!bg(ay, bl, aj, s)) {
            revert VoteCastForbidden(am, bl);
        }

        // Same vote
        if (aj == ay.bs[bl].aq) {
            // Same value, nothing to do
            if (s == ay.bs[bl].ak) return;

            // More balance
            /// @dev diff > 0 is guaranteed, as _canVote() above will return false and revert otherwise
            uint256 bw = s - ay.bs[bl].ak;
            ay.bs[bl].ak = s;

            if (ay.bs[bl].aq == VoteOption.Yes) {
                ay.bp.by += bw;
            } else if (ay.bs[bl].aq == VoteOption.No) {
                ay.bp.bz += bw;
            } else {
                /// @dev Voting none is not possible, as _canVote() above will return false and revert if so
                ay.bp.bj += bw;
            }
        } else {
            /// @dev VoteReplacement has already been enforced by _canVote()

            // Was there a vote?
            if (ay.bs[bl].ak > 0) {
                // Undo that vote
                if (ay.bs[bl].aq == VoteOption.Yes) {
                    ay.bp.by -= ay.bs[bl].ak;
                } else if (ay.bs[bl].aq == VoteOption.No) {
                    ay.bp.bz -= ay.bs[bl].ak;
                } else {
                    /// @dev Voting none is not possible, only abstain is left
                    ay.bp.bj -= ay.bs[bl].ak;
                }
            }

            // Register the new vote
            if (aj == VoteOption.Yes) {
                ay.bp.by += s;
            } else if (aj == VoteOption.No) {
                ay.bp.bz += s;
            } else {
                /// @dev Voting none is not possible, only abstain is left
                ay.bp.bj += s;
            }
            ay.bs[bl].aq = aj;
            ay.bs[bl].ak = s;
        }

        emit VoteCast(am, bl, aj, s);

        if (ay.ap.at == VotingMode.EarlyExecution) {
            e(am, as());
        }
    }

    /// @inheritdoc ILockToVote
    function bb(uint256 am, address bl) external bt(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage ay = ba[am];
        if (!p(ay)) {
            revert VoteRemovalForbidden(am, bl);
        } else if (ay.ap.at != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(am, bl);
        } else if (ay.bs[bl].ak == 0) {
            // Nothing to do
            return;
        }

        // Undo that vote
        if (ay.bs[bl].aq == VoteOption.Yes) {
            ay.bp.by -= ay.bs[bl].ak;
        } else if (ay.bs[bl].aq == VoteOption.No) {
            ay.bp.bz -= ay.bs[bl].ak;
        }
        /// @dev Double checking for abstain, even though canVote prevents any other voteOption value
        else if (ay.bs[bl].aq == VoteOption.Abstain) {
            ay.bp.bj -= ay.bs[bl].ak;
        }
        ay.bs[bl].ak = 0;

        emit VoteCleared(am, bl);
    }

    /// @inheritdoc ILockToGovernBase
    function z(uint256 am) external view returns (bool) {
        Proposal storage ay = ba[am];
        return p(ay);
    }

    /// @inheritdoc MajorityVotingBase
    function d() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase.d();
    }

    /// @inheritdoc MajorityVotingBase
    function i() public view override returns (uint256) {
        return IERC20(an.bo()).al();
    }

    /// @inheritdoc ILockToGovernBase
    function v(uint256 am, address bl) public view returns (uint256) {
        return ba[am].bs[bl].ak;
    }

    // Internal helpers

    function bg(Proposal storage ay, address bl, VoteOption aj, uint256 s)
        internal
        view
        returns (bool)
    {
        uint256 h = ay.bs[bl].ak;

        // The proposal vote hasn't started or has already ended.
        if (!p(ay)) {
            return false;
        } else if (aj == VoteOption.None) {
            return false;
        }
        // Standard voting + early execution
        else if (ay.ap.at != VotingMode.VoteReplacement) {
            // Lowering the existing voting power (or the same) is not allowed
            if (s <= h) {
                return false;
            }
            // The voter already voted a different option but vote replacment is not allowed.
            else if (
                ay.bs[bl].aq != VoteOption.None
                    && aj != ay.bs[bl].aq
            ) {
                return false;
            }
        }
        // Vote replacement mode
        else {
            // Lowering the existing voting power is not allowed
            if (s == 0 || s < h) {
                return false;
            }
            // Voting the same option with the same balance is not allowed
            else if (s == h && aj == ay.bs[bl].aq) {
                return false;
            }
        }

        return true;
    }

    function e(uint256 am, address ao) internal {
        if (!ai(am)) {
            return;
        } else if (!bx().aa(address(this), ao, EXECUTE_PROPOSAL_PERMISSION_ID, bc())) {
            return;
        }

        bd(am);
    }

    function bd(uint256 am) internal override {
        super.bd(am);

        // Notify the LockManager to stop tracking this proposal ID
        an.ab(am);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add
    /// new variables without shifting down storage in the inheritance chain
    /// (see [OpenZeppelin's guide about storage gaps]
    /// (https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[50] private __gap;
}
