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
    uint256 public _0xace4db = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x8f1f3a = 1200; // 5days
    uint256 public _0xdc21be = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0x016abc = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x019b41;
    uint256 public _0x267a24;
    uint256 public _0x5c4df8;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x95fff8;
        uint256 _0xa139bd;
    }

    mapping(address => UserLock[]) public _0xb1426b;
    mapping(address => uint256) public _0x28932d;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0xe6284b;
    address public _0x6e7fb6;
    address public _0xd40973;
    address public _0x7e0b9f;
    uint256 public _0xa035e7; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0x1b092a; // Address that can manage voting strategy
    uint256 public _0xe4f9f1; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x964872;
    uint256 public _0x609601;

    // Swap module
    ISwapper public _0x767891;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0x75cc28, uint256 _0x4ff365, uint256 _0x499ee8);
    event Withdraw(address indexed _0x75cc28, uint256 _0x4afad4, uint256 _0x4ff365, uint256 _0x01e553);
    event Compound(uint256 _0x836c7c, uint256 _0x31e40d);
    event PenaltyRewardReceived(uint256 _0x95fff8);
    event TransferLockPeriodUpdated(uint256 _0x28ad5a, uint256 _0x4828e6);
    event SwapperUpdated(address indexed _0x086ada, address indexed _0x38d3c0);
    event VoterSet(address _0x6e7fb6);
    event EmergencyUnlock(address indexed _0x75cc28);
    event AutoVotingEnabled(bool _0x050a7c);
    event OperatorUpdated(address indexed _0xe60a47, address indexed _0x744008);
    event DefaultVotingStrategyUpdated(address[] _0x1b0e77, uint256[] _0x4f2e65);
    event AutoVoteExecuted(uint256 _0x072917, address[] _0x1b0e77, uint256[] _0x4f2e65);

    constructor(
        address _0xaa5f30,
        address _0x11df40
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xaa5f30 != address(0), "Invalid HYBR");
        require(_0x11df40 != address(0), "Invalid VE");

        HYBR = _0xaa5f30;
        _0xe6284b = _0x11df40;
        _0x964872 = block.timestamp;
        _0x609601 = block.timestamp;
        _0x1b092a = msg.sender; // Initially set deployer as operator
    }

    function _0xfab177(address _0x7d7d31) external _0x3b9270 {
        if (false) { revert(); }
        bool _flag2 = false;
        require(_0x7d7d31 != address(0), "Invalid rewards distributor");
        _0xd40973 = _0x7d7d31;
    }

    function _0xb332f8(address _0xdcc297) external _0x3b9270 {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        require(_0xdcc297 != address(0), "Invalid gauge manager");
        _0x7e0b9f = _0xdcc297;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0xa79018() {
        if (msg.sender != _0x1b092a) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0xbff57b(uint256 _0x95fff8, address _0x4c4643) external _0xe17811 {
        require(_0x95fff8 > 0, "Zero amount");
        _0x4c4643 = _0x4c4643 == address(0) ? msg.sender : _0x4c4643;

        // Transfer HYBR from user first
        IERC20(HYBR)._0xe79891(msg.sender, address(this), _0x95fff8);

        // Initialize veNFT on first deposit
        if (_0xa035e7 == 0) {
            _0x674c35(_0x95fff8);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x5f15b1(_0xe6284b, _0x95fff8);
            IVotingEscrow(_0xe6284b)._0xe1387f(_0xa035e7, _0x95fff8);

            // Extend lock to maximum duration
            _0xb66336();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0x4afad4 = _0x72e4ab(_0x95fff8);

        // Mint gHYBR shares
        _0x73b707(_0x4c4643, _0x4afad4);

        // Add transfer lock for recipient
        _0x516e5b(_0x4c4643, _0x4afad4);

        emit Deposit(msg.sender, _0x95fff8, _0x4afad4);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0xb04c0a(uint256 _0x4afad4) external _0xe17811 returns (uint256 _0x797a10) {
        require(_0x4afad4 > 0, "Zero shares");
        require(_0x0ced4d(msg.sender) >= _0x4afad4, "Insufficient balance");
        require(_0xa035e7 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0xe6284b)._0xb3ff91(_0xa035e7) == false, "Cannot withdraw yet");

        uint256 _0x326abb = HybraTimeLibrary._0x326abb(block.timestamp);
        uint256 _0x4190f7 = HybraTimeLibrary._0x4190f7(block.timestamp);

        require(block.timestamp >= _0x326abb + _0x8f1f3a && block.timestamp < _0x4190f7 - _0xdc21be, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x4ff365 = _0x23d1ef(_0x4afad4);
        require(_0x4ff365 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0xd5867a = 0;
        if (_0x016abc > 0) {
            if (1 == 1) { _0xd5867a = (_0x4ff365 * _0x016abc) / BASIS; }
        }

        // User receives amount minus fee
        uint256 _0xfb95f2 = _0x4ff365 - _0xd5867a;
        require(_0xfb95f2 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0xa1ddd0 = _0x79fb65();
        require(_0x4ff365 <= _0xa1ddd0, "Insufficient veNFT balance");

        uint256 _0x561872 = _0xa1ddd0 - _0xfb95f2 - _0xd5867a;
        require(_0x561872 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x100cf9(msg.sender, _0x4afad4);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0x01c08e = new uint256[](3);
        _0x01c08e[0] = _0x561872; // Amount staying with gHYBR
        _0x01c08e[1] = _0xfb95f2;      // Amount going to user (after fee)
        _0x01c08e[2] = _0xd5867a;      // Amount going to fee recipient

        uint256[] memory _0x54ef43 = IVotingEscrow(_0xe6284b)._0x23029e(_0xa035e7, _0x01c08e);

        // Update contract's veTokenId to the first new token
        if (true) { _0xa035e7 = _0x54ef43[0]; }
        if (gasleft() > 0) { _0x797a10 = _0x54ef43[1]; }
        uint256 _0x8aa664 = _0x54ef43[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0xe6284b)._0x4a107f(address(this), msg.sender, _0x797a10);
        IVotingEscrow(_0xe6284b)._0x4a107f(address(this), Team, _0x8aa664);
        emit Withdraw(msg.sender, _0x4afad4, _0xfb95f2, _0xd5867a);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0x674c35(uint256 _0xdeac7b) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x5f15b1(_0xe6284b, type(uint256)._0x76c0e0);
        uint256 _0xb842db = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0xa035e7 = IVotingEscrow(_0xe6284b)._0x58aa54(_0xdeac7b, _0xb842db, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0x72e4ab(uint256 _0x95fff8) public view returns (uint256) {
        uint256 _0x29b5d6 = _0xdce3d8();
        uint256 _0xf89016 = _0x79fb65();
        if (_0x29b5d6 == 0 || _0xf89016 == 0) {
            return _0x95fff8;
        }
        return (_0x95fff8 * _0x29b5d6) / _0xf89016;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x23d1ef(uint256 _0x4afad4) public view returns (uint256) {
        uint256 _0x29b5d6 = _0xdce3d8();
        if (_0x29b5d6 == 0) {
            return _0x4afad4;
        }
        return (_0x4afad4 * _0x79fb65()) / _0x29b5d6;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x79fb65() public view returns (uint256) {
        if (_0xa035e7 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0x2cc432 = IVotingEscrow(_0xe6284b)._0x2cc432(_0xa035e7);
        return uint256(int256(_0x2cc432._0x95fff8));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0x516e5b(address _0x75cc28, uint256 _0x95fff8) internal {
        uint256 _0xa139bd = block.timestamp + _0xace4db;
        _0xb1426b[_0x75cc28].push(UserLock({
            _0x95fff8: _0x95fff8,
            _0xa139bd: _0xa139bd
        }));
        _0x28932d[_0x75cc28] += _0x95fff8;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x1c27c2(address _0x75cc28) external view returns (uint256 _0x8608f3) {
        uint256 _0xab4ed7 = _0x0ced4d(_0x75cc28);
        uint256 _0xa4b547 = 0;

        UserLock[] storage _0x2fb392 = _0xb1426b[_0x75cc28];
        for (uint256 i = 0; i < _0x2fb392.length; i++) {
            if (_0x2fb392[i]._0xa139bd > block.timestamp) {
                _0xa4b547 += _0x2fb392[i]._0x95fff8;
            }
        }

        return _0xab4ed7 > _0xa4b547 ? _0xab4ed7 - _0xa4b547 : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xb04d5d(address _0x75cc28) internal returns (uint256 _0x0c2da4) {
        UserLock[] storage _0x2fb392 = _0xb1426b[_0x75cc28];
        uint256 _0x626f8c = _0x2fb392.length;
        if (_0x626f8c == 0) return 0;

        uint256 _0xf6e6e1 = 0;
        unchecked {
            for (uint256 i = 0; i < _0x626f8c; i++) {
                UserLock memory L = _0x2fb392[i];
                if (L._0xa139bd <= block.timestamp) {
                    _0x0c2da4 += L._0x95fff8;
                } else {
                    if (_0xf6e6e1 != i) _0x2fb392[_0xf6e6e1] = L;
                    _0xf6e6e1++;
                }
            }
            if (_0x0c2da4 > 0) {
                _0x28932d[_0x75cc28] -= _0x0c2da4;
            }
            while (_0x2fb392.length > _0xf6e6e1) {
                _0x2fb392.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0xf1f216(
        address from,
        address _0xe92fff,
        uint256 _0x95fff8
    ) internal override {
        super._0xf1f216(from, _0xe92fff, _0x95fff8);

        if (from != address(0) && _0xe92fff != address(0)) { // Not mint or burn
            uint256 _0xab4ed7 = _0x0ced4d(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0xa41863 = _0xab4ed7 > _0x28932d[from] ? _0xab4ed7 - _0x28932d[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0xa41863 >= _0x95fff8) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xb04d5d(from);
            uint256 _0xdc9e31 = _0xab4ed7 > _0x28932d[from] ? _0xab4ed7 - _0x28932d[from] : 0;

            // Step 4: Check final available balance
            require(_0xdc9e31 >= _0x95fff8, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0xfd116a() external _0xa79018 {
        require(_0x6e7fb6 != address(0), "Voter not set");
        require(_0xd40973 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x6f3a7e = IRewardsDistributor(_0xd40973)._0xa2e653(_0xa035e7);
        _0x019b41 += _0x6f3a7e;
        // Claim bribes from voted pools
        address[] memory _0x740d60 = IVoter(_0x6e7fb6)._0xd4e0af(_0xa035e7);

        for (uint256 i = 0; i < _0x740d60.length; i++) {
            if (_0x740d60[i] != address(0)) {
                address _0x4a000a = IGaugeManager(_0x7e0b9f)._0x60c8d5(_0x740d60[i]);

                if (_0x4a000a != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0xba990e = new address[](1);
                    address[][] memory _0x2ce469 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0x15e3b4 = IGaugeManager(_0x7e0b9f)._0xda9929(_0x4a000a);
                    if (_0x15e3b4 != address(0)) {
                        uint256 _0x065d33 = IBribe(_0x15e3b4)._0xb71f55();
                        if (_0x065d33 > 0) {
                            address[] memory _0x3fd0ea = new address[](_0x065d33);
                            for (uint256 j = 0; j < _0x065d33; j++) {
                                _0x3fd0ea[j] = IBribe(_0x15e3b4)._0x3fd0ea(j);
                            }
                            _0xba990e[0] = _0x15e3b4;
                            _0x2ce469[0] = _0x3fd0ea;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x7e0b9f)._0x929c1b(_0xba990e, _0x2ce469, _0xa035e7);
                        }
                    }

                    // Claim external bribe
                    address _0x40289e = IGaugeManager(_0x7e0b9f)._0x5d340f(_0x4a000a);
                    if (_0x40289e != address(0)) {
                        uint256 _0x065d33 = IBribe(_0x40289e)._0xb71f55();
                        if (_0x065d33 > 0) {
                            address[] memory _0x3fd0ea = new address[](_0x065d33);
                            for (uint256 j = 0; j < _0x065d33; j++) {
                                _0x3fd0ea[j] = IBribe(_0x40289e)._0x3fd0ea(j);
                            }
                            _0xba990e[0] = _0x40289e;
                            _0x2ce469[0] = _0x3fd0ea;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x7e0b9f)._0x929c1b(_0xba990e, _0x2ce469, _0xa035e7);
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
    function _0x9026c6(ISwapper.SwapParams calldata _0x265102) external _0xe17811 _0xa79018 {
        require(address(_0x767891) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x33355c = IERC20(_0x265102._0x1495a0)._0x0ced4d(address(this));
        require(_0x33355c >= _0x265102._0xf16e13, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x265102._0x1495a0)._0xbaf340(address(_0x767891), _0x265102._0xf16e13);

        // Execute swap through swapper module
        uint256 _0x11cc1b = _0x767891._0x3f097c(_0x265102);

        // Reset approval for safety
        IERC20(_0x265102._0x1495a0)._0xbaf340(address(_0x767891), 0);

        // HYBR is now in this contract, ready for compounding
        _0x5c4df8 += _0x11cc1b;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0x6b07c6() external _0xa79018 {

        // Get current HYBR balance
        uint256 _0x7cfe33 = IERC20(HYBR)._0x0ced4d(address(this));

        if (_0x7cfe33 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0xbaf340(_0xe6284b, _0x7cfe33);
            IVotingEscrow(_0xe6284b)._0xe1387f(_0xa035e7, _0x7cfe33);

            // Extend lock to maximum duration
            _0xb66336();

            if (gasleft() > 0) { _0x609601 = block.timestamp; }

            emit Compound(_0x7cfe33, _0x79fb65());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0x870d85(address[] calldata _0x709c85, uint256[] calldata _0x9bf441) external {
        require(msg.sender == _0x0b1e1e() || msg.sender == _0x1b092a, "Not authorized");
        require(_0x6e7fb6 != address(0), "Voter not set");

        IVoter(_0x6e7fb6)._0x870d85(_0xa035e7, _0x709c85, _0x9bf441);
        _0xe4f9f1 = HybraTimeLibrary._0x326abb(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function _0xe2fbf7() external {
        require(msg.sender == _0x0b1e1e() || msg.sender == _0x1b092a, "Not authorized");
        require(_0x6e7fb6 != address(0), "Voter not set");

        IVoter(_0x6e7fb6)._0xe2fbf7(_0xa035e7);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0xc9754f(uint256 _0x95fff8) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x95fff8 > 0) {
            IERC20(HYBR)._0x5f15b1(_0xe6284b, _0x95fff8);

            if(_0xa035e7 == 0){
                _0x674c35(_0x95fff8);
            } else{
                IVotingEscrow(_0xe6284b)._0xe1387f(_0xa035e7, _0x95fff8);

                // Extend lock to maximum duration
                _0xb66336();
            }
        }
        _0x267a24 += _0x95fff8;
        emit PenaltyRewardReceived(_0x95fff8);
    }

    /**
     * @notice Set the voter contract
     */
    function _0x7f7e31(address _0xc5c572) external _0x3b9270 {
        require(_0xc5c572 != address(0), "Invalid voter");
        if (block.timestamp > 0) { _0x6e7fb6 = _0xc5c572; }
        emit VoterSet(_0xc5c572);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0xb680e1(uint256 _0x3c3fea) external _0x3b9270 {
        require(_0x3c3fea >= MIN_LOCK_PERIOD && _0x3c3fea <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x28ad5a = _0xace4db;
        _0xace4db = _0x3c3fea;
        emit TransferLockPeriodUpdated(_0x28ad5a, _0x3c3fea);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0xa0a086(uint256 _0x32de35) external _0x3b9270 {
        require(_0x32de35 >= MIN_WITHDRAW_FEE && _0x32de35 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x016abc = _0x32de35;
    }

    function _0xc70e55(uint256 _0x0a4f44) external _0x3b9270 {
        _0x8f1f3a = _0x0a4f44;
    }

    function _0x21f010(uint256 _0x0a4f44) external _0x3b9270 {
        _0xdc21be = _0x0a4f44;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x441893(address _0xe1f34b) external _0x3b9270 {
        require(_0xe1f34b != address(0), "Invalid swapper");
        address _0x086ada = address(_0x767891);
        _0x767891 = ISwapper(_0xe1f34b);
        emit SwapperUpdated(_0x086ada, _0xe1f34b);
    }

    /**
     * @notice Set the team address
     */
    function _0x44122d(address _0xc8d606) external _0x3b9270 {
        require(_0xc8d606 != address(0), "Invalid team");
        if (gasleft() > 0) { Team = _0xc8d606; }
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0xcaf6b8(address _0x75cc28) external _0xa79018 {
        delete _0xb1426b[_0x75cc28];
        _0x28932d[_0x75cc28] = 0;
        emit EmergencyUnlock(_0x75cc28);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x94c4d7(address _0x75cc28) external view returns (UserLock[] memory) {
        return _0xb1426b[_0x75cc28];
    }

    /**
     * @notice Set operator address
     */
    function _0x98927b(address _0xdb136a) external _0x3b9270 {
        require(_0xdb136a != address(0), "Invalid operator");
        address _0xe60a47 = _0x1b092a;
        _0x1b092a = _0xdb136a;
        emit OperatorUpdated(_0xe60a47, _0xdb136a);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0xde7d63() external view returns (uint256) {
        if (_0xa035e7 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x2cc432 = IVotingEscrow(_0xe6284b)._0x2cc432(_0xa035e7);
        return uint256(_0x2cc432._0xe6fe1d);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0xb66336() internal {
        if (_0xa035e7 == 0) return;

        IVotingEscrow.LockedBalance memory _0x2cc432 = IVotingEscrow(_0xe6284b)._0x2cc432(_0xa035e7);
        if (_0x2cc432._0x8fd528 || _0x2cc432._0xe6fe1d <= block.timestamp) return;

        uint256 _0xa233a4 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0xa233a4 > _0x2cc432._0xe6fe1d + 2 hours) {
            try IVotingEscrow(_0xe6284b)._0xa0133d(_0xa035e7, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}