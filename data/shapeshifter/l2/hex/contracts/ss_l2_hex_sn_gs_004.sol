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
    uint256 public _0x0c3872 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0xd0755f = 1200; // 5days
    uint256 public _0xf7ab47 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0xaa7e20 = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x9e65af;
    uint256 public _0x93f8b2;
    uint256 public _0x69cb47;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x9baf4b;
        uint256 _0x725b56;
    }

    mapping(address => UserLock[]) public _0x08a0ca;
    mapping(address => uint256) public _0x235290;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x3bcb90;
    address public _0xdd69ab;
    address public _0x28b7c4;
    address public _0x725e75;
    uint256 public _0x8a5ed6; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0xdfc883; // Address that can manage voting strategy
    uint256 public _0x48bb01; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x8a6372;
    uint256 public _0x36818e;

    // Swap module
    ISwapper public _0x2bd0d0;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0xcafb62, uint256 _0x7a96b1, uint256 _0x734877);
    event Withdraw(address indexed _0xcafb62, uint256 _0xef133c, uint256 _0x7a96b1, uint256 _0x46fbd9);
    event Compound(uint256 _0x8712a1, uint256 _0xbc27d0);
    event PenaltyRewardReceived(uint256 _0x9baf4b);
    event TransferLockPeriodUpdated(uint256 _0x0ff4cb, uint256 _0x3d143e);
    event SwapperUpdated(address indexed _0x2e93bb, address indexed _0xea3d25);
    event VoterSet(address _0xdd69ab);
    event EmergencyUnlock(address indexed _0xcafb62);
    event AutoVotingEnabled(bool _0x095807);
    event OperatorUpdated(address indexed _0x54b4d3, address indexed _0xe7d571);
    event DefaultVotingStrategyUpdated(address[] _0x7205b7, uint256[] _0x7cfc76);
    event AutoVoteExecuted(uint256 _0xd076b1, address[] _0x7205b7, uint256[] _0x7cfc76);

    constructor(
        address _0xa66795,
        address _0xf4405a
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xa66795 != address(0), "Invalid HYBR");
        require(_0xf4405a != address(0), "Invalid VE");

        HYBR = _0xa66795;
        _0x3bcb90 = _0xf4405a;
        _0x8a6372 = block.timestamp;
        _0x36818e = block.timestamp;
        _0xdfc883 = msg.sender; // Initially set deployer as operator
    }

    function _0xe1666b(address _0xfa0832) external _0xe5c9cf {
        require(_0xfa0832 != address(0), "Invalid rewards distributor");
        _0x28b7c4 = _0xfa0832;
    }

    function _0xfe73ff(address _0x1bc804) external _0xe5c9cf {
        require(_0x1bc804 != address(0), "Invalid gauge manager");
        _0x725e75 = _0x1bc804;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0xcfae1d() {
        if (msg.sender != _0xdfc883) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x96c149(uint256 _0x9baf4b, address _0xa693ca) external _0x211840 {
        require(_0x9baf4b > 0, "Zero amount");
        _0xa693ca = _0xa693ca == address(0) ? msg.sender : _0xa693ca;

        // Transfer HYBR from user first
        IERC20(HYBR)._0x9e289b(msg.sender, address(this), _0x9baf4b);

        // Initialize veNFT on first deposit
        if (_0x8a5ed6 == 0) {
            _0x24da8e(_0x9baf4b);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x1d1308(_0x3bcb90, _0x9baf4b);
            IVotingEscrow(_0x3bcb90)._0xad7b2a(_0x8a5ed6, _0x9baf4b);

            // Extend lock to maximum duration
            _0xe77992();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0xef133c = _0x914df6(_0x9baf4b);

        // Mint gHYBR shares
        _0xdbe3c1(_0xa693ca, _0xef133c);

        // Add transfer lock for recipient
        _0x56f3e0(_0xa693ca, _0xef133c);

        emit Deposit(msg.sender, _0x9baf4b, _0xef133c);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0x33be44(uint256 _0xef133c) external _0x211840 returns (uint256 _0x4439eb) {
        require(_0xef133c > 0, "Zero shares");
        require(_0x106404(msg.sender) >= _0xef133c, "Insufficient balance");
        require(_0x8a5ed6 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x3bcb90)._0x69367f(_0x8a5ed6) == false, "Cannot withdraw yet");

        uint256 _0x84dd04 = HybraTimeLibrary._0x84dd04(block.timestamp);
        uint256 _0x659a58 = HybraTimeLibrary._0x659a58(block.timestamp);

        require(block.timestamp >= _0x84dd04 + _0xd0755f && block.timestamp < _0x659a58 - _0xf7ab47, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x7a96b1 = _0xd53367(_0xef133c);
        require(_0x7a96b1 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0x784a98 = 0;
        if (_0xaa7e20 > 0) {
            _0x784a98 = (_0x7a96b1 * _0xaa7e20) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0xc14ec1 = _0x7a96b1 - _0x784a98;
        require(_0xc14ec1 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x0a2bf8 = _0x6e0c50();
        require(_0x7a96b1 <= _0x0a2bf8, "Insufficient veNFT balance");

        uint256 _0x08a33a = _0x0a2bf8 - _0xc14ec1 - _0x784a98;
        require(_0x08a33a >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0xc45561(msg.sender, _0xef133c);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0xcd3a64 = new uint256[](3);
        _0xcd3a64[0] = _0x08a33a; // Amount staying with gHYBR
        _0xcd3a64[1] = _0xc14ec1;      // Amount going to user (after fee)
        _0xcd3a64[2] = _0x784a98;      // Amount going to fee recipient

        uint256[] memory _0x9879a7 = IVotingEscrow(_0x3bcb90)._0xb5f39e(_0x8a5ed6, _0xcd3a64);

        // Update contract's veTokenId to the first new token
        _0x8a5ed6 = _0x9879a7[0];
        _0x4439eb = _0x9879a7[1];
        uint256 _0x1430e6 = _0x9879a7[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x3bcb90)._0x793e87(address(this), msg.sender, _0x4439eb);
        IVotingEscrow(_0x3bcb90)._0x793e87(address(this), Team, _0x1430e6);
        emit Withdraw(msg.sender, _0xef133c, _0xc14ec1, _0x784a98);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0x24da8e(uint256 _0xfcccfd) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x1d1308(_0x3bcb90, type(uint256)._0x7b84f1);
        uint256 _0xd895b3 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x8a5ed6 = IVotingEscrow(_0x3bcb90)._0x5fa35f(_0xfcccfd, _0xd895b3, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0x914df6(uint256 _0x9baf4b) public view returns (uint256) {
        uint256 _0x7a16d0 = _0xc95bc4();
        uint256 _0x1e75a7 = _0x6e0c50();
        if (_0x7a16d0 == 0 || _0x1e75a7 == 0) {
            return _0x9baf4b;
        }
        return (_0x9baf4b * _0x7a16d0) / _0x1e75a7;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0xd53367(uint256 _0xef133c) public view returns (uint256) {
        uint256 _0x7a16d0 = _0xc95bc4();
        if (_0x7a16d0 == 0) {
            return _0xef133c;
        }
        return (_0xef133c * _0x6e0c50()) / _0x7a16d0;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x6e0c50() public view returns (uint256) {
        if (_0x8a5ed6 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0x115897 = IVotingEscrow(_0x3bcb90)._0x115897(_0x8a5ed6);
        return uint256(int256(_0x115897._0x9baf4b));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0x56f3e0(address _0xcafb62, uint256 _0x9baf4b) internal {
        uint256 _0x725b56 = block.timestamp + _0x0c3872;
        _0x08a0ca[_0xcafb62].push(UserLock({
            _0x9baf4b: _0x9baf4b,
            _0x725b56: _0x725b56
        }));
        _0x235290[_0xcafb62] += _0x9baf4b;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x6b886d(address _0xcafb62) external view returns (uint256 _0x9a852b) {
        uint256 _0xf15e16 = _0x106404(_0xcafb62);
        uint256 _0x5d46e4 = 0;

        UserLock[] storage _0x2f0bfd = _0x08a0ca[_0xcafb62];
        for (uint256 i = 0; i < _0x2f0bfd.length; i++) {
            if (_0x2f0bfd[i]._0x725b56 > block.timestamp) {
                _0x5d46e4 += _0x2f0bfd[i]._0x9baf4b;
            }
        }

        return _0xf15e16 > _0x5d46e4 ? _0xf15e16 - _0x5d46e4 : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xadd49f(address _0xcafb62) internal returns (uint256 _0x9d5770) {
        UserLock[] storage _0x2f0bfd = _0x08a0ca[_0xcafb62];
        uint256 _0xf52325 = _0x2f0bfd.length;
        if (_0xf52325 == 0) return 0;

        uint256 _0xb5ceb7 = 0;
        unchecked {
            for (uint256 i = 0; i < _0xf52325; i++) {
                UserLock memory L = _0x2f0bfd[i];
                if (L._0x725b56 <= block.timestamp) {
                    _0x9d5770 += L._0x9baf4b;
                } else {
                    if (_0xb5ceb7 != i) _0x2f0bfd[_0xb5ceb7] = L;
                    _0xb5ceb7++;
                }
            }
            if (_0x9d5770 > 0) {
                _0x235290[_0xcafb62] -= _0x9d5770;
            }
            while (_0x2f0bfd.length > _0xb5ceb7) {
                _0x2f0bfd.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x3fd035(
        address from,
        address _0xe4ff96,
        uint256 _0x9baf4b
    ) internal override {
        super._0x3fd035(from, _0xe4ff96, _0x9baf4b);

        if (from != address(0) && _0xe4ff96 != address(0)) { // Not mint or burn
            uint256 _0xf15e16 = _0x106404(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0xc6bd7f = _0xf15e16 > _0x235290[from] ? _0xf15e16 - _0x235290[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0xc6bd7f >= _0x9baf4b) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xadd49f(from);
            uint256 _0xb66e08 = _0xf15e16 > _0x235290[from] ? _0xf15e16 - _0x235290[from] : 0;

            // Step 4: Check final available balance
            require(_0xb66e08 >= _0x9baf4b, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0x20c0f3() external _0xcfae1d {
        require(_0xdd69ab != address(0), "Voter not set");
        require(_0x28b7c4 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x25cae8 = IRewardsDistributor(_0x28b7c4)._0xfb2f52(_0x8a5ed6);
        _0x9e65af += _0x25cae8;
        // Claim bribes from voted pools
        address[] memory _0x553b0e = IVoter(_0xdd69ab)._0xb8bff6(_0x8a5ed6);

        for (uint256 i = 0; i < _0x553b0e.length; i++) {
            if (_0x553b0e[i] != address(0)) {
                address _0x36a928 = IGaugeManager(_0x725e75)._0x544f34(_0x553b0e[i]);

                if (_0x36a928 != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0x295f32 = new address[](1);
                    address[][] memory _0xf557b4 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0xd73691 = IGaugeManager(_0x725e75)._0xd71cf4(_0x36a928);
                    if (_0xd73691 != address(0)) {
                        uint256 _0x90d7ec = IBribe(_0xd73691)._0xb0081a();
                        if (_0x90d7ec > 0) {
                            address[] memory _0x3c5bc9 = new address[](_0x90d7ec);
                            for (uint256 j = 0; j < _0x90d7ec; j++) {
                                _0x3c5bc9[j] = IBribe(_0xd73691)._0x3c5bc9(j);
                            }
                            _0x295f32[0] = _0xd73691;
                            _0xf557b4[0] = _0x3c5bc9;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x725e75)._0xb1c42e(_0x295f32, _0xf557b4, _0x8a5ed6);
                        }
                    }

                    // Claim external bribe
                    address _0x8447bc = IGaugeManager(_0x725e75)._0x270259(_0x36a928);
                    if (_0x8447bc != address(0)) {
                        uint256 _0x90d7ec = IBribe(_0x8447bc)._0xb0081a();
                        if (_0x90d7ec > 0) {
                            address[] memory _0x3c5bc9 = new address[](_0x90d7ec);
                            for (uint256 j = 0; j < _0x90d7ec; j++) {
                                _0x3c5bc9[j] = IBribe(_0x8447bc)._0x3c5bc9(j);
                            }
                            _0x295f32[0] = _0x8447bc;
                            _0xf557b4[0] = _0x3c5bc9;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x725e75)._0xb1c42e(_0x295f32, _0xf557b4, _0x8a5ed6);
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
    function _0x982899(ISwapper.SwapParams calldata _0x6d9efd) external _0x211840 _0xcfae1d {
        require(address(_0x2bd0d0) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0xe47e4b = IERC20(_0x6d9efd._0x42f895)._0x106404(address(this));
        require(_0xe47e4b >= _0x6d9efd._0xdad209, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x6d9efd._0x42f895)._0x9fbab6(address(_0x2bd0d0), _0x6d9efd._0xdad209);

        // Execute swap through swapper module
        uint256 _0xe2a7c2 = _0x2bd0d0._0x870a71(_0x6d9efd);

        // Reset approval for safety
        IERC20(_0x6d9efd._0x42f895)._0x9fbab6(address(_0x2bd0d0), 0);

        // HYBR is now in this contract, ready for compounding
        _0x69cb47 += _0xe2a7c2;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0x6f3e4d() external _0xcfae1d {

        // Get current HYBR balance
        uint256 _0x05a981 = IERC20(HYBR)._0x106404(address(this));

        if (_0x05a981 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x9fbab6(_0x3bcb90, _0x05a981);
            IVotingEscrow(_0x3bcb90)._0xad7b2a(_0x8a5ed6, _0x05a981);

            // Extend lock to maximum duration
            _0xe77992();

            _0x36818e = block.timestamp;

            emit Compound(_0x05a981, _0x6e0c50());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0xa17d6d(address[] calldata _0x3e3ea2, uint256[] calldata _0xda4806) external {
        require(msg.sender == _0x10e85a() || msg.sender == _0xdfc883, "Not authorized");
        require(_0xdd69ab != address(0), "Voter not set");

        IVoter(_0xdd69ab)._0xa17d6d(_0x8a5ed6, _0x3e3ea2, _0xda4806);
        _0x48bb01 = HybraTimeLibrary._0x84dd04(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function _0x16199a() external {
        require(msg.sender == _0x10e85a() || msg.sender == _0xdfc883, "Not authorized");
        require(_0xdd69ab != address(0), "Voter not set");

        IVoter(_0xdd69ab)._0x16199a(_0x8a5ed6);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x89b5cd(uint256 _0x9baf4b) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x9baf4b > 0) {
            IERC20(HYBR)._0x1d1308(_0x3bcb90, _0x9baf4b);

            if(_0x8a5ed6 == 0){
                _0x24da8e(_0x9baf4b);
            } else{
                IVotingEscrow(_0x3bcb90)._0xad7b2a(_0x8a5ed6, _0x9baf4b);

                // Extend lock to maximum duration
                _0xe77992();
            }
        }
        _0x93f8b2 += _0x9baf4b;
        emit PenaltyRewardReceived(_0x9baf4b);
    }

    /**
     * @notice Set the voter contract
     */
    function _0x97f6c2(address _0x80ec03) external _0xe5c9cf {
        require(_0x80ec03 != address(0), "Invalid voter");
        _0xdd69ab = _0x80ec03;
        emit VoterSet(_0x80ec03);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x8c22b6(uint256 _0x6fa78b) external _0xe5c9cf {
        require(_0x6fa78b >= MIN_LOCK_PERIOD && _0x6fa78b <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x0ff4cb = _0x0c3872;
        _0x0c3872 = _0x6fa78b;
        emit TransferLockPeriodUpdated(_0x0ff4cb, _0x6fa78b);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x020e9c(uint256 _0xe5f8d5) external _0xe5c9cf {
        require(_0xe5f8d5 >= MIN_WITHDRAW_FEE && _0xe5f8d5 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0xaa7e20 = _0xe5f8d5;
    }

    function _0x709e52(uint256 _0xe4cd32) external _0xe5c9cf {
        _0xd0755f = _0xe4cd32;
    }

    function _0x9a9607(uint256 _0xe4cd32) external _0xe5c9cf {
        _0xf7ab47 = _0xe4cd32;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x11cabe(address _0x90f7d9) external _0xe5c9cf {
        require(_0x90f7d9 != address(0), "Invalid swapper");
        address _0x2e93bb = address(_0x2bd0d0);
        _0x2bd0d0 = ISwapper(_0x90f7d9);
        emit SwapperUpdated(_0x2e93bb, _0x90f7d9);
    }

    /**
     * @notice Set the team address
     */
    function _0x6cbd89(address _0x50f3d0) external _0xe5c9cf {
        require(_0x50f3d0 != address(0), "Invalid team");
        Team = _0x50f3d0;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x49e6e6(address _0xcafb62) external _0xcfae1d {
        delete _0x08a0ca[_0xcafb62];
        _0x235290[_0xcafb62] = 0;
        emit EmergencyUnlock(_0xcafb62);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x4265c4(address _0xcafb62) external view returns (UserLock[] memory) {
        return _0x08a0ca[_0xcafb62];
    }

    /**
     * @notice Set operator address
     */
    function _0x5e59b9(address _0xba69eb) external _0xe5c9cf {
        require(_0xba69eb != address(0), "Invalid operator");
        address _0x54b4d3 = _0xdfc883;
        _0xdfc883 = _0xba69eb;
        emit OperatorUpdated(_0x54b4d3, _0xba69eb);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0x42384e() external view returns (uint256) {
        if (_0x8a5ed6 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x115897 = IVotingEscrow(_0x3bcb90)._0x115897(_0x8a5ed6);
        return uint256(_0x115897._0x82bb3b);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0xe77992() internal {
        if (_0x8a5ed6 == 0) return;

        IVotingEscrow.LockedBalance memory _0x115897 = IVotingEscrow(_0x3bcb90)._0x115897(_0x8a5ed6);
        if (_0x115897._0x7be9f7 || _0x115897._0x82bb3b <= block.timestamp) return;

        uint256 _0x4e3a37 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0x4e3a37 > _0x115897._0x82bb3b + 2 hours) {
            try IVotingEscrow(_0x3bcb90)._0x935206(_0x8a5ed6, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}