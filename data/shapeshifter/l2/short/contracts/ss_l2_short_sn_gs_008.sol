// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IVotingEscrow.sol";
import "./interfaces/IVoter.sol";
import "./interfaces/IBribe.sol";
import "./interfaces/IRewardsDistributor.sol";
import "./interfaces/IGaugeManager.sol";
import "./interfaces/ISwapper.sol";
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title GovernanceHYBR (gHYBR)
 * @notice Auto-compounding staking token that locks HYBR as veHYBR and compounds rewards
 * @dev Implements transfer restrictions for new deposits and automatic reward compounding
 */
contract GrowthHYBR is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    // Lock period for new deposits (configurable between 12-24 hours)
    uint256 public l = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public b = 1200; // 5days
    uint256 public c = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public bi = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public du;
    uint256 public dk;
    uint256 public bp;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 dv;
        uint256 cb;
    }

    mapping(address => UserLock[]) public ck;
    mapping(address => uint256) public ai;

    // Core contracts
    address public immutable HYBR;
    address public immutable at;
    address public ei;
    address public k;
    address public aw;
    uint256 public ci; // The veNFT owned by this contract

    // Auto-voting strategy
    address public cv; // Address that can manage voting strategy
    uint256 public am; // Last epoch when we voted

    // Reward tracking
    uint256 public ac;
    uint256 public n;

    // Swap module
    ISwapper public de;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed en, uint256 cc, uint256 ah);
    event Withdraw(address indexed en, uint256 dw, uint256 cc, uint256 eq);
    event Compound(uint256 di, uint256 ag);
    event PenaltyRewardReceived(uint256 dv);
    event TransferLockPeriodUpdated(uint256 cm, uint256 cs);
    event SwapperUpdated(address indexed by, address indexed ce);
    event VoterSet(address ei);
    event EmergencyUnlock(address indexed en);
    event AutoVotingEnabled(bool dd);
    event OperatorUpdated(address indexed bt, address indexed bh);
    event DefaultVotingStrategyUpdated(address[] eb, uint256[] dm);
    event AutoVoteExecuted(uint256 ee, address[] eb, uint256[] dm);

    constructor(
        address el,
        address aq
    ) ERC20("Growth HYBR", "gHYBR") {
        require(el != address(0), "Invalid HYBR");
        require(aq != address(0), "Invalid VE");

        HYBR = el;
        at = aq;
        ac = block.timestamp;
        n = block.timestamp;
        cv = msg.sender; // Initially set deployer as operator
    }

    function f(address j) external ct {
        require(j != address(0), "Invalid rewards distributor");
        k = j;
    }

    function u(address al) external ct {
        require(al != address(0), "Invalid gauge manager");
        aw = al;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier be() {
        if (msg.sender != cv) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function df(uint256 dv, address cn) external bc {
        require(dv > 0, "Zero amount");
        cn = cn == address(0) ? msg.sender : cn;

        // Transfer HYBR from user first
        IERC20(HYBR).ax(msg.sender, address(this), dv);

        // Initialize veNFT on first deposit
        if (ci == 0) {
            q(dv);
        } else {
            // Add to existing veNFT
            IERC20(HYBR).dg(at, dv);
            IVotingEscrow(at).bf(ci, dv);

            // Extend lock to maximum duration
            t();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 dw = w(dv);

        // Mint gHYBR shares
        eh(cn, dw);

        // Add transfer lock for recipient
        s(cn, dw);

        emit Deposit(msg.sender, dv, dw);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function cx(uint256 dw) external bc returns (uint256 bq) {
        require(dw > 0, "Zero shares");
        require(co(msg.sender) >= dw, "Insufficient balance");
        require(ci != 0, "No veNFT initialized");
        require(IVotingEscrow(at).dx(ci) == false, "Cannot withdraw yet");

        uint256 bz = HybraTimeLibrary.bz(block.timestamp);
        uint256 cl = HybraTimeLibrary.cl(block.timestamp);

        require(block.timestamp >= bz + b && block.timestamp < cl - c, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 cc = z(dw);
        require(cc > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 cr = 0;
        if (bi > 0) {
            cr = (cc * bi) / BASIS;
        }

        // User receives amount minus fee
        uint256 cf = cc - cr;
        require(cf > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 ch = bu();
        require(cc <= ch, "Insufficient veNFT balance");

        uint256 v = ch - cf - cr;
        require(v >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        ed(msg.sender, dw);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory dh = new uint256[](3);
        dh[0] = v; // Amount staying with gHYBR
        dh[1] = cf;      // Amount going to user (after fee)
        dh[2] = cr;      // Amount going to fee recipient

        uint256[] memory bl = IVotingEscrow(at).bv(ci, dh);

        // Update contract's veTokenId to the first new token
        ci = bl[0];
        bq = bl[1];
        uint256 bx = bl[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(at).o(address(this), msg.sender, bq);
        IVotingEscrow(at).o(address(this), Team, bx);
        emit Withdraw(msg.sender, dw, cf, cr);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function q(uint256 an) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR).dg(at, type(uint256).ep);
        uint256 cz = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        ci = IVotingEscrow(at).x(an, cz, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function w(uint256 dv) public view returns (uint256) {
        uint256 az = bm();
        uint256 bd = bu();
        if (az == 0 || bd == 0) {
            return dv;
        }
        return (dv * az) / bd;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function z(uint256 dw) public view returns (uint256) {
        uint256 az = bm();
        if (az == 0) {
            return dw;
        }
        return (dw * bu()) / az;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function bu() public view returns (uint256) {
        if (ci == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory ds = IVotingEscrow(at).ds(ci);
        return uint256(int256(ds.dv));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function s(address en, uint256 dv) internal {
        uint256 cb = block.timestamp + l;
        ck[en].push(UserLock({
            dv: dv,
            cb: cb
        }));
        ai[en] += dv;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function r(address en) external view returns (uint256 cp) {
        uint256 au = co(en);
        uint256 ak = 0;

        UserLock[] storage er = ck[en];
        for (uint256 i = 0; i < er.length; i++) {
            if (er[i].cb > block.timestamp) {
                ak += er[i].dv;
            }
        }

        return au > ak ? au - ak : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function ao(address en) internal returns (uint256 ek) {
        UserLock[] storage er = ck[en];
        uint256 es = er.length;
        if (es == 0) return 0;

        uint256 eg = 0;
        unchecked {
            for (uint256 i = 0; i < es; i++) {
                UserLock memory L = er[i];
                if (L.cb <= block.timestamp) {
                    ek += L.dv;
                } else {
                    if (eg != i) er[eg] = L;
                    eg++;
                }
            }
            if (ek > 0) {
                ai[en] -= ek;
            }
            while (er.length > eg) {
                er.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function i(
        address from,
        address eu,
        uint256 dv
    ) internal override {
        super.i(from, eu, dv);

        if (from != address(0) && eu != address(0)) { // Not mint or burn
            uint256 au = co(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 p = au > ai[from] ? au - ai[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (p >= dv) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            ao(from);
            uint256 ae = au > ai[from] ? au - ai[from] : 0;

            // Step 4: Check final available balance
            require(ae >= dv, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function as() external be {
        require(ei != address(0), "Voter not set");
        require(k != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  bb = IRewardsDistributor(k).ej(ci);
        du += bb;
        // Claim bribes from voted pools
        address[] memory cg = IVoter(ei).da(ci);

        for (uint256 i = 0; i < cg.length; i++) {
            if (cg[i] != address(0)) {
                address dz = IGaugeManager(aw).dr(cg[i]);

                if (dz != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory dt = new address[](1);
                    address[][] memory dp = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address ar = IGaugeManager(aw).ab(dz);
                    if (ar != address(0)) {
                        uint256 bw = IBribe(ar).m();
                        if (bw > 0) {
                            address[] memory bs = new address[](bw);
                            for (uint256 j = 0; j < bw; j++) {
                                bs[j] = IBribe(ar).bs(j);
                            }
                            dt[0] = ar;
                            dp[0] = bs;
                            // Call claimBribes for this single bribe
                            IGaugeManager(aw).bg(dt, dp, ci);
                        }
                    }

                    // Claim external bribe
                    address ap = IGaugeManager(aw).aa(dz);
                    if (ap != address(0)) {
                        uint256 bw = IBribe(ap).m();
                        if (bw > 0) {
                            address[] memory bs = new address[](bw);
                            for (uint256 j = 0; j < bw; j++) {
                                bs[j] = IBribe(ap).bs(j);
                            }
                            dt[0] = ap;
                            dp[0] = bs;
                            // Call claimBribes for this single bribe
                            IGaugeManager(aw).bg(dt, dp, ci);
                        }
                    }
                }
            }
        }
    }

    /**
     * @notice Execute swap through the configured swapper module
     * @param _params Swap parameters for the swapper module
     */
    function bk(ISwapper.SwapParams calldata dj) external bc be {
        require(address(de) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 ba = IERC20(dj.dl).co(address(this));
        require(ba >= dj.cw, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(dj.dl).bj(address(de), dj.cw);

        // Execute swap through swapper module
        uint256 ay = de.ca(dj);

        // Reset approval for safety
        IERC20(dj.dl).bj(address(de), 0);

        // HYBR is now in this contract, ready for compounding
        bp += ay;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function db() external be {

        // Get current HYBR balance
        uint256 br = IERC20(HYBR).co(address(this));

        if (br > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR).bj(at, br);
            IVotingEscrow(at).bf(ci, br);

            // Extend lock to maximum duration
            t();

            n = block.timestamp;

            emit Compound(br, bu());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function eo(address[] calldata cq, uint256[] calldata cu) external {
        require(msg.sender == ef() || msg.sender == cv, "Not authorized");
        require(ei != address(0), "Voter not set");

        IVoter(ei).eo(ci, cq, cu);
        am = HybraTimeLibrary.bz(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function ec() external {
        require(msg.sender == ef() || msg.sender == cv, "Not authorized");
        require(ei != address(0), "Voter not set");

        IVoter(ei).ec(ci);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function g(uint256 dv) external {

        // Auto-compound penalty rewards to existing veNFT
        if (dv > 0) {
            IERC20(HYBR).dg(at, dv);

            if(ci == 0){
                q(dv);
            } else{
                IVotingEscrow(at).bf(ci, dv);

                // Extend lock to maximum duration
                t();
            }
        }
        dk += dv;
        emit PenaltyRewardReceived(dv);
    }

    /**
     * @notice Set the voter contract
     */
    function cy(address dq) external ct {
        require(dq != address(0), "Invalid voter");
        ei = dq;
        emit VoterSet(dq);
    }

    /**
     * @notice Update transfer lock period
     */
    function e(uint256 do) external ct {
        require(do >= MIN_LOCK_PERIOD && do <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 cm = l;
        l = do;
        emit TransferLockPeriodUpdated(cm, do);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function af(uint256 em) external ct {
        require(em >= MIN_WITHDRAW_FEE && em <= MAX_WITHDRAW_FEE, "Invalid fee");
        bi = em;
    }

    function a(uint256 dy) external ct {
        b = dy;
    }

    function d(uint256 dy) external ct {
        c = dy;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function cd(address dc) external ct {
        require(dc != address(0), "Invalid swapper");
        address by = address(de);
        de = ISwapper(dc);
        emit SwapperUpdated(by, dc);
    }

    /**
     * @notice Set the team address
     */
    function dn(address ea) external ct {
        require(ea != address(0), "Invalid team");
        Team = ea;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function y(address en) external be {
        delete ck[en];
        ai[en] = 0;
        emit EmergencyUnlock(en);
    }

    /**
     * @notice Get user's locks info
     */
    function av(address en) external view returns (UserLock[] memory) {
        return ck[en];
    }

    /**
     * @notice Set operator address
     */
    function bo(address cj) external ct {
        require(cj != address(0), "Invalid operator");
        address bt = cv;
        cv = cj;
        emit OperatorUpdated(bt, cj);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function ad() external view returns (uint256) {
        if (ci == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory ds = IVotingEscrow(at).ds(ci);
        return uint256(ds.et);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function t() internal {
        if (ci == 0) return;

        IVotingEscrow.LockedBalance memory ds = IVotingEscrow(at).ds(ci);
        if (ds.bn || ds.et <= block.timestamp) return;

        uint256 aj = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (aj > ds.et + 2 hours) {
            try IVotingEscrow(at).h(ci, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}