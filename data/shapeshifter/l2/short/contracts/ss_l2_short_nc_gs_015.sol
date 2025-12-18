pragma solidity ^0.8.13;

import {ILockManager, LockManagerSettings, PluginMode} from "../interfaces/ILockManager.sol";
import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockToVote} from "../interfaces/ILockToVote.sol";
import {IMajorityVoting} from "../interfaces/IMajorityVoting.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


abstract contract LockManagerBase is ILockManager {
    using EnumerableSet for EnumerableSet.UintSet;


    LockManagerSettings public ad;


    ILockToGovernBase public aj;


    mapping(address => uint256) private r;


    EnumerableSet.UintSet internal l;


    event BalanceLocked(address am, uint256 ah);


    event BalanceUnlocked(address am, uint256 ah);


    event ProposalEnded(uint256 x);


    error InvalidPluginAddress();


    error NoBalance();


    error LocksStillActive();


    error InvalidPlugin();


    error InvalidPluginMode();


    error SetPluginAddressForbidden();


    constructor(LockManagerSettings memory aa) {
        ad.z = aa.z;
    }


    function h(uint256 al) public view virtual returns (uint256) {
        return l.at(al);
    }


    function b() public view virtual returns (uint256) {
        return l.length();
    }


    function ap() public virtual {
        ao(c());
    }


    function ap(uint256 ae) public virtual {
        ao(ae);
    }


    function w(uint256 v, IMajorityVoting.VoteOption t) public virtual {
        if (ad.z != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        ao(c());
        an(v, t);
    }


    function w(uint256 v, IMajorityVoting.VoteOption t, uint256 ae) public virtual {
        if (ad.z != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        ao(ae);
        an(v, t);
    }


    function aq(uint256 v, IMajorityVoting.VoteOption t) public virtual {
        if (ad.z != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        an(v, t);
    }


    function j(address ac) public view virtual returns (uint256) {
        return r[ac];
    }


    function af(uint256 v, address ai, IMajorityVoting.VoteOption t)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(aj)).af(v, ai, t);
    }


    function ag() public virtual {
        uint256 e = j(msg.sender);
        if (e == 0) {
            revert NoBalance();
        }


        a();


        r[msg.sender] = 0;


        f(msg.sender, e);
        emit BalanceUnlocked(msg.sender, e);
    }


    function n(uint256 v) public virtual {
        if (msg.sender != address(aj)) {
            revert InvalidPluginAddress();
        }


        l.ar(v);
    }


    function s(uint256 v) public virtual {
        if (msg.sender != address(aj)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(v);
        l.ak(v);
    }


    function k(ILockToGovernBase i) public virtual {
        if (address(aj) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(i)).g(type(ILockToGovernBase).u)) {
            revert InvalidPlugin();
        }

        else if (
            ad.z == PluginMode.Voting
                && !IERC165(address(i)).g(type(ILockToVote).u)
        ) {
            revert InvalidPlugin();
        }

        aj = i;
    }


    function c() internal view virtual returns (uint256);


    function ao(uint256 ae) internal virtual {
        if (ae == 0) {
            revert NoBalance();
        }


        m(ae);

        r[msg.sender] += ae;
        emit BalanceLocked(msg.sender, ae);
    }


    function m(uint256 ae) internal virtual;


    function f(address y, uint256 ae) internal virtual;

    function an(uint256 v, IMajorityVoting.VoteOption t) internal virtual {
        uint256 d = j(msg.sender);


        ILockToVote(address(aj)).aq(v, msg.sender, t, d);
    }

    function a() internal virtual {
        uint256 p = l.length();
        for (uint256 as; as < p;) {
            uint256 v = l.at(as);
            if (!aj.q(v)) {
                l.ak(v);
                p = l.length();


                if (as == p) {
                    return;
                }


                continue;
            }

            if (aj.o(v, msg.sender) > 0) {
                ILockToVote(address(aj)).ab(v, msg.sender);
            }

            unchecked {
                as++;
            }
        }
    }
}