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


    bytes4 internal constant LOCK_TO_VOTE_INTERFACE_ID =
        this.e.selector ^ this.z.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = ba("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = ba("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 aq, address bo);

    error VoteRemovalForbidden(uint256 aq, address bo);


    function av(
        IDAO bt,
        ILockManager ag,
        VotingSettings calldata s,
        IPlugin.TargetConfig calldata ad,
        bytes calldata p
    ) external a ab(1) {
        __MajorityVotingBase_init(bt, s, ad, p);
        __LockToGovernBase_init(ag);

        emit MembershipContractAnnounced({l: address(ag.br())});
    }


    function k(bytes4 af)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return af == LOCK_TO_VOTE_INTERFACE_ID || af == type(ILockToVote).ah
            || super.k(af);
    }


    function b() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function z(
        bytes calldata ax,
        Action[] memory be,
        uint64 au,
        uint64 bd,
        bytes memory bs
    ) external bu(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 aq) {
        uint256 m;

        if (bs.length != 0) {
            (m) = abi.bl(bs, (uint256));
        }

        if (i() == 0) {
            revert NoVotingPower();
        }


        (au, bd) = c(au, bd);

        aq = j(ba(abi.bm(be, ax)));

        if (v(aq)) {
            revert ProposalAlreadyExists(aq);
        }


        Proposal storage az = ay[aq];

        az.at.as = as();
        az.at.g = g();
        az.at.aw = au;
        az.at.bh = bd;
        az.at.f = f();
        az.at.n = n();

        az.ae = t();


        if (m != 0) {
            az.w = m;
        }

        for (uint256 i; i < be.length;) {
            az.bk.push(be[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(aq, ar(), au, bd, ax, be, m);

        an.x(aq);
    }


    function bj(uint256 al, address bn, VoteOption ao) public view returns (bool) {
        if (!v(al)) {
            revert NonexistentProposal(al);
        }

        Proposal storage az = ay[al];
        return bg(az, bn, ao, an.o(bn));
    }


    function bv(uint256 al, address bn, VoteOption ao, uint256 u)
        public
        override
        bu(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage az = ay[al];

        if (!bg(az, bn, ao, u)) {
            revert VoteCastForbidden(al, bn);
        }


        if (ao == az.bq[bn].ap) {

            if (u == az.bq[bn].am) return;


            uint256 bw = u - az.bq[bn].am;
            az.bq[bn].am = u;

            if (az.bq[bn].ap == VoteOption.Yes) {
                az.bp.bx += bw;
            } else if (az.bq[bn].ap == VoteOption.No) {
                az.bp.bz += bw;
            } else {

                az.bp.bi += bw;
            }
        } else {


            if (az.bq[bn].am > 0) {

                if (az.bq[bn].ap == VoteOption.Yes) {
                    az.bp.bx -= az.bq[bn].am;
                } else if (az.bq[bn].ap == VoteOption.No) {
                    az.bp.bz -= az.bq[bn].am;
                } else {

                    az.bp.bi -= az.bq[bn].am;
                }
            }


            if (ao == VoteOption.Yes) {
                az.bp.bx += u;
            } else if (ao == VoteOption.No) {
                az.bp.bz += u;
            } else {

                az.bp.bi += u;
            }
            az.bq[bn].ap = ao;
            az.bq[bn].am = u;
        }

        emit VoteCast(al, bn, ao, u);

        if (az.at.as == VotingMode.EarlyExecution) {
            d(al, ar());
        }
    }


    function bb(uint256 al, address bn) external bu(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage az = ay[al];
        if (!q(az)) {
            revert VoteRemovalForbidden(al, bn);
        } else if (az.at.as != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(al, bn);
        } else if (az.bq[bn].am == 0) {

            return;
        }


        if (az.bq[bn].ap == VoteOption.Yes) {
            az.bp.bx -= az.bq[bn].am;
        } else if (az.bq[bn].ap == VoteOption.No) {
            az.bp.bz -= az.bq[bn].am;
        }

        else if (az.bq[bn].ap == VoteOption.Abstain) {
            az.bp.bi -= az.bq[bn].am;
        }
        az.bq[bn].am = 0;

        emit VoteCleared(al, bn);
    }


    function y(uint256 al) external view returns (bool) {
        Proposal storage az = ay[al];
        return q(az);
    }


    function e() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase.e();
    }


    function i() public view override returns (uint256) {
        return IERC20(an.br()).ai();
    }


    function r(uint256 al, address bn) public view returns (uint256) {
        return ay[al].bq[bn].am;
    }


    function bg(Proposal storage az, address bn, VoteOption ao, uint256 u)
        internal
        view
        returns (bool)
    {
        uint256 h = az.bq[bn].am;


        if (!q(az)) {
            return false;
        } else if (ao == VoteOption.None) {
            return false;
        }

        else if (az.at.as != VotingMode.VoteReplacement) {

            if (u <= h) {
                return false;
            }

            else if (
                az.bq[bn].ap != VoteOption.None
                    && ao != az.bq[bn].ap
            ) {
                return false;
            }
        }

        else {

            if (u == 0 || u < h) {
                return false;
            }

            else if (u == h && ao == az.bq[bn].ap) {
                return false;
            }
        }

        return true;
    }

    function d(uint256 al, address aj) internal {
        if (!ak(al)) {
            return;
        } else if (!by().aa(address(this), aj, EXECUTE_PROPOSAL_PERMISSION_ID, bf())) {
            return;
        }

        bc(al);
    }

    function bc(uint256 al) internal override {
        super.bc(al);


        an.ac(al);
    }


    uint256[50] private __gap;
}