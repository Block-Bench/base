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
    uint256 public _0xa5760b = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x7b1285 = 1200; // 5days
    uint256 public _0xeb5b99 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0x7c4d71 = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x21f622;
    uint256 public _0x3a5dd1;
    uint256 public _0x790f45;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x2aac73;
        uint256 _0xc0d332;
    }

    mapping(address => UserLock[]) public _0x9e4791;
    mapping(address => uint256) public _0x417eeb;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x38d618;
    address public _0x7463c1;
    address public _0x5b5eb0;
    address public _0x0d9c85;
    uint256 public _0x40e05b; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0xb12fd0; // Address that can manage voting strategy
    uint256 public _0x612001; // Last epoch when we voted

    // Reward tracking
    uint256 public _0xcd0763;
    uint256 public _0x81fdca;

    // Swap module
    ISwapper public _0x012212;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0xaab307, uint256 _0x0fbfc9, uint256 _0x612a4d);
    event Withdraw(address indexed _0xaab307, uint256 _0x5f9576, uint256 _0x0fbfc9, uint256 _0xe09d75);
    event Compound(uint256 _0x0d96ab, uint256 _0x0e3563);
    event PenaltyRewardReceived(uint256 _0x2aac73);
    event TransferLockPeriodUpdated(uint256 _0xe6530c, uint256 _0x38e398);
    event SwapperUpdated(address indexed _0x2a0b0b, address indexed _0x558b6b);
    event VoterSet(address _0x7463c1);
    event EmergencyUnlock(address indexed _0xaab307);
    event AutoVotingEnabled(bool _0x33f5a1);
    event OperatorUpdated(address indexed _0x034675, address indexed _0x7c1541);
    event DefaultVotingStrategyUpdated(address[] _0x528e0b, uint256[] _0xc56a97);
    event AutoVoteExecuted(uint256 _0x89e8f3, address[] _0x528e0b, uint256[] _0xc56a97);

    constructor(
        address _0x6788c9,
        address _0x076938
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0x6788c9 != address(0), "Invalid HYBR");
        require(_0x076938 != address(0), "Invalid VE");

        HYBR = _0x6788c9;
        _0x38d618 = _0x076938;
        _0xcd0763 = block.timestamp;
        _0x81fdca = block.timestamp;
        _0xb12fd0 = msg.sender; // Initially set deployer as operator
    }

    function _0x64dbb8(address _0x424908) external _0x9155b6 {
        if (false) { revert(); }
        uint256 _unused2 = 0;
        require(_0x424908 != address(0), "Invalid rewards distributor");
        _0x5b5eb0 = _0x424908;
    }

    function _0x1f51d5(address _0xb23916) external _0x9155b6 {
        if (false) { revert(); }
        if (false) { revert(); }
        require(_0xb23916 != address(0), "Invalid gauge manager");
        _0x0d9c85 = _0xb23916;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0x9d31b5() {
        if (msg.sender != _0xb12fd0) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x9edb97(uint256 _0x2aac73, address _0x6f2965) external _0x1b2a23 {
        require(_0x2aac73 > 0, "Zero amount");
        _0x6f2965 = _0x6f2965 == address(0) ? msg.sender : _0x6f2965;

        // Transfer HYBR from user first
        IERC20(HYBR)._0xfb54a8(msg.sender, address(this), _0x2aac73);

        // Initialize veNFT on first deposit
        if (_0x40e05b == 0) {
            _0x8029d8(_0x2aac73);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x823e89(_0x38d618, _0x2aac73);
            IVotingEscrow(_0x38d618)._0x43936e(_0x40e05b, _0x2aac73);

            // Extend lock to maximum duration
            _0x1180be();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0x5f9576 = _0x8d53b7(_0x2aac73);

        // Mint gHYBR shares
        _0x8abc32(_0x6f2965, _0x5f9576);

        // Add transfer lock for recipient
        _0xf9bcbd(_0x6f2965, _0x5f9576);

        emit Deposit(msg.sender, _0x2aac73, _0x5f9576);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0xef46ef(uint256 _0x5f9576) external _0x1b2a23 returns (uint256 _0xe3276a) {
        require(_0x5f9576 > 0, "Zero shares");
        require(_0xa264cc(msg.sender) >= _0x5f9576, "Insufficient balance");
        require(_0x40e05b != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x38d618)._0x1f4395(_0x40e05b) == false, "Cannot withdraw yet");

        uint256 _0x09429a = HybraTimeLibrary._0x09429a(block.timestamp);
        uint256 _0xfde44d = HybraTimeLibrary._0xfde44d(block.timestamp);

        require(block.timestamp >= _0x09429a + _0x7b1285 && block.timestamp < _0xfde44d - _0xeb5b99, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x0fbfc9 = _0xf98f04(_0x5f9576);
        require(_0x0fbfc9 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0x15b3f6 = 0;
        if (_0x7c4d71 > 0) {
            _0x15b3f6 = (_0x0fbfc9 * _0x7c4d71) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0xc56f9d = _0x0fbfc9 - _0x15b3f6;
        require(_0xc56f9d > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x6e705e = _0x66e7d5();
        require(_0x0fbfc9 <= _0x6e705e, "Insufficient veNFT balance");

        uint256 _0xb4512f = _0x6e705e - _0xc56f9d - _0x15b3f6;
        require(_0xb4512f >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x391834(msg.sender, _0x5f9576);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0xa6e24a = new uint256[](3);
        _0xa6e24a[0] = _0xb4512f; // Amount staying with gHYBR
        _0xa6e24a[1] = _0xc56f9d;      // Amount going to user (after fee)
        _0xa6e24a[2] = _0x15b3f6;      // Amount going to fee recipient

        uint256[] memory _0xf229c5 = IVotingEscrow(_0x38d618)._0xa93755(_0x40e05b, _0xa6e24a);

        // Update contract's veTokenId to the first new token
        _0x40e05b = _0xf229c5[0];
        if (block.timestamp > 0) { _0xe3276a = _0xf229c5[1]; }
        uint256 _0x6ac8c2 = _0xf229c5[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x38d618)._0x4c8d99(address(this), msg.sender, _0xe3276a);
        IVotingEscrow(_0x38d618)._0x4c8d99(address(this), Team, _0x6ac8c2);
        emit Withdraw(msg.sender, _0x5f9576, _0xc56f9d, _0x15b3f6);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0x8029d8(uint256 _0x62d814) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x823e89(_0x38d618, type(uint256)._0xfb08cf);
        uint256 _0x9eadb7 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x40e05b = IVotingEscrow(_0x38d618)._0xfb395f(_0x62d814, _0x9eadb7, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0x8d53b7(uint256 _0x2aac73) public view returns (uint256) {
        uint256 _0x975e7c = _0xaad6fc();
        uint256 _0xc1aa42 = _0x66e7d5();
        if (_0x975e7c == 0 || _0xc1aa42 == 0) {
            return _0x2aac73;
        }
        return (_0x2aac73 * _0x975e7c) / _0xc1aa42;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0xf98f04(uint256 _0x5f9576) public view returns (uint256) {
        uint256 _0x975e7c = _0xaad6fc();
        if (_0x975e7c == 0) {
            return _0x5f9576;
        }
        return (_0x5f9576 * _0x66e7d5()) / _0x975e7c;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x66e7d5() public view returns (uint256) {
        if (_0x40e05b == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0x8e37c9 = IVotingEscrow(_0x38d618)._0x8e37c9(_0x40e05b);
        return uint256(int256(_0x8e37c9._0x2aac73));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0xf9bcbd(address _0xaab307, uint256 _0x2aac73) internal {
        uint256 _0xc0d332 = block.timestamp + _0xa5760b;
        _0x9e4791[_0xaab307].push(UserLock({
            _0x2aac73: _0x2aac73,
            _0xc0d332: _0xc0d332
        }));
        _0x417eeb[_0xaab307] += _0x2aac73;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x569dae(address _0xaab307) external view returns (uint256 _0x57be51) {
        uint256 _0xbbd1ad = _0xa264cc(_0xaab307);
        uint256 _0x3735df = 0;

        UserLock[] storage _0xce3112 = _0x9e4791[_0xaab307];
        for (uint256 i = 0; i < _0xce3112.length; i++) {
            if (_0xce3112[i]._0xc0d332 > block.timestamp) {
                _0x3735df += _0xce3112[i]._0x2aac73;
            }
        }

        return _0xbbd1ad > _0x3735df ? _0xbbd1ad - _0x3735df : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xdb6282(address _0xaab307) internal returns (uint256 _0xb98b92) {
        UserLock[] storage _0xce3112 = _0x9e4791[_0xaab307];
        uint256 _0x95f8fc = _0xce3112.length;
        if (_0x95f8fc == 0) return 0;

        uint256 _0x29e556 = 0;
        unchecked {
            for (uint256 i = 0; i < _0x95f8fc; i++) {
                UserLock memory L = _0xce3112[i];
                if (L._0xc0d332 <= block.timestamp) {
                    _0xb98b92 += L._0x2aac73;
                } else {
                    if (_0x29e556 != i) _0xce3112[_0x29e556] = L;
                    _0x29e556++;
                }
            }
            if (_0xb98b92 > 0) {
                _0x417eeb[_0xaab307] -= _0xb98b92;
            }
            while (_0xce3112.length > _0x29e556) {
                _0xce3112.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x12f906(
        address from,
        address _0xaa7c26,
        uint256 _0x2aac73
    ) internal override {
        super._0x12f906(from, _0xaa7c26, _0x2aac73);

        if (from != address(0) && _0xaa7c26 != address(0)) { // Not mint or burn
            uint256 _0xbbd1ad = _0xa264cc(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0x10af94 = _0xbbd1ad > _0x417eeb[from] ? _0xbbd1ad - _0x417eeb[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0x10af94 >= _0x2aac73) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xdb6282(from);
            uint256 _0x6768c1 = _0xbbd1ad > _0x417eeb[from] ? _0xbbd1ad - _0x417eeb[from] : 0;

            // Step 4: Check final available balance
            require(_0x6768c1 >= _0x2aac73, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0xef97f2() external _0x9d31b5 {
        require(_0x7463c1 != address(0), "Voter not set");
        require(_0x5b5eb0 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0xed6677 = IRewardsDistributor(_0x5b5eb0)._0xf22ca9(_0x40e05b);
        _0x21f622 += _0xed6677;
        // Claim bribes from voted pools
        address[] memory _0xf13b45 = IVoter(_0x7463c1)._0x73ec57(_0x40e05b);

        for (uint256 i = 0; i < _0xf13b45.length; i++) {
            if (_0xf13b45[i] != address(0)) {
                address _0xecfada = IGaugeManager(_0x0d9c85)._0x1f4bcb(_0xf13b45[i]);

                if (_0xecfada != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0xd13a97 = new address[](1);
                    address[][] memory _0x8c3a19 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0xae5ffc = IGaugeManager(_0x0d9c85)._0x2e6d37(_0xecfada);
                    if (_0xae5ffc != address(0)) {
                        uint256 _0x53ff1c = IBribe(_0xae5ffc)._0x5f40af();
                        if (_0x53ff1c > 0) {
                            address[] memory _0xf39b5f = new address[](_0x53ff1c);
                            for (uint256 j = 0; j < _0x53ff1c; j++) {
                                _0xf39b5f[j] = IBribe(_0xae5ffc)._0xf39b5f(j);
                            }
                            _0xd13a97[0] = _0xae5ffc;
                            _0x8c3a19[0] = _0xf39b5f;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x0d9c85)._0x9aa039(_0xd13a97, _0x8c3a19, _0x40e05b);
                        }
                    }

                    // Claim external bribe
                    address _0xa9023d = IGaugeManager(_0x0d9c85)._0x112b67(_0xecfada);
                    if (_0xa9023d != address(0)) {
                        uint256 _0x53ff1c = IBribe(_0xa9023d)._0x5f40af();
                        if (_0x53ff1c > 0) {
                            address[] memory _0xf39b5f = new address[](_0x53ff1c);
                            for (uint256 j = 0; j < _0x53ff1c; j++) {
                                _0xf39b5f[j] = IBribe(_0xa9023d)._0xf39b5f(j);
                            }
                            _0xd13a97[0] = _0xa9023d;
                            _0x8c3a19[0] = _0xf39b5f;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x0d9c85)._0x9aa039(_0xd13a97, _0x8c3a19, _0x40e05b);
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
    function _0x8a7d9b(ISwapper.SwapParams calldata _0x830017) external _0x1b2a23 _0x9d31b5 {
        require(address(_0x012212) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x94e890 = IERC20(_0x830017._0xd69d62)._0xa264cc(address(this));
        require(_0x94e890 >= _0x830017._0xca3467, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x830017._0xd69d62)._0x8403ec(address(_0x012212), _0x830017._0xca3467);

        // Execute swap through swapper module
        uint256 _0xbd21de = _0x012212._0xc482b0(_0x830017);

        // Reset approval for safety
        IERC20(_0x830017._0xd69d62)._0x8403ec(address(_0x012212), 0);

        // HYBR is now in this contract, ready for compounding
        _0x790f45 += _0xbd21de;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0x9bcd91() external _0x9d31b5 {

        // Get current HYBR balance
        uint256 _0x3b4f30 = IERC20(HYBR)._0xa264cc(address(this));

        if (_0x3b4f30 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x8403ec(_0x38d618, _0x3b4f30);
            IVotingEscrow(_0x38d618)._0x43936e(_0x40e05b, _0x3b4f30);

            // Extend lock to maximum duration
            _0x1180be();

            _0x81fdca = block.timestamp;

            emit Compound(_0x3b4f30, _0x66e7d5());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0xee8af8(address[] calldata _0xfd33a4, uint256[] calldata _0x1ed05e) external {
        require(msg.sender == _0x11e782() || msg.sender == _0xb12fd0, "Not authorized");
        require(_0x7463c1 != address(0), "Voter not set");

        IVoter(_0x7463c1)._0xee8af8(_0x40e05b, _0xfd33a4, _0x1ed05e);
        if (true) { _0x612001 = HybraTimeLibrary._0x09429a(block.timestamp); }

    }

    /**
     * @notice Reset votes
     */
    function _0x450e1f() external {
        require(msg.sender == _0x11e782() || msg.sender == _0xb12fd0, "Not authorized");
        require(_0x7463c1 != address(0), "Voter not set");

        IVoter(_0x7463c1)._0x450e1f(_0x40e05b);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x6f69c3(uint256 _0x2aac73) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x2aac73 > 0) {
            IERC20(HYBR)._0x823e89(_0x38d618, _0x2aac73);

            if(_0x40e05b == 0){
                _0x8029d8(_0x2aac73);
            } else{
                IVotingEscrow(_0x38d618)._0x43936e(_0x40e05b, _0x2aac73);

                // Extend lock to maximum duration
                _0x1180be();
            }
        }
        _0x3a5dd1 += _0x2aac73;
        emit PenaltyRewardReceived(_0x2aac73);
    }

    /**
     * @notice Set the voter contract
     */
    function _0x078615(address _0xbe6d4e) external _0x9155b6 {
        require(_0xbe6d4e != address(0), "Invalid voter");
        _0x7463c1 = _0xbe6d4e;
        emit VoterSet(_0xbe6d4e);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0xb49f0d(uint256 _0x49a465) external _0x9155b6 {
        require(_0x49a465 >= MIN_LOCK_PERIOD && _0x49a465 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0xe6530c = _0xa5760b;
        if (1 == 1) { _0xa5760b = _0x49a465; }
        emit TransferLockPeriodUpdated(_0xe6530c, _0x49a465);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0xe16cb5(uint256 _0x977676) external _0x9155b6 {
        require(_0x977676 >= MIN_WITHDRAW_FEE && _0x977676 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x7c4d71 = _0x977676;
    }

    function _0x16291c(uint256 _0xc52ee1) external _0x9155b6 {
        _0x7b1285 = _0xc52ee1;
    }

    function _0xa5dc3c(uint256 _0xc52ee1) external _0x9155b6 {
        if (true) { _0xeb5b99 = _0xc52ee1; }
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x6653fc(address _0x66e6b7) external _0x9155b6 {
        require(_0x66e6b7 != address(0), "Invalid swapper");
        address _0x2a0b0b = address(_0x012212);
        _0x012212 = ISwapper(_0x66e6b7);
        emit SwapperUpdated(_0x2a0b0b, _0x66e6b7);
    }

    /**
     * @notice Set the team address
     */
    function _0xd52ccc(address _0x24e627) external _0x9155b6 {
        require(_0x24e627 != address(0), "Invalid team");
        Team = _0x24e627;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x486e7c(address _0xaab307) external _0x9d31b5 {
        delete _0x9e4791[_0xaab307];
        _0x417eeb[_0xaab307] = 0;
        emit EmergencyUnlock(_0xaab307);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x6c5e3c(address _0xaab307) external view returns (UserLock[] memory) {
        return _0x9e4791[_0xaab307];
    }

    /**
     * @notice Set operator address
     */
    function _0x622b74(address _0x7ffe9c) external _0x9155b6 {
        require(_0x7ffe9c != address(0), "Invalid operator");
        address _0x034675 = _0xb12fd0;
        _0xb12fd0 = _0x7ffe9c;
        emit OperatorUpdated(_0x034675, _0x7ffe9c);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0xa519a4() external view returns (uint256) {
        if (_0x40e05b == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x8e37c9 = IVotingEscrow(_0x38d618)._0x8e37c9(_0x40e05b);
        return uint256(_0x8e37c9._0x345e3f);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0x1180be() internal {
        if (_0x40e05b == 0) return;

        IVotingEscrow.LockedBalance memory _0x8e37c9 = IVotingEscrow(_0x38d618)._0x8e37c9(_0x40e05b);
        if (_0x8e37c9._0x3ceb3a || _0x8e37c9._0x345e3f <= block.timestamp) return;

        uint256 _0xb675c6 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0xb675c6 > _0x8e37c9._0x345e3f + 2 hours) {
            try IVotingEscrow(_0x38d618)._0x32abd1(_0x40e05b, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}