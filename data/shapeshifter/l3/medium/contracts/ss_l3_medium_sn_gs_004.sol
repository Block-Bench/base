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
    uint256 public _0xcd8aa8 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x1ba363 = 1200; // 5days
    uint256 public _0x09c6d6 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0xc90859 = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0xfd26ac;
    uint256 public _0xdc5272;
    uint256 public _0x8cf1ff;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x9288b4;
        uint256 _0xb8fb9c;
    }

    mapping(address => UserLock[]) public _0x453047;
    mapping(address => uint256) public _0x1f7080;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x1e14e7;
    address public _0x79bd2b;
    address public _0x977f56;
    address public _0x4d624f;
    uint256 public _0x1585c1; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0x1660de; // Address that can manage voting strategy
    uint256 public _0x919638; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x358200;
    uint256 public _0x905e47;

    // Swap module
    ISwapper public _0x9cccbf;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0x2ca574, uint256 _0xfa5ea1, uint256 _0x6c2398);
    event Withdraw(address indexed _0x2ca574, uint256 _0x3945f3, uint256 _0xfa5ea1, uint256 _0x33a22c);
    event Compound(uint256 _0x2feb54, uint256 _0x520926);
    event PenaltyRewardReceived(uint256 _0x9288b4);
    event TransferLockPeriodUpdated(uint256 _0x25d4a6, uint256 _0xf6ddde);
    event SwapperUpdated(address indexed _0x40a6a3, address indexed _0x98513a);
    event VoterSet(address _0x79bd2b);
    event EmergencyUnlock(address indexed _0x2ca574);
    event AutoVotingEnabled(bool _0x614216);
    event OperatorUpdated(address indexed _0x4c323c, address indexed _0x16cfe2);
    event DefaultVotingStrategyUpdated(address[] _0x43447b, uint256[] _0x675a3a);
    event AutoVoteExecuted(uint256 _0x783fb9, address[] _0x43447b, uint256[] _0x675a3a);

    constructor(
        address _0xbde7d5,
        address _0x242c26
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xbde7d5 != address(0), "Invalid HYBR");
        require(_0x242c26 != address(0), "Invalid VE");

        HYBR = _0xbde7d5;
        _0x1e14e7 = _0x242c26;
        _0x358200 = block.timestamp;
        _0x905e47 = block.timestamp;
        _0x1660de = msg.sender; // Initially set deployer as operator
    }

    function _0xfdb0e5(address _0xbf1c68) external _0x09c856 {
        require(_0xbf1c68 != address(0), "Invalid rewards distributor");
        _0x977f56 = _0xbf1c68;
    }

    function _0x6d528f(address _0xd7d780) external _0x09c856 {
        require(_0xd7d780 != address(0), "Invalid gauge manager");
        _0x4d624f = _0xd7d780;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0x9d4f46() {
        if (msg.sender != _0x1660de) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x369cd9(uint256 _0x9288b4, address _0xb5ed3f) external _0x439fef {
        require(_0x9288b4 > 0, "Zero amount");
        _0xb5ed3f = _0xb5ed3f == address(0) ? msg.sender : _0xb5ed3f;

        // Transfer HYBR from user first
        IERC20(HYBR)._0xacd279(msg.sender, address(this), _0x9288b4);

        // Initialize veNFT on first deposit
        if (_0x1585c1 == 0) {
            _0x513e0b(_0x9288b4);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x138500(_0x1e14e7, _0x9288b4);
            IVotingEscrow(_0x1e14e7)._0x5edc01(_0x1585c1, _0x9288b4);

            // Extend lock to maximum duration
            _0xf6684c();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0x3945f3 = _0x113428(_0x9288b4);

        // Mint gHYBR shares
        _0x00d7b2(_0xb5ed3f, _0x3945f3);

        // Add transfer lock for recipient
        _0x69043c(_0xb5ed3f, _0x3945f3);

        emit Deposit(msg.sender, _0x9288b4, _0x3945f3);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0xf263b2(uint256 _0x3945f3) external _0x439fef returns (uint256 _0x91bfec) {
        require(_0x3945f3 > 0, "Zero shares");
        require(_0x75a829(msg.sender) >= _0x3945f3, "Insufficient balance");
        require(_0x1585c1 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x1e14e7)._0x380009(_0x1585c1) == false, "Cannot withdraw yet");

        uint256 _0x6c1bdd = HybraTimeLibrary._0x6c1bdd(block.timestamp);
        uint256 _0xd6f41e = HybraTimeLibrary._0xd6f41e(block.timestamp);

        require(block.timestamp >= _0x6c1bdd + _0x1ba363 && block.timestamp < _0xd6f41e - _0x09c6d6, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0xfa5ea1 = _0xb4f761(_0x3945f3);
        require(_0xfa5ea1 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0x3e7f6c = 0;
        if (_0xc90859 > 0) {
            if (true) { _0x3e7f6c = (_0xfa5ea1 * _0xc90859) / BASIS; }
        }

        // User receives amount minus fee
        uint256 _0xd8b74b = _0xfa5ea1 - _0x3e7f6c;
        require(_0xd8b74b > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x71b1c0 = _0x49f9a7();
        require(_0xfa5ea1 <= _0x71b1c0, "Insufficient veNFT balance");

        uint256 _0x207702 = _0x71b1c0 - _0xd8b74b - _0x3e7f6c;
        require(_0x207702 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x7926d1(msg.sender, _0x3945f3);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0x94e823 = new uint256[](3);
        _0x94e823[0] = _0x207702; // Amount staying with gHYBR
        _0x94e823[1] = _0xd8b74b;      // Amount going to user (after fee)
        _0x94e823[2] = _0x3e7f6c;      // Amount going to fee recipient

        uint256[] memory _0xf6aedc = IVotingEscrow(_0x1e14e7)._0xca59cb(_0x1585c1, _0x94e823);

        // Update contract's veTokenId to the first new token
        _0x1585c1 = _0xf6aedc[0];
        _0x91bfec = _0xf6aedc[1];
        uint256 _0xd349d2 = _0xf6aedc[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x1e14e7)._0x44c5f4(address(this), msg.sender, _0x91bfec);
        IVotingEscrow(_0x1e14e7)._0x44c5f4(address(this), Team, _0xd349d2);
        emit Withdraw(msg.sender, _0x3945f3, _0xd8b74b, _0x3e7f6c);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0x513e0b(uint256 _0xcd209f) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x138500(_0x1e14e7, type(uint256)._0x62ad02);
        uint256 _0x51ebd0 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x1585c1 = IVotingEscrow(_0x1e14e7)._0x3fbe45(_0xcd209f, _0x51ebd0, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0x113428(uint256 _0x9288b4) public view returns (uint256) {
        uint256 _0xfa462d = _0xb90cb9();
        uint256 _0x11052d = _0x49f9a7();
        if (_0xfa462d == 0 || _0x11052d == 0) {
            return _0x9288b4;
        }
        return (_0x9288b4 * _0xfa462d) / _0x11052d;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0xb4f761(uint256 _0x3945f3) public view returns (uint256) {
        uint256 _0xfa462d = _0xb90cb9();
        if (_0xfa462d == 0) {
            return _0x3945f3;
        }
        return (_0x3945f3 * _0x49f9a7()) / _0xfa462d;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x49f9a7() public view returns (uint256) {
        if (_0x1585c1 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0xa3166d = IVotingEscrow(_0x1e14e7)._0xa3166d(_0x1585c1);
        return uint256(int256(_0xa3166d._0x9288b4));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0x69043c(address _0x2ca574, uint256 _0x9288b4) internal {
        uint256 _0xb8fb9c = block.timestamp + _0xcd8aa8;
        _0x453047[_0x2ca574].push(UserLock({
            _0x9288b4: _0x9288b4,
            _0xb8fb9c: _0xb8fb9c
        }));
        _0x1f7080[_0x2ca574] += _0x9288b4;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x78b106(address _0x2ca574) external view returns (uint256 _0x40fa1e) {
        uint256 _0x7ecbbd = _0x75a829(_0x2ca574);
        uint256 _0x0d0a6f = 0;

        UserLock[] storage _0xa916f1 = _0x453047[_0x2ca574];
        for (uint256 i = 0; i < _0xa916f1.length; i++) {
            if (_0xa916f1[i]._0xb8fb9c > block.timestamp) {
                _0x0d0a6f += _0xa916f1[i]._0x9288b4;
            }
        }

        return _0x7ecbbd > _0x0d0a6f ? _0x7ecbbd - _0x0d0a6f : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0x4e27c6(address _0x2ca574) internal returns (uint256 _0x6168af) {
        UserLock[] storage _0xa916f1 = _0x453047[_0x2ca574];
        uint256 _0x92a0f7 = _0xa916f1.length;
        if (_0x92a0f7 == 0) return 0;

        uint256 _0x26a068 = 0;
        unchecked {
            for (uint256 i = 0; i < _0x92a0f7; i++) {
                UserLock memory L = _0xa916f1[i];
                if (L._0xb8fb9c <= block.timestamp) {
                    _0x6168af += L._0x9288b4;
                } else {
                    if (_0x26a068 != i) _0xa916f1[_0x26a068] = L;
                    _0x26a068++;
                }
            }
            if (_0x6168af > 0) {
                _0x1f7080[_0x2ca574] -= _0x6168af;
            }
            while (_0xa916f1.length > _0x26a068) {
                _0xa916f1.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x67f146(
        address from,
        address _0xff887d,
        uint256 _0x9288b4
    ) internal override {
        super._0x67f146(from, _0xff887d, _0x9288b4);

        if (from != address(0) && _0xff887d != address(0)) { // Not mint or burn
            uint256 _0x7ecbbd = _0x75a829(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0xbfaafd = _0x7ecbbd > _0x1f7080[from] ? _0x7ecbbd - _0x1f7080[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0xbfaafd >= _0x9288b4) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0x4e27c6(from);
            uint256 _0xfe1b84 = _0x7ecbbd > _0x1f7080[from] ? _0x7ecbbd - _0x1f7080[from] : 0;

            // Step 4: Check final available balance
            require(_0xfe1b84 >= _0x9288b4, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0xe0231c() external _0x9d4f46 {
        require(_0x79bd2b != address(0), "Voter not set");
        require(_0x977f56 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x6e4470 = IRewardsDistributor(_0x977f56)._0xfce241(_0x1585c1);
        _0xfd26ac += _0x6e4470;
        // Claim bribes from voted pools
        address[] memory _0x4c2197 = IVoter(_0x79bd2b)._0x9a4620(_0x1585c1);

        for (uint256 i = 0; i < _0x4c2197.length; i++) {
            if (_0x4c2197[i] != address(0)) {
                address _0x268a01 = IGaugeManager(_0x4d624f)._0xf297e9(_0x4c2197[i]);

                if (_0x268a01 != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0x670531 = new address[](1);
                    address[][] memory _0xf2b2c3 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0x51fca5 = IGaugeManager(_0x4d624f)._0xfaad16(_0x268a01);
                    if (_0x51fca5 != address(0)) {
                        uint256 _0x0bc34d = IBribe(_0x51fca5)._0x0a554e();
                        if (_0x0bc34d > 0) {
                            address[] memory _0xec7cb3 = new address[](_0x0bc34d);
                            for (uint256 j = 0; j < _0x0bc34d; j++) {
                                _0xec7cb3[j] = IBribe(_0x51fca5)._0xec7cb3(j);
                            }
                            _0x670531[0] = _0x51fca5;
                            _0xf2b2c3[0] = _0xec7cb3;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x4d624f)._0x38282b(_0x670531, _0xf2b2c3, _0x1585c1);
                        }
                    }

                    // Claim external bribe
                    address _0xd4d86a = IGaugeManager(_0x4d624f)._0x0d4f43(_0x268a01);
                    if (_0xd4d86a != address(0)) {
                        uint256 _0x0bc34d = IBribe(_0xd4d86a)._0x0a554e();
                        if (_0x0bc34d > 0) {
                            address[] memory _0xec7cb3 = new address[](_0x0bc34d);
                            for (uint256 j = 0; j < _0x0bc34d; j++) {
                                _0xec7cb3[j] = IBribe(_0xd4d86a)._0xec7cb3(j);
                            }
                            _0x670531[0] = _0xd4d86a;
                            _0xf2b2c3[0] = _0xec7cb3;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x4d624f)._0x38282b(_0x670531, _0xf2b2c3, _0x1585c1);
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
    function _0x7c1855(ISwapper.SwapParams calldata _0xe20d1c) external _0x439fef _0x9d4f46 {
        require(address(_0x9cccbf) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0xe16bc0 = IERC20(_0xe20d1c._0xc6db04)._0x75a829(address(this));
        require(_0xe16bc0 >= _0xe20d1c._0xef1206, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0xe20d1c._0xc6db04)._0x295256(address(_0x9cccbf), _0xe20d1c._0xef1206);

        // Execute swap through swapper module
        uint256 _0x76eba6 = _0x9cccbf._0xfa0389(_0xe20d1c);

        // Reset approval for safety
        IERC20(_0xe20d1c._0xc6db04)._0x295256(address(_0x9cccbf), 0);

        // HYBR is now in this contract, ready for compounding
        _0x8cf1ff += _0x76eba6;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0xcefbf9() external _0x9d4f46 {

        // Get current HYBR balance
        uint256 _0xa9a259 = IERC20(HYBR)._0x75a829(address(this));

        if (_0xa9a259 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x295256(_0x1e14e7, _0xa9a259);
            IVotingEscrow(_0x1e14e7)._0x5edc01(_0x1585c1, _0xa9a259);

            // Extend lock to maximum duration
            _0xf6684c();

            _0x905e47 = block.timestamp;

            emit Compound(_0xa9a259, _0x49f9a7());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0x45f69b(address[] calldata _0xa8660f, uint256[] calldata _0x52ffb8) external {
        require(msg.sender == _0xe9a09e() || msg.sender == _0x1660de, "Not authorized");
        require(_0x79bd2b != address(0), "Voter not set");

        IVoter(_0x79bd2b)._0x45f69b(_0x1585c1, _0xa8660f, _0x52ffb8);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x919638 = HybraTimeLibrary._0x6c1bdd(block.timestamp); }

    }

    /**
     * @notice Reset votes
     */
    function _0xfd2665() external {
        require(msg.sender == _0xe9a09e() || msg.sender == _0x1660de, "Not authorized");
        require(_0x79bd2b != address(0), "Voter not set");

        IVoter(_0x79bd2b)._0xfd2665(_0x1585c1);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x0ba4b6(uint256 _0x9288b4) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x9288b4 > 0) {
            IERC20(HYBR)._0x138500(_0x1e14e7, _0x9288b4);

            if(_0x1585c1 == 0){
                _0x513e0b(_0x9288b4);
            } else{
                IVotingEscrow(_0x1e14e7)._0x5edc01(_0x1585c1, _0x9288b4);

                // Extend lock to maximum duration
                _0xf6684c();
            }
        }
        _0xdc5272 += _0x9288b4;
        emit PenaltyRewardReceived(_0x9288b4);
    }

    /**
     * @notice Set the voter contract
     */
    function _0xc3ac84(address _0x97d8b4) external _0x09c856 {
        require(_0x97d8b4 != address(0), "Invalid voter");
        _0x79bd2b = _0x97d8b4;
        emit VoterSet(_0x97d8b4);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x842533(uint256 _0x150d5b) external _0x09c856 {
        require(_0x150d5b >= MIN_LOCK_PERIOD && _0x150d5b <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x25d4a6 = _0xcd8aa8;
        _0xcd8aa8 = _0x150d5b;
        emit TransferLockPeriodUpdated(_0x25d4a6, _0x150d5b);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x2f2989(uint256 _0x0da399) external _0x09c856 {
        require(_0x0da399 >= MIN_WITHDRAW_FEE && _0x0da399 <= MAX_WITHDRAW_FEE, "Invalid fee");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xc90859 = _0x0da399; }
    }

    function _0x9ce40e(uint256 _0xc703f2) external _0x09c856 {
        _0x1ba363 = _0xc703f2;
    }

    function _0x843d9f(uint256 _0xc703f2) external _0x09c856 {
        _0x09c6d6 = _0xc703f2;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x39ea69(address _0x5e0694) external _0x09c856 {
        require(_0x5e0694 != address(0), "Invalid swapper");
        address _0x40a6a3 = address(_0x9cccbf);
        _0x9cccbf = ISwapper(_0x5e0694);
        emit SwapperUpdated(_0x40a6a3, _0x5e0694);
    }

    /**
     * @notice Set the team address
     */
    function _0xf4950c(address _0x5a278b) external _0x09c856 {
        require(_0x5a278b != address(0), "Invalid team");
        if (block.timestamp > 0) { Team = _0x5a278b; }
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x22c376(address _0x2ca574) external _0x9d4f46 {
        delete _0x453047[_0x2ca574];
        _0x1f7080[_0x2ca574] = 0;
        emit EmergencyUnlock(_0x2ca574);
    }

    /**
     * @notice Get user's locks info
     */
    function _0xc6cd7a(address _0x2ca574) external view returns (UserLock[] memory) {
        return _0x453047[_0x2ca574];
    }

    /**
     * @notice Set operator address
     */
    function _0xa750ff(address _0x30b8a3) external _0x09c856 {
        require(_0x30b8a3 != address(0), "Invalid operator");
        address _0x4c323c = _0x1660de;
        _0x1660de = _0x30b8a3;
        emit OperatorUpdated(_0x4c323c, _0x30b8a3);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0xf4f15b() external view returns (uint256) {
        if (_0x1585c1 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0xa3166d = IVotingEscrow(_0x1e14e7)._0xa3166d(_0x1585c1);
        return uint256(_0xa3166d._0xd21254);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0xf6684c() internal {
        if (_0x1585c1 == 0) return;

        IVotingEscrow.LockedBalance memory _0xa3166d = IVotingEscrow(_0x1e14e7)._0xa3166d(_0x1585c1);
        if (_0xa3166d._0xf7a438 || _0xa3166d._0xd21254 <= block.timestamp) return;

        uint256 _0xea95fc = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0xea95fc > _0xa3166d._0xd21254 + 2 hours) {
            try IVotingEscrow(_0x1e14e7)._0x733fbd(_0x1585c1, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}