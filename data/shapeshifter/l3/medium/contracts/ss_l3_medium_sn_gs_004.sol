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
    uint256 public _0xfd37c6 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0xa735a6 = 1200; // 5days
    uint256 public _0x337477 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0x37b482 = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x5ff5a1;
    uint256 public _0x39dc15;
    uint256 public _0xfbee50;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x00524f;
        uint256 _0x8e028f;
    }

    mapping(address => UserLock[]) public _0xddab6d;
    mapping(address => uint256) public _0x17ad5a;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0xa19a98;
    address public _0xad5dc3;
    address public _0x0f9cca;
    address public _0xeb40b1;
    uint256 public _0x14f424; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0x0f751b; // Address that can manage voting strategy
    uint256 public _0xac4718; // Last epoch when we voted

    // Reward tracking
    uint256 public _0xb2d2b3;
    uint256 public _0xda0b42;

    // Swap module
    ISwapper public _0x22e07d;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0xb67c23, uint256 _0x5fe0ab, uint256 _0xa0c15f);
    event Withdraw(address indexed _0xb67c23, uint256 _0x05758e, uint256 _0x5fe0ab, uint256 _0x6368f2);
    event Compound(uint256 _0x1e5f4f, uint256 _0x67e1bb);
    event PenaltyRewardReceived(uint256 _0x00524f);
    event TransferLockPeriodUpdated(uint256 _0x5dbf4e, uint256 _0xf4f599);
    event SwapperUpdated(address indexed _0xbfab54, address indexed _0x2c38b9);
    event VoterSet(address _0xad5dc3);
    event EmergencyUnlock(address indexed _0xb67c23);
    event AutoVotingEnabled(bool _0x2bd059);
    event OperatorUpdated(address indexed _0x3f7f8c, address indexed _0x254785);
    event DefaultVotingStrategyUpdated(address[] _0x7e3808, uint256[] _0x22a754);
    event AutoVoteExecuted(uint256 _0xa27f2f, address[] _0x7e3808, uint256[] _0x22a754);

    constructor(
        address _0xcb5f95,
        address _0xed5f76
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xcb5f95 != address(0), "Invalid HYBR");
        require(_0xed5f76 != address(0), "Invalid VE");

        HYBR = _0xcb5f95;
        _0xa19a98 = _0xed5f76;
        _0xb2d2b3 = block.timestamp;
        _0xda0b42 = block.timestamp;
        _0x0f751b = msg.sender; // Initially set deployer as operator
    }

    function _0xeb290e(address _0x7af843) external _0x13085c {
        require(_0x7af843 != address(0), "Invalid rewards distributor");
        if (1 == 1) { _0x0f9cca = _0x7af843; }
    }

    function _0x9ad765(address _0xdc0939) external _0x13085c {
        require(_0xdc0939 != address(0), "Invalid gauge manager");
        _0xeb40b1 = _0xdc0939;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0xe90de7() {
        if (msg.sender != _0x0f751b) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x4e512c(uint256 _0x00524f, address _0xa36533) external _0x46ce13 {
        require(_0x00524f > 0, "Zero amount");
        _0xa36533 = _0xa36533 == address(0) ? msg.sender : _0xa36533;

        // Transfer HYBR from user first
        IERC20(HYBR)._0xea4289(msg.sender, address(this), _0x00524f);

        // Initialize veNFT on first deposit
        if (_0x14f424 == 0) {
            _0xc8129f(_0x00524f);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x70423f(_0xa19a98, _0x00524f);
            IVotingEscrow(_0xa19a98)._0xa4cd82(_0x14f424, _0x00524f);

            // Extend lock to maximum duration
            _0xea6382();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0x05758e = _0x43ea14(_0x00524f);

        // Mint gHYBR shares
        _0xa9e8aa(_0xa36533, _0x05758e);

        // Add transfer lock for recipient
        _0x075441(_0xa36533, _0x05758e);

        emit Deposit(msg.sender, _0x00524f, _0x05758e);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0x3ebe83(uint256 _0x05758e) external _0x46ce13 returns (uint256 _0xdeff95) {
        require(_0x05758e > 0, "Zero shares");
        require(_0xeab9e3(msg.sender) >= _0x05758e, "Insufficient balance");
        require(_0x14f424 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0xa19a98)._0x588068(_0x14f424) == false, "Cannot withdraw yet");

        uint256 _0x8abb9d = HybraTimeLibrary._0x8abb9d(block.timestamp);
        uint256 _0xe0968b = HybraTimeLibrary._0xe0968b(block.timestamp);

        require(block.timestamp >= _0x8abb9d + _0xa735a6 && block.timestamp < _0xe0968b - _0x337477, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x5fe0ab = _0x4c6272(_0x05758e);
        require(_0x5fe0ab > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0x983560 = 0;
        if (_0x37b482 > 0) {
            _0x983560 = (_0x5fe0ab * _0x37b482) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0xdb2d76 = _0x5fe0ab - _0x983560;
        require(_0xdb2d76 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x416975 = _0x8f5c0d();
        require(_0x5fe0ab <= _0x416975, "Insufficient veNFT balance");

        uint256 _0xfb0168 = _0x416975 - _0xdb2d76 - _0x983560;
        require(_0xfb0168 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x2a6945(msg.sender, _0x05758e);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0x359bba = new uint256[](3);
        _0x359bba[0] = _0xfb0168; // Amount staying with gHYBR
        _0x359bba[1] = _0xdb2d76;      // Amount going to user (after fee)
        _0x359bba[2] = _0x983560;      // Amount going to fee recipient

        uint256[] memory _0x2235c9 = IVotingEscrow(_0xa19a98)._0x46f745(_0x14f424, _0x359bba);

        // Update contract's veTokenId to the first new token
        _0x14f424 = _0x2235c9[0];
        _0xdeff95 = _0x2235c9[1];
        uint256 _0x601d7c = _0x2235c9[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0xa19a98)._0x7abc5e(address(this), msg.sender, _0xdeff95);
        IVotingEscrow(_0xa19a98)._0x7abc5e(address(this), Team, _0x601d7c);
        emit Withdraw(msg.sender, _0x05758e, _0xdb2d76, _0x983560);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0xc8129f(uint256 _0x00c4de) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x70423f(_0xa19a98, type(uint256)._0x3dc52c);
        uint256 _0x7713e6 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x14f424 = IVotingEscrow(_0xa19a98)._0xc60e99(_0x00c4de, _0x7713e6, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0x43ea14(uint256 _0x00524f) public view returns (uint256) {
        uint256 _0xf9d920 = _0xd73546();
        uint256 _0x520207 = _0x8f5c0d();
        if (_0xf9d920 == 0 || _0x520207 == 0) {
            return _0x00524f;
        }
        return (_0x00524f * _0xf9d920) / _0x520207;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x4c6272(uint256 _0x05758e) public view returns (uint256) {
        uint256 _0xf9d920 = _0xd73546();
        if (_0xf9d920 == 0) {
            return _0x05758e;
        }
        return (_0x05758e * _0x8f5c0d()) / _0xf9d920;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x8f5c0d() public view returns (uint256) {
        if (_0x14f424 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0xb463b9 = IVotingEscrow(_0xa19a98)._0xb463b9(_0x14f424);
        return uint256(int256(_0xb463b9._0x00524f));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0x075441(address _0xb67c23, uint256 _0x00524f) internal {
        uint256 _0x8e028f = block.timestamp + _0xfd37c6;
        _0xddab6d[_0xb67c23].push(UserLock({
            _0x00524f: _0x00524f,
            _0x8e028f: _0x8e028f
        }));
        _0x17ad5a[_0xb67c23] += _0x00524f;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x30b8d2(address _0xb67c23) external view returns (uint256 _0x39fc6e) {
        uint256 _0xacb7f5 = _0xeab9e3(_0xb67c23);
        uint256 _0xf9e1bd = 0;

        UserLock[] storage _0x7a5069 = _0xddab6d[_0xb67c23];
        for (uint256 i = 0; i < _0x7a5069.length; i++) {
            if (_0x7a5069[i]._0x8e028f > block.timestamp) {
                _0xf9e1bd += _0x7a5069[i]._0x00524f;
            }
        }

        return _0xacb7f5 > _0xf9e1bd ? _0xacb7f5 - _0xf9e1bd : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xb00368(address _0xb67c23) internal returns (uint256 _0x74ccd5) {
        UserLock[] storage _0x7a5069 = _0xddab6d[_0xb67c23];
        uint256 _0x71069b = _0x7a5069.length;
        if (_0x71069b == 0) return 0;

        uint256 _0xcc8b70 = 0;
        unchecked {
            for (uint256 i = 0; i < _0x71069b; i++) {
                UserLock memory L = _0x7a5069[i];
                if (L._0x8e028f <= block.timestamp) {
                    _0x74ccd5 += L._0x00524f;
                } else {
                    if (_0xcc8b70 != i) _0x7a5069[_0xcc8b70] = L;
                    _0xcc8b70++;
                }
            }
            if (_0x74ccd5 > 0) {
                _0x17ad5a[_0xb67c23] -= _0x74ccd5;
            }
            while (_0x7a5069.length > _0xcc8b70) {
                _0x7a5069.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x088a0e(
        address from,
        address _0x016c21,
        uint256 _0x00524f
    ) internal override {
        super._0x088a0e(from, _0x016c21, _0x00524f);

        if (from != address(0) && _0x016c21 != address(0)) { // Not mint or burn
            uint256 _0xacb7f5 = _0xeab9e3(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0xf7bef9 = _0xacb7f5 > _0x17ad5a[from] ? _0xacb7f5 - _0x17ad5a[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0xf7bef9 >= _0x00524f) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xb00368(from);
            uint256 _0xf6edaa = _0xacb7f5 > _0x17ad5a[from] ? _0xacb7f5 - _0x17ad5a[from] : 0;

            // Step 4: Check final available balance
            require(_0xf6edaa >= _0x00524f, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0xe1ed2a() external _0xe90de7 {
        require(_0xad5dc3 != address(0), "Voter not set");
        require(_0x0f9cca != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x76fdca = IRewardsDistributor(_0x0f9cca)._0x763b0c(_0x14f424);
        _0x5ff5a1 += _0x76fdca;
        // Claim bribes from voted pools
        address[] memory _0xc43de0 = IVoter(_0xad5dc3)._0xec1b80(_0x14f424);

        for (uint256 i = 0; i < _0xc43de0.length; i++) {
            if (_0xc43de0[i] != address(0)) {
                address _0x93079f = IGaugeManager(_0xeb40b1)._0x9201df(_0xc43de0[i]);

                if (_0x93079f != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0x27a43d = new address[](1);
                    address[][] memory _0x7361b9 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0xb14032 = IGaugeManager(_0xeb40b1)._0x1b0944(_0x93079f);
                    if (_0xb14032 != address(0)) {
                        uint256 _0xde7502 = IBribe(_0xb14032)._0x97a056();
                        if (_0xde7502 > 0) {
                            address[] memory _0xe915f9 = new address[](_0xde7502);
                            for (uint256 j = 0; j < _0xde7502; j++) {
                                _0xe915f9[j] = IBribe(_0xb14032)._0xe915f9(j);
                            }
                            _0x27a43d[0] = _0xb14032;
                            _0x7361b9[0] = _0xe915f9;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0xeb40b1)._0x45fce0(_0x27a43d, _0x7361b9, _0x14f424);
                        }
                    }

                    // Claim external bribe
                    address _0xd603c5 = IGaugeManager(_0xeb40b1)._0xdc06b3(_0x93079f);
                    if (_0xd603c5 != address(0)) {
                        uint256 _0xde7502 = IBribe(_0xd603c5)._0x97a056();
                        if (_0xde7502 > 0) {
                            address[] memory _0xe915f9 = new address[](_0xde7502);
                            for (uint256 j = 0; j < _0xde7502; j++) {
                                _0xe915f9[j] = IBribe(_0xd603c5)._0xe915f9(j);
                            }
                            _0x27a43d[0] = _0xd603c5;
                            _0x7361b9[0] = _0xe915f9;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0xeb40b1)._0x45fce0(_0x27a43d, _0x7361b9, _0x14f424);
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
    function _0x9fe54c(ISwapper.SwapParams calldata _0x4549e9) external _0x46ce13 _0xe90de7 {
        require(address(_0x22e07d) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0xf27774 = IERC20(_0x4549e9._0xf77751)._0xeab9e3(address(this));
        require(_0xf27774 >= _0x4549e9._0x473a2f, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x4549e9._0xf77751)._0x783294(address(_0x22e07d), _0x4549e9._0x473a2f);

        // Execute swap through swapper module
        uint256 _0xcc7487 = _0x22e07d._0xd064e4(_0x4549e9);

        // Reset approval for safety
        IERC20(_0x4549e9._0xf77751)._0x783294(address(_0x22e07d), 0);

        // HYBR is now in this contract, ready for compounding
        _0xfbee50 += _0xcc7487;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0x6ebd9f() external _0xe90de7 {

        // Get current HYBR balance
        uint256 _0x609c77 = IERC20(HYBR)._0xeab9e3(address(this));

        if (_0x609c77 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x783294(_0xa19a98, _0x609c77);
            IVotingEscrow(_0xa19a98)._0xa4cd82(_0x14f424, _0x609c77);

            // Extend lock to maximum duration
            _0xea6382();

            _0xda0b42 = block.timestamp;

            emit Compound(_0x609c77, _0x8f5c0d());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0xfef4c7(address[] calldata _0x7e8a27, uint256[] calldata _0xe5efb5) external {
        require(msg.sender == _0xa0e476() || msg.sender == _0x0f751b, "Not authorized");
        require(_0xad5dc3 != address(0), "Voter not set");

        IVoter(_0xad5dc3)._0xfef4c7(_0x14f424, _0x7e8a27, _0xe5efb5);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xac4718 = HybraTimeLibrary._0x8abb9d(block.timestamp); }

    }

    /**
     * @notice Reset votes
     */
    function _0x5a946d() external {
        require(msg.sender == _0xa0e476() || msg.sender == _0x0f751b, "Not authorized");
        require(_0xad5dc3 != address(0), "Voter not set");

        IVoter(_0xad5dc3)._0x5a946d(_0x14f424);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x667c62(uint256 _0x00524f) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x00524f > 0) {
            IERC20(HYBR)._0x70423f(_0xa19a98, _0x00524f);

            if(_0x14f424 == 0){
                _0xc8129f(_0x00524f);
            } else{
                IVotingEscrow(_0xa19a98)._0xa4cd82(_0x14f424, _0x00524f);

                // Extend lock to maximum duration
                _0xea6382();
            }
        }
        _0x39dc15 += _0x00524f;
        emit PenaltyRewardReceived(_0x00524f);
    }

    /**
     * @notice Set the voter contract
     */
    function _0xc31fe3(address _0x3705db) external _0x13085c {
        require(_0x3705db != address(0), "Invalid voter");
        _0xad5dc3 = _0x3705db;
        emit VoterSet(_0x3705db);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x17e382(uint256 _0xa93924) external _0x13085c {
        require(_0xa93924 >= MIN_LOCK_PERIOD && _0xa93924 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x5dbf4e = _0xfd37c6;
        _0xfd37c6 = _0xa93924;
        emit TransferLockPeriodUpdated(_0x5dbf4e, _0xa93924);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x436483(uint256 _0x585381) external _0x13085c {
        require(_0x585381 >= MIN_WITHDRAW_FEE && _0x585381 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x37b482 = _0x585381;
    }

    function _0xbb6c9b(uint256 _0xcbf49a) external _0x13085c {
        _0xa735a6 = _0xcbf49a;
    }

    function _0xfc3809(uint256 _0xcbf49a) external _0x13085c {
        _0x337477 = _0xcbf49a;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x62c251(address _0x3ad31c) external _0x13085c {
        require(_0x3ad31c != address(0), "Invalid swapper");
        address _0xbfab54 = address(_0x22e07d);
        _0x22e07d = ISwapper(_0x3ad31c);
        emit SwapperUpdated(_0xbfab54, _0x3ad31c);
    }

    /**
     * @notice Set the team address
     */
    function _0x483522(address _0x5f4112) external _0x13085c {
        require(_0x5f4112 != address(0), "Invalid team");
        Team = _0x5f4112;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0xcd5621(address _0xb67c23) external _0xe90de7 {
        delete _0xddab6d[_0xb67c23];
        _0x17ad5a[_0xb67c23] = 0;
        emit EmergencyUnlock(_0xb67c23);
    }

    /**
     * @notice Get user's locks info
     */
    function _0xbd8f05(address _0xb67c23) external view returns (UserLock[] memory) {
        return _0xddab6d[_0xb67c23];
    }

    /**
     * @notice Set operator address
     */
    function _0x5593fd(address _0x2c3dd8) external _0x13085c {
        require(_0x2c3dd8 != address(0), "Invalid operator");
        address _0x3f7f8c = _0x0f751b;
        _0x0f751b = _0x2c3dd8;
        emit OperatorUpdated(_0x3f7f8c, _0x2c3dd8);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0x1bd197() external view returns (uint256) {
        if (_0x14f424 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0xb463b9 = IVotingEscrow(_0xa19a98)._0xb463b9(_0x14f424);
        return uint256(_0xb463b9._0x59a952);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0xea6382() internal {
        if (_0x14f424 == 0) return;

        IVotingEscrow.LockedBalance memory _0xb463b9 = IVotingEscrow(_0xa19a98)._0xb463b9(_0x14f424);
        if (_0xb463b9._0xd50e01 || _0xb463b9._0x59a952 <= block.timestamp) return;

        uint256 _0x284b8e = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0x284b8e > _0xb463b9._0x59a952 + 2 hours) {
            try IVotingEscrow(_0xa19a98)._0xcc0c7f(_0x14f424, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}