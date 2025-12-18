pragma solidity ^0.8.13;

import {ILockManager, LockManagerSettings, PluginMode} from "../interfaces/ILockManager.sol";
import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockToVote} from "../interfaces/ILockToVote.sol";
import {IMajorityVoting} from "../interfaces/IMajorityVoting.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


abstract contract LockManagerBase is ILockManager {
    using EnumerableSet for EnumerableSet.UintSet;


    LockManagerSettings public ac;


    ILockToGovernBase public al;


    mapping(address => uint256) private q;


    EnumerableSet.UintSet internal k;


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
        ac.y = aa.y;
    }


    function h(uint256 aj) public view virtual returns (uint256) {
        return k.as(aj);
    }


    function b() public view virtual returns (uint256) {
        return k.length();
    }


    function aq() public virtual {
        an(c());
    }


    function aq(uint256 ae) public virtual {
        an(ae);
    }


    function v(uint256 w, IMajorityVoting.VoteOption u) public virtual {
        if (ac.y != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        an(c());
        ao(w, u);
    }


    function v(uint256 w, IMajorityVoting.VoteOption u, uint256 ae) public virtual {
        if (ac.y != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        an(ae);
        ao(w, u);
    }


    function ap(uint256 w, IMajorityVoting.VoteOption u) public virtual {
        if (ac.y != PluginMode.Voting) {
            revert InvalidPluginMode();
        }

        ao(w, u);
    }


    function l(address ad) public view virtual returns (uint256) {
        return q[ad];
    }


    function af(uint256 w, address ai, IMajorityVoting.VoteOption u)
        external
        view
        virtual
        returns (bool)
    {
        return ILockToVote(address(al)).af(w, ai, u);
    }


    function ag() public virtual {
        uint256 e = l(msg.sender);
        if (e == 0) {
            revert NoBalance();
        }


        a();


        q[msg.sender] = 0;


        i(msg.sender, e);
        emit BalanceUnlocked(msg.sender, e);
    }


    function n(uint256 w) public virtual {
        if (msg.sender != address(al)) {
            revert InvalidPluginAddress();
        }


        k.ar(w);
    }


    function s(uint256 w) public virtual {
        if (msg.sender != address(al)) {
            revert InvalidPluginAddress();
        }

        emit ProposalEnded(w);
        k.ak(w);
    }


    function j(ILockToGovernBase g) public virtual {
        if (address(al) != address(0)) {
            revert SetPluginAddressForbidden();
        } else if (!IERC165(address(g)).f(type(ILockToGovernBase).t)) {
            revert InvalidPlugin();
        }

        else if (
            ac.y == PluginMode.Voting
                && !IERC165(address(g)).f(type(ILockToVote).t)
        ) {
            revert InvalidPlugin();
        }

        al = g;
    }


    function c() internal view virtual returns (uint256);


    function an(uint256 ae) internal virtual {
        if (ae == 0) {
            revert NoBalance();
        }


        m(ae);

        q[msg.sender] += ae;
        emit BalanceLocked(msg.sender, ae);
    }


    function m(uint256 ae) internal virtual;


    function i(address z, uint256 ae) internal virtual;

    function ao(uint256 w, IMajorityVoting.VoteOption u) internal virtual {
        uint256 d = l(msg.sender);


        ILockToVote(address(al)).ap(w, msg.sender, u, d);
    }

    function a() internal virtual {
        uint256 r = k.length();
        for (uint256 at; at < r;) {
            uint256 w = k.as(at);
            if (!al.p(w)) {
                k.ak(w);
                r = k.length();


                if (at == r) {
                    return;
                }


                continue;
            }

            if (al.o(w, msg.sender) > 0) {
                ILockToVote(address(al)).ab(w, msg.sender);
            }

            unchecked {
                at++;
            }
        }
    }
}