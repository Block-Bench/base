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
    uint256 public _0xbe2390 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x0dc852 = 1200; // 5days
    uint256 public _0xf80792 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0x3d0f4f = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x955bbb;
    uint256 public _0xbb663d;
    uint256 public _0x95c23e;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x1b3d67;
        uint256 _0x7d3e11;
    }

    mapping(address => UserLock[]) public _0xd0ddf3;
    mapping(address => uint256) public _0x92082b;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0xf973eb;
    address public _0x73b9b8;
    address public _0x32463b;
    address public _0x29d856;
    uint256 public _0x4d642b; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0x47eaa7; // Address that can manage voting strategy
    uint256 public _0x8662a8; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x222cf5;
    uint256 public _0x78b0f4;

    // Swap module
    ISwapper public _0xf0fa28;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0xc4cb9f, uint256 _0x3290a4, uint256 _0x19666b);
    event Withdraw(address indexed _0xc4cb9f, uint256 _0xd0f815, uint256 _0x3290a4, uint256 _0xe3e2c3);
    event Compound(uint256 _0x8be3a2, uint256 _0x496b91);
    event PenaltyRewardReceived(uint256 _0x1b3d67);
    event TransferLockPeriodUpdated(uint256 _0x30b604, uint256 _0x30ae58);
    event SwapperUpdated(address indexed _0x0ef62e, address indexed _0x869361);
    event VoterSet(address _0x73b9b8);
    event EmergencyUnlock(address indexed _0xc4cb9f);
    event AutoVotingEnabled(bool _0x80b1c8);
    event OperatorUpdated(address indexed _0x2bbadb, address indexed _0x5985ac);
    event DefaultVotingStrategyUpdated(address[] _0xa058c4, uint256[] _0x958ebe);
    event AutoVoteExecuted(uint256 _0x1fdd42, address[] _0xa058c4, uint256[] _0x958ebe);

    constructor(
        address _0x435a3d,
        address _0xd0fcb9
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0x435a3d != address(0), "Invalid HYBR");
        require(_0xd0fcb9 != address(0), "Invalid VE");

        HYBR = _0x435a3d;
        _0xf973eb = _0xd0fcb9;
        _0x222cf5 = block.timestamp;
        _0x78b0f4 = block.timestamp;
        _0x47eaa7 = msg.sender; // Initially set deployer as operator
    }

    function _0x67103b(address _0xb97b58) external _0xc34fba {
        require(_0xb97b58 != address(0), "Invalid rewards distributor");
        _0x32463b = _0xb97b58;
    }

    function _0xb0608d(address _0x9aa5f8) external _0xc34fba {
        require(_0x9aa5f8 != address(0), "Invalid gauge manager");
        _0x29d856 = _0x9aa5f8;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0xedbc8f() {
        if (msg.sender != _0x47eaa7) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0xf64c1b(uint256 _0x1b3d67, address _0xefe868) external _0x78f0a4 {
        require(_0x1b3d67 > 0, "Zero amount");
        _0xefe868 = _0xefe868 == address(0) ? msg.sender : _0xefe868;

        // Transfer HYBR from user first
        IERC20(HYBR)._0x10db0a(msg.sender, address(this), _0x1b3d67);

        // Initialize veNFT on first deposit
        if (_0x4d642b == 0) {
            _0xb8d615(_0x1b3d67);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x152e36(_0xf973eb, _0x1b3d67);
            IVotingEscrow(_0xf973eb)._0x1841e0(_0x4d642b, _0x1b3d67);

            // Extend lock to maximum duration
            _0x058960();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0xd0f815 = _0xe71b00(_0x1b3d67);

        // Mint gHYBR shares
        _0xbdf3eb(_0xefe868, _0xd0f815);

        // Add transfer lock for recipient
        _0xfd84d0(_0xefe868, _0xd0f815);

        emit Deposit(msg.sender, _0x1b3d67, _0xd0f815);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0x34c1af(uint256 _0xd0f815) external _0x78f0a4 returns (uint256 _0xb81f0b) {
        require(_0xd0f815 > 0, "Zero shares");
        require(_0x6d6164(msg.sender) >= _0xd0f815, "Insufficient balance");
        require(_0x4d642b != 0, "No veNFT initialized");
        require(IVotingEscrow(_0xf973eb)._0x13e23f(_0x4d642b) == false, "Cannot withdraw yet");

        uint256 _0xfc7860 = HybraTimeLibrary._0xfc7860(block.timestamp);
        uint256 _0xe601dc = HybraTimeLibrary._0xe601dc(block.timestamp);

        require(block.timestamp >= _0xfc7860 + _0x0dc852 && block.timestamp < _0xe601dc - _0xf80792, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x3290a4 = _0x43c5e7(_0xd0f815);
        require(_0x3290a4 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0xdc5c10 = 0;
        if (_0x3d0f4f > 0) {
            _0xdc5c10 = (_0x3290a4 * _0x3d0f4f) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0x31b902 = _0x3290a4 - _0xdc5c10;
        require(_0x31b902 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0xaa2a69 = _0xbb9eb9();
        require(_0x3290a4 <= _0xaa2a69, "Insufficient veNFT balance");

        uint256 _0xf5a3d1 = _0xaa2a69 - _0x31b902 - _0xdc5c10;
        require(_0xf5a3d1 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x6c3a7d(msg.sender, _0xd0f815);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0xebbc05 = new uint256[](3);
        _0xebbc05[0] = _0xf5a3d1; // Amount staying with gHYBR
        _0xebbc05[1] = _0x31b902;      // Amount going to user (after fee)
        _0xebbc05[2] = _0xdc5c10;      // Amount going to fee recipient

        uint256[] memory _0x6ee3bd = IVotingEscrow(_0xf973eb)._0x7c4cb5(_0x4d642b, _0xebbc05);

        // Update contract's veTokenId to the first new token
        _0x4d642b = _0x6ee3bd[0];
        if (1 == 1) { _0xb81f0b = _0x6ee3bd[1]; }
        uint256 _0x8d2652 = _0x6ee3bd[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0xf973eb)._0xacb51c(address(this), msg.sender, _0xb81f0b);
        IVotingEscrow(_0xf973eb)._0xacb51c(address(this), Team, _0x8d2652);
        emit Withdraw(msg.sender, _0xd0f815, _0x31b902, _0xdc5c10);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0xb8d615(uint256 _0xae0c53) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x152e36(_0xf973eb, type(uint256)._0x0c0d19);
        uint256 _0x97e6f9 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x4d642b = IVotingEscrow(_0xf973eb)._0x308b87(_0xae0c53, _0x97e6f9, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0xe71b00(uint256 _0x1b3d67) public view returns (uint256) {
        uint256 _0x0fa401 = _0x0179fb();
        uint256 _0xd9e5c4 = _0xbb9eb9();
        if (_0x0fa401 == 0 || _0xd9e5c4 == 0) {
            return _0x1b3d67;
        }
        return (_0x1b3d67 * _0x0fa401) / _0xd9e5c4;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x43c5e7(uint256 _0xd0f815) public view returns (uint256) {
        uint256 _0x0fa401 = _0x0179fb();
        if (_0x0fa401 == 0) {
            return _0xd0f815;
        }
        return (_0xd0f815 * _0xbb9eb9()) / _0x0fa401;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0xbb9eb9() public view returns (uint256) {
        if (_0x4d642b == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0x62d34b = IVotingEscrow(_0xf973eb)._0x62d34b(_0x4d642b);
        return uint256(int256(_0x62d34b._0x1b3d67));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0xfd84d0(address _0xc4cb9f, uint256 _0x1b3d67) internal {
        uint256 _0x7d3e11 = block.timestamp + _0xbe2390;
        _0xd0ddf3[_0xc4cb9f].push(UserLock({
            _0x1b3d67: _0x1b3d67,
            _0x7d3e11: _0x7d3e11
        }));
        _0x92082b[_0xc4cb9f] += _0x1b3d67;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x770a2d(address _0xc4cb9f) external view returns (uint256 _0xc5a7af) {
        uint256 _0xcb489a = _0x6d6164(_0xc4cb9f);
        uint256 _0xd1ae56 = 0;

        UserLock[] storage _0xa5db0c = _0xd0ddf3[_0xc4cb9f];
        for (uint256 i = 0; i < _0xa5db0c.length; i++) {
            if (_0xa5db0c[i]._0x7d3e11 > block.timestamp) {
                _0xd1ae56 += _0xa5db0c[i]._0x1b3d67;
            }
        }

        return _0xcb489a > _0xd1ae56 ? _0xcb489a - _0xd1ae56 : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xfb6bf1(address _0xc4cb9f) internal returns (uint256 _0xfc8dcf) {
        UserLock[] storage _0xa5db0c = _0xd0ddf3[_0xc4cb9f];
        uint256 _0x9b2758 = _0xa5db0c.length;
        if (_0x9b2758 == 0) return 0;

        uint256 _0x95644e = 0;
        unchecked {
            for (uint256 i = 0; i < _0x9b2758; i++) {
                UserLock memory L = _0xa5db0c[i];
                if (L._0x7d3e11 <= block.timestamp) {
                    _0xfc8dcf += L._0x1b3d67;
                } else {
                    if (_0x95644e != i) _0xa5db0c[_0x95644e] = L;
                    _0x95644e++;
                }
            }
            if (_0xfc8dcf > 0) {
                _0x92082b[_0xc4cb9f] -= _0xfc8dcf;
            }
            while (_0xa5db0c.length > _0x95644e) {
                _0xa5db0c.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x40ac0f(
        address from,
        address _0x83f025,
        uint256 _0x1b3d67
    ) internal override {
        super._0x40ac0f(from, _0x83f025, _0x1b3d67);

        if (from != address(0) && _0x83f025 != address(0)) { // Not mint or burn
            uint256 _0xcb489a = _0x6d6164(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0x95163a = _0xcb489a > _0x92082b[from] ? _0xcb489a - _0x92082b[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0x95163a >= _0x1b3d67) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xfb6bf1(from);
            uint256 _0x5b0a51 = _0xcb489a > _0x92082b[from] ? _0xcb489a - _0x92082b[from] : 0;

            // Step 4: Check final available balance
            require(_0x5b0a51 >= _0x1b3d67, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0x97f764() external _0xedbc8f {
        require(_0x73b9b8 != address(0), "Voter not set");
        require(_0x32463b != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x5586ab = IRewardsDistributor(_0x32463b)._0x805b04(_0x4d642b);
        _0x955bbb += _0x5586ab;
        // Claim bribes from voted pools
        address[] memory _0xbf7432 = IVoter(_0x73b9b8)._0x3db4b1(_0x4d642b);

        for (uint256 i = 0; i < _0xbf7432.length; i++) {
            if (_0xbf7432[i] != address(0)) {
                address _0xd5c1ad = IGaugeManager(_0x29d856)._0x9c9478(_0xbf7432[i]);

                if (_0xd5c1ad != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0x44be78 = new address[](1);
                    address[][] memory _0xef073f = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0xd9adf9 = IGaugeManager(_0x29d856)._0x616fcc(_0xd5c1ad);
                    if (_0xd9adf9 != address(0)) {
                        uint256 _0x7f91e6 = IBribe(_0xd9adf9)._0x0a203b();
                        if (_0x7f91e6 > 0) {
                            address[] memory _0xdbf79c = new address[](_0x7f91e6);
                            for (uint256 j = 0; j < _0x7f91e6; j++) {
                                _0xdbf79c[j] = IBribe(_0xd9adf9)._0xdbf79c(j);
                            }
                            _0x44be78[0] = _0xd9adf9;
                            _0xef073f[0] = _0xdbf79c;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x29d856)._0x6373ef(_0x44be78, _0xef073f, _0x4d642b);
                        }
                    }

                    // Claim external bribe
                    address _0x0df5c2 = IGaugeManager(_0x29d856)._0x03af4a(_0xd5c1ad);
                    if (_0x0df5c2 != address(0)) {
                        uint256 _0x7f91e6 = IBribe(_0x0df5c2)._0x0a203b();
                        if (_0x7f91e6 > 0) {
                            address[] memory _0xdbf79c = new address[](_0x7f91e6);
                            for (uint256 j = 0; j < _0x7f91e6; j++) {
                                _0xdbf79c[j] = IBribe(_0x0df5c2)._0xdbf79c(j);
                            }
                            _0x44be78[0] = _0x0df5c2;
                            _0xef073f[0] = _0xdbf79c;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x29d856)._0x6373ef(_0x44be78, _0xef073f, _0x4d642b);
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
    function _0x963d77(ISwapper.SwapParams calldata _0x1929f2) external _0x78f0a4 _0xedbc8f {
        require(address(_0xf0fa28) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x49d652 = IERC20(_0x1929f2._0x79c517)._0x6d6164(address(this));
        require(_0x49d652 >= _0x1929f2._0x7aae48, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x1929f2._0x79c517)._0x94deb6(address(_0xf0fa28), _0x1929f2._0x7aae48);

        // Execute swap through swapper module
        uint256 _0xf16090 = _0xf0fa28._0x472ac2(_0x1929f2);

        // Reset approval for safety
        IERC20(_0x1929f2._0x79c517)._0x94deb6(address(_0xf0fa28), 0);

        // HYBR is now in this contract, ready for compounding
        _0x95c23e += _0xf16090;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0xba6d3e() external _0xedbc8f {

        // Get current HYBR balance
        uint256 _0xdeceba = IERC20(HYBR)._0x6d6164(address(this));

        if (_0xdeceba > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x94deb6(_0xf973eb, _0xdeceba);
            IVotingEscrow(_0xf973eb)._0x1841e0(_0x4d642b, _0xdeceba);

            // Extend lock to maximum duration
            _0x058960();

            _0x78b0f4 = block.timestamp;

            emit Compound(_0xdeceba, _0xbb9eb9());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0x6f0ee1(address[] calldata _0x57982b, uint256[] calldata _0x81fc74) external {
        require(msg.sender == _0x382e4b() || msg.sender == _0x47eaa7, "Not authorized");
        require(_0x73b9b8 != address(0), "Voter not set");

        IVoter(_0x73b9b8)._0x6f0ee1(_0x4d642b, _0x57982b, _0x81fc74);
        _0x8662a8 = HybraTimeLibrary._0xfc7860(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function _0xd6eb10() external {
        require(msg.sender == _0x382e4b() || msg.sender == _0x47eaa7, "Not authorized");
        require(_0x73b9b8 != address(0), "Voter not set");

        IVoter(_0x73b9b8)._0xd6eb10(_0x4d642b);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x9ab62c(uint256 _0x1b3d67) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x1b3d67 > 0) {
            IERC20(HYBR)._0x152e36(_0xf973eb, _0x1b3d67);

            if(_0x4d642b == 0){
                _0xb8d615(_0x1b3d67);
            } else{
                IVotingEscrow(_0xf973eb)._0x1841e0(_0x4d642b, _0x1b3d67);

                // Extend lock to maximum duration
                _0x058960();
            }
        }
        _0xbb663d += _0x1b3d67;
        emit PenaltyRewardReceived(_0x1b3d67);
    }

    /**
     * @notice Set the voter contract
     */
    function _0xf47c09(address _0x04e9a0) external _0xc34fba {
        require(_0x04e9a0 != address(0), "Invalid voter");
        _0x73b9b8 = _0x04e9a0;
        emit VoterSet(_0x04e9a0);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x058672(uint256 _0xffd02e) external _0xc34fba {
        require(_0xffd02e >= MIN_LOCK_PERIOD && _0xffd02e <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x30b604 = _0xbe2390;
        _0xbe2390 = _0xffd02e;
        emit TransferLockPeriodUpdated(_0x30b604, _0xffd02e);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x744d15(uint256 _0xe57000) external _0xc34fba {
        require(_0xe57000 >= MIN_WITHDRAW_FEE && _0xe57000 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x3d0f4f = _0xe57000;
    }

    function _0x8624e3(uint256 _0xebe4d9) external _0xc34fba {
        _0x0dc852 = _0xebe4d9;
    }

    function _0x4c331a(uint256 _0xebe4d9) external _0xc34fba {
        _0xf80792 = _0xebe4d9;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0xc6f493(address _0x122ae1) external _0xc34fba {
        require(_0x122ae1 != address(0), "Invalid swapper");
        address _0x0ef62e = address(_0xf0fa28);
        if (gasleft() > 0) { _0xf0fa28 = ISwapper(_0x122ae1); }
        emit SwapperUpdated(_0x0ef62e, _0x122ae1);
    }

    /**
     * @notice Set the team address
     */
    function _0x3a150e(address _0x192916) external _0xc34fba {
        require(_0x192916 != address(0), "Invalid team");
        if (block.timestamp > 0) { Team = _0x192916; }
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x0b82fe(address _0xc4cb9f) external _0xedbc8f {
        delete _0xd0ddf3[_0xc4cb9f];
        _0x92082b[_0xc4cb9f] = 0;
        emit EmergencyUnlock(_0xc4cb9f);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x03d5fc(address _0xc4cb9f) external view returns (UserLock[] memory) {
        return _0xd0ddf3[_0xc4cb9f];
    }

    /**
     * @notice Set operator address
     */
    function _0xbc3aaa(address _0x5439e1) external _0xc34fba {
        require(_0x5439e1 != address(0), "Invalid operator");
        address _0x2bbadb = _0x47eaa7;
        _0x47eaa7 = _0x5439e1;
        emit OperatorUpdated(_0x2bbadb, _0x5439e1);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0x19e091() external view returns (uint256) {
        if (_0x4d642b == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x62d34b = IVotingEscrow(_0xf973eb)._0x62d34b(_0x4d642b);
        return uint256(_0x62d34b._0x5e1b09);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0x058960() internal {
        if (_0x4d642b == 0) return;

        IVotingEscrow.LockedBalance memory _0x62d34b = IVotingEscrow(_0xf973eb)._0x62d34b(_0x4d642b);
        if (_0x62d34b._0x08e108 || _0x62d34b._0x5e1b09 <= block.timestamp) return;

        uint256 _0xcd8fde = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0xcd8fde > _0x62d34b._0x5e1b09 + 2 hours) {
            try IVotingEscrow(_0xf973eb)._0xb3913f(_0x4d642b, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}