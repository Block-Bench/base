// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {ILiquidityBuffer} from "./interfaces/ILiquidityBuffer.sol";
import {IPositionManager} from "./interfaces/IPositionManager.sol";
import {IStakingReturnsWrite} from "../interfaces/IStaking.sol";
import {IPauserRead} from "../interfaces/IPauser.sol";
import {ProtocolEvents} from "../interfaces/ProtocolEvents.sol";

interface LiquidityBufferEvents {
    event ETHWithdrawnFromManager(uint256 indexed cd, uint256 cn);
    event ETHReturnedToStaking(uint256 cn);
    event ETHAllocatedToManager(uint256 indexed cd, uint256 cn);
    event ETHReceivedFromStaking(uint256 cn);
    event FeesCollected(uint256 cn);
    event InterestClaimed(
        uint256 indexed cd,
        uint256 bm
    );
    event InterestToppedUp(
        uint256 cn
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = cb("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = cb("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = cb("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = cb("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant i = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public bb;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public cl;

    /// @notice Total number of position managers
    uint256 public ad;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public o;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public af;

    /// @notice Total funds received from staking contract
    uint256 public am;

    /// @notice Total funds returned to staking contract
    uint256 public an;

    /// @notice Total allocated balance across all position managers
    uint256 public v;

    /// @notice Total interest claimed from position managers
    uint256 public ac;

    /// @notice Total interest topped up to staking contract
    uint256 public s;

    /// @notice Total allocation capacity across all managers
    uint256 public k;

    /// @notice Cumulative drawdown amount
    uint256 public ar;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public ba;

    /// @notice The address receiving protocol fees.
    address payable public bs;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public bg;

    uint256 public aq;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public be;

    /// @notice Tracks pending principal available for operations
    uint256 public aw;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public l;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public ag;

    struct Init {
        address cq;
        address ay;
        address bf;
        address bq;
        address bc;
        address payable bs;
        IStakingReturnsWrite ci;
        IPauserRead cl;
    }

    // ========================================= ERRORS =========================================

    error LiquidityBuffer__ManagerNotFound();
    error LiquidityBuffer__ManagerInactive();
    error LiquidityBuffer__ManagerAlreadyRegistered();
    error LiquidityBuffer__ExceedsAllocationCap();
    error LiquidityBuffer__InsufficientBalance();
    error LiquidityBuffer__InsufficientAllocation();
    error LiquidityBuffer__DoesNotReceiveETH();
    error LiquidityBuffer__Paused();
    error LiquidityBuffer__InvalidConfiguration();
    error LiquidityBuffer__ZeroAddress();
    error LiquidityBuffer__NotStakingContract();
    error LiquidityBuffer__NotPositionManagerContract();
    error LiquidityBuffer__ExceedsPendingInterest();
    error LiquidityBuffer__ExceedsPendingPrincipal();
    // ========================================= INITIALIZATION =========================================

    constructor() {
        ae();
    }

    function bw(Init memory ct) external bv {

        __AccessControlEnumerable_init();

        by(DEFAULT_ADMIN_ROLE, ct.cq);
        by(LIQUIDITY_MANAGER_ROLE, ct.ay);
        by(POSITION_MANAGER_ROLE, ct.bf);
        by(INTEREST_TOPUP_ROLE, ct.bq);
        by(DRAWDOWN_MANAGER_ROLE, ct.bc);

        bb = ct.ci;
        cl = ct.cl;
        bs = ct.bs;
        l = true;

        by(LIQUIDITY_MANAGER_ROLE, address(bb));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function at(uint256 cd) public view returns (uint256) {
        PositionManagerConfig memory ck = o[cd];
        // Get current underlying balance from position manager
        IPositionManager cj = IPositionManager(ck.bh);
        uint256 bj = cj.aa();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory bx = af[cd];

        if (bj > bx.ax) {
            return bj - bx.ax;
        }

        return 0;
    }

    function z() public view returns (uint256) {
        return k - v;
    }

    function aj() public view returns (uint256) {
        return am - an;
    }

    function y() public view returns (uint256) {
        uint256 br = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < ad; i++) {
            PositionManagerConfig storage ck = o[i];
            if (ck.cg) {
                IPositionManager cj = IPositionManager(ck.bh);
                uint256 bl = cj.aa();
                br += bl;
            }
        }

        return br;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function ap(
        address bh,
        uint256 bp
    ) external ce(POSITION_MANAGER_ROLE) returns (uint256 cd) {
        if (ag[bh]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        cd = ad;
        ad++;

        o[cd] = PositionManagerConfig({
            bh: bh,
            bp: bp,
            cg: true
        });
        af[cd] = PositionAccountant({
            ax: 0,
            f: 0
        });
        ag[bh] = true;

        k += bp;
        emit ProtocolConfigChanged(
            this.ap.selector,
            "addPositionManager(address,uint256)",
            abi.cm(bh, bp)
        );
    }

    function w(
        uint256 cd,
        uint256 az,
        bool cg
    ) external ce(POSITION_MANAGER_ROLE) {
        if (cd >= ad) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage ck = o[cd];

        if (az < af[cd].ax) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        k = k - ck.bp + az;

        ck.bp = az;
        ck.cg = cg;

        emit ProtocolConfigChanged(
            this.w.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi.cm(cd, az, cg)
        );
    }

    function d(uint256 cd) external ce(POSITION_MANAGER_ROLE) {
        if (cd >= ad) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage ck = o[cd];
        ck.cg = !ck.cg;

        emit ProtocolConfigChanged(
            this.d.selector,
            "togglePositionManagerStatus(uint256)",
            abi.cm(cd)
        );
    }

    function x(uint256 bo) external ce(DRAWDOWN_MANAGER_ROLE) {
        ar = bo;

        emit ProtocolConfigChanged(
            this.x.selector,
            "setCumulativeDrawdown(uint256)",
            abi.cm(bo)
        );
    }

    function al(uint256 ai) external ce(POSITION_MANAGER_ROLE) {
        if (ai >= ad) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!o[ai].cg) {
            revert LiquidityBuffer__ManagerInactive();
        }

        ba = ai;

        emit ProtocolConfigChanged(
            this.al.selector,
            "setDefaultManagerId(uint256)",
            abi.cm(ai)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function as(uint16 bn) external ce(POSITION_MANAGER_ROLE) {
        if (bn > i) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        bg = bn;
        emit ProtocolConfigChanged(
            this.as.selector, "setFeeBasisPoints(uint16)", abi.cm(bn)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function bd(address payable bu)
        external
        ce(POSITION_MANAGER_ROLE)
        bk(bu)
    {
        bs = bu;
        emit ProtocolConfigChanged(this.bd.selector, "setFeesReceiver(address)", abi.cm(bu));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function g(bool au) external ce(POSITION_MANAGER_ROLE) {
        l = au;
        emit ProtocolConfigChanged(this.g.selector, "setShouldExecuteAllocation(bool)", abi.cm(au));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function bz() external payable ce(LIQUIDITY_MANAGER_ROLE) {
        if (cl.n()) revert LiquidityBuffer__Paused();
        p(msg.value);
        if (l) {
            u(ba, msg.value);
        }
    }

    function av(uint256 cd, uint256 cn) external ce(LIQUIDITY_MANAGER_ROLE) {
        m(cd, cn);
        ak(cn);
    }

    function ab(uint256 cd, uint256 cn) external ce(LIQUIDITY_MANAGER_ROLE) {
        u(cd, cn);
    }

    function r(uint256 cd, uint256 cn) external ce(LIQUIDITY_MANAGER_ROLE) {
        m(cd, cn);
    }

    function ao(uint256 cn) external ce(LIQUIDITY_MANAGER_ROLE) {
        ak(cn);
    }

    function c() external payable e {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function j(uint256 cd, uint256 cc) external ce(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 cn = h(cd);
        if (cn < cc) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return cn;
    }

    function q(uint256 cn) external ce(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < cn) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        a(cn);
        return cn;
    }

    function t(uint256 cd, uint256 cc) external ce(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 cn = h(cd);
        if (cn < cc) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        a(cn);

        return cn;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function a(uint256 cn) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }
        if (cn > be) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        be -= cn;
        uint256 cs = Math.co(bg, cn, i);
        uint256 bt = cn - cs;
        bb.cp{value: bt}();
        s += bt;
        emit InterestToppedUp(bt);

        if (cs > 0) {
            Address.ca(bs, cs);
            aq += cs;
            emit FeesCollected(cs);
        }
    }

    function h(uint256 cd) internal returns (uint256) {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 bm = at(cd);

        if (bm > 0) {
            PositionManagerConfig memory ck = o[cd];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            af[cd].f += bm;
            ac += bm;
            be += bm;
            emit InterestClaimed(cd, bm);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager cj = IPositionManager(ck.bh);
            cj.cf(bm);
        } else {
            emit InterestClaimed(cd, bm);
        }

        return bm;
    }

    function m(uint256 cd, uint256 cn) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }
        if (cd >= ad) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory ck = o[cd];
        if (!ck.cg) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage bx = af[cd];

        // Check sufficient allocation
        if (cn > bx.ax) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        bx.ax -= cn;
        v -= cn;
        aw += cn;
        emit ETHWithdrawnFromManager(cd, cn);

        // Call position manager to withdraw AFTER state updates
        IPositionManager cj = IPositionManager(ck.bh);
        cj.cf(cn);
    }

    function ak(uint256 cn) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(bb) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (cn > aw) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        an += cn;
        aw -= cn;
        emit ETHReturnedToStaking(cn);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        bb.b{value: cn}();
    }

    function u(uint256 cd, uint256 cn) internal {
        if (cl.n()) {
            revert LiquidityBuffer__Paused();
        }
        if (cn > aw) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (cd >= ad) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < cn) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory ck = o[cd];
        if (!ck.cg) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage bx = af[cd];
        if (bx.ax + cn > ck.bp) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        bx.ax += cn;
        v += cn;
        aw -= cn;
        emit ETHAllocatedToManager(cd, cn);

        // deposit to position manager AFTER state updates
        IPositionManager cj = IPositionManager(ck.bh);
        cj.ch{value: cn}(0);
    }

    function p(uint256 cn) internal {
        am += cn;
        aw += cn;
        emit ETHReceivedFromStaking(cn);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier bk(address cr) {
        if (cr == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier ah() {
        if (msg.sender != address(bb)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier e() {
        bool bi = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < ad; i++) {
            PositionManagerConfig memory ck = o[i];

            if (msg.sender == ck.bh && ck.cg) {
                bi = true;
                break;
            }
        }

        if (!bi) {
            revert LiquidityBuffer__NotPositionManagerContract();
        }
        _;
    }

    receive() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }

    fallback() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }
}