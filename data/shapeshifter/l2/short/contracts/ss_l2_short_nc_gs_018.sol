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
        this.d.selector ^ this.z.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = ax("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = ax("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 au, address bs);

    error VoteRemovalForbidden(uint256 au, address bs);


    function as(
        IDAO bw,
        ILockManager af,
        VotingSettings calldata q,
        IPlugin.TargetConfig calldata ab,
        bytes calldata w
    ) external a ac(1) {
        __MajorityVotingBase_init(bw, q, ab, w);
        __LockToGovernBase_init(af);

        emit MembershipContractAnnounced({l: address(af.bo())});
    }


    function j(bytes4 ag)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return ag == LOCK_TO_VOTE_INTERFACE_ID || ag == type(ILockToVote).an
            || super.j(ag);
    }


    function b() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function z(
        bytes calldata az,
        Action[] memory bg,
        uint64 av,
        uint64 bf,
        bytes memory bq
    ) external bt(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 au) {
        uint256 m;

        if (bq.length != 0) {
            (m) = abi.bm(bq, (uint256));
        }

        if (i() == 0) {
            revert NoVotingPower();
        }


        (av, bf) = e(av, bf);

        au = k(ax(abi.bl(bg, az)));

        if (v(au)) {
            revert ProposalAlreadyExists(au);
        }


        Proposal storage ba = bb[au];

        ba.at.ar = ar();
        ba.at.f = f();
        ba.at.aw = av;
        ba.at.bh = bf;
        ba.at.g = g();
        ba.at.n = n();

        ba.ae = r();


        if (m != 0) {
            ba.p = m;
        }

        for (uint256 i; i < bg.length;) {
            ba.bj.push(bg[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(au, aq(), av, bf, az, bg, m);

        al.x(au);
    }


    function bk(uint256 ak, address bn, VoteOption ah) public view returns (bool) {
        if (!v(ak)) {
            revert NonexistentProposal(ak);
        }

        Proposal storage ba = bb[ak];
        return bd(ba, bn, ah, al.o(bn));
    }


    function bv(uint256 ak, address bn, VoteOption ah, uint256 s)
        public
        override
        bt(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage ba = bb[ak];

        if (!bd(ba, bn, ah, s)) {
            revert VoteCastForbidden(ak, bn);
        }


        if (ah == ba.bp[bn].ap) {

            if (s == ba.bp[bn].aj) return;


            uint256 bu = s - ba.bp[bn].aj;
            ba.bp[bn].aj = s;

            if (ba.bp[bn].ap == VoteOption.Yes) {
                ba.br.bx += bu;
            } else if (ba.bp[bn].ap == VoteOption.No) {
                ba.br.bz += bu;
            } else {

                ba.br.bi += bu;
            }
        } else {


            if (ba.bp[bn].aj > 0) {

                if (ba.bp[bn].ap == VoteOption.Yes) {
                    ba.br.bx -= ba.bp[bn].aj;
                } else if (ba.bp[bn].ap == VoteOption.No) {
                    ba.br.bz -= ba.bp[bn].aj;
                } else {

                    ba.br.bi -= ba.bp[bn].aj;
                }
            }


            if (ah == VoteOption.Yes) {
                ba.br.bx += s;
            } else if (ah == VoteOption.No) {
                ba.br.bz += s;
            } else {

                ba.br.bi += s;
            }
            ba.bp[bn].ap = ah;
            ba.bp[bn].aj = s;
        }

        emit VoteCast(ak, bn, ah, s);

        if (ba.at.ar == VotingMode.EarlyExecution) {
            c(ak, aq());
        }
    }


    function ay(uint256 ak, address bn) external bt(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage ba = bb[ak];
        if (!u(ba)) {
            revert VoteRemovalForbidden(ak, bn);
        } else if (ba.at.ar != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(ak, bn);
        } else if (ba.bp[bn].aj == 0) {

            return;
        }


        if (ba.bp[bn].ap == VoteOption.Yes) {
            ba.br.bx -= ba.bp[bn].aj;
        } else if (ba.bp[bn].ap == VoteOption.No) {
            ba.br.bz -= ba.bp[bn].aj;
        }

        else if (ba.bp[bn].ap == VoteOption.Abstain) {
            ba.br.bi -= ba.bp[bn].aj;
        }
        ba.bp[bn].aj = 0;

        emit VoteCleared(ak, bn);
    }


    function y(uint256 ak) external view returns (bool) {
        Proposal storage ba = bb[ak];
        return u(ba);
    }


    function d() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase.d();
    }


    function i() public view override returns (uint256) {
        return IERC20(al.bo()).ao();
    }


    function t(uint256 ak, address bn) public view returns (uint256) {
        return bb[ak].bp[bn].aj;
    }


    function bd(Proposal storage ba, address bn, VoteOption ah, uint256 s)
        internal
        view
        returns (bool)
    {
        uint256 h = ba.bp[bn].aj;


        if (!u(ba)) {
            return false;
        } else if (ah == VoteOption.None) {
            return false;
        }

        else if (ba.at.ar != VotingMode.VoteReplacement) {

            if (s <= h) {
                return false;
            }

            else if (
                ba.bp[bn].ap != VoteOption.None
                    && ah != ba.bp[bn].ap
            ) {
                return false;
            }
        }

        else {

            if (s == 0 || s < h) {
                return false;
            }

            else if (s == h && ah == ba.bp[bn].ap) {
                return false;
            }
        }

        return true;
    }

    function c(uint256 ak, address am) internal {
        if (!ai(ak)) {
            return;
        } else if (!by().aa(address(this), am, EXECUTE_PROPOSAL_PERMISSION_ID, bc())) {
            return;
        }

        be(ak);
    }

    function be(uint256 ak) internal override {
        super.be(ak);


        al.ad(ak);
    }


    uint256[50] private __gap;
}