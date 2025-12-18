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
    uint256 public _0x92309b = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x50805a = 1200; // 5days
    uint256 public _0x520a67 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0x0dc53f = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x9714cc;
    uint256 public _0x3b47ca;
    uint256 public _0x7c0f51;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x3e78fa;
        uint256 _0xe64dd6;
    }

    mapping(address => UserLock[]) public _0xd935b4;
    mapping(address => uint256) public _0x9c7b96;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x8fa21b;
    address public _0x0d9a5d;
    address public _0xd4835f;
    address public _0x3afc25;
    uint256 public _0x0b9154; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0x3eedd2; // Address that can manage voting strategy
    uint256 public _0x889b9c; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x3c06de;
    uint256 public _0x3b6a50;

    // Swap module
    ISwapper public _0xb86365;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0x706102, uint256 _0x0ca0b0, uint256 _0x588e3e);
    event Withdraw(address indexed _0x706102, uint256 _0x1cefbb, uint256 _0x0ca0b0, uint256 _0x52125e);
    event Compound(uint256 _0xfdd4fc, uint256 _0x2eef9b);
    event PenaltyRewardReceived(uint256 _0x3e78fa);
    event TransferLockPeriodUpdated(uint256 _0xf9e0a8, uint256 _0x749f41);
    event SwapperUpdated(address indexed _0x83877a, address indexed _0xe0ef8a);
    event VoterSet(address _0x0d9a5d);
    event EmergencyUnlock(address indexed _0x706102);
    event AutoVotingEnabled(bool _0xa0d56c);
    event OperatorUpdated(address indexed _0xa46488, address indexed _0xdc1344);
    event DefaultVotingStrategyUpdated(address[] _0xf285f9, uint256[] _0x1f2cae);
    event AutoVoteExecuted(uint256 _0xe4a416, address[] _0xf285f9, uint256[] _0x1f2cae);

    constructor(
        address _0xf49b20,
        address _0xf831da
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xf49b20 != address(0), "Invalid HYBR");
        require(_0xf831da != address(0), "Invalid VE");

        HYBR = _0xf49b20;
        _0x8fa21b = _0xf831da;
        _0x3c06de = block.timestamp;
        _0x3b6a50 = block.timestamp;
        _0x3eedd2 = msg.sender; // Initially set deployer as operator
    }

    function _0x0a9089(address _0xfb95e1) external _0x687b6f {
        require(_0xfb95e1 != address(0), "Invalid rewards distributor");
        if (1 == 1) { _0xd4835f = _0xfb95e1; }
    }

    function _0xe798f3(address _0x94ccab) external _0x687b6f {
        require(_0x94ccab != address(0), "Invalid gauge manager");
        if (block.timestamp > 0) { _0x3afc25 = _0x94ccab; }
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0x82cbfa() {
        if (msg.sender != _0x3eedd2) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x9112d8(uint256 _0x3e78fa, address _0x817ecf) external _0x999d9d {
        require(_0x3e78fa > 0, "Zero amount");
        _0x817ecf = _0x817ecf == address(0) ? msg.sender : _0x817ecf;

        // Transfer HYBR from user first
        IERC20(HYBR)._0x56ac58(msg.sender, address(this), _0x3e78fa);

        // Initialize veNFT on first deposit
        if (_0x0b9154 == 0) {
            _0x15e62d(_0x3e78fa);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x1f9377(_0x8fa21b, _0x3e78fa);
            IVotingEscrow(_0x8fa21b)._0xc24414(_0x0b9154, _0x3e78fa);

            // Extend lock to maximum duration
            _0xa98711();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0x1cefbb = _0xbc2693(_0x3e78fa);

        // Mint gHYBR shares
        _0x6f3f7f(_0x817ecf, _0x1cefbb);

        // Add transfer lock for recipient
        _0x461c4c(_0x817ecf, _0x1cefbb);

        emit Deposit(msg.sender, _0x3e78fa, _0x1cefbb);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0x898325(uint256 _0x1cefbb) external _0x999d9d returns (uint256 _0xe7a81c) {
        require(_0x1cefbb > 0, "Zero shares");
        require(_0x60beef(msg.sender) >= _0x1cefbb, "Insufficient balance");
        require(_0x0b9154 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x8fa21b)._0xc1611e(_0x0b9154) == false, "Cannot withdraw yet");

        uint256 _0xa677ac = HybraTimeLibrary._0xa677ac(block.timestamp);
        uint256 _0x0bbf8e = HybraTimeLibrary._0x0bbf8e(block.timestamp);

        require(block.timestamp >= _0xa677ac + _0x50805a && block.timestamp < _0x0bbf8e - _0x520a67, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x0ca0b0 = _0xfbf1d1(_0x1cefbb);
        require(_0x0ca0b0 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0xda5899 = 0;
        if (_0x0dc53f > 0) {
            _0xda5899 = (_0x0ca0b0 * _0x0dc53f) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0xb75228 = _0x0ca0b0 - _0xda5899;
        require(_0xb75228 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x5a8c38 = _0x5a4f15();
        require(_0x0ca0b0 <= _0x5a8c38, "Insufficient veNFT balance");

        uint256 _0x9f3ddb = _0x5a8c38 - _0xb75228 - _0xda5899;
        require(_0x9f3ddb >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x52aa69(msg.sender, _0x1cefbb);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0x4cbdaf = new uint256[](3);
        _0x4cbdaf[0] = _0x9f3ddb; // Amount staying with gHYBR
        _0x4cbdaf[1] = _0xb75228;      // Amount going to user (after fee)
        _0x4cbdaf[2] = _0xda5899;      // Amount going to fee recipient

        uint256[] memory _0x1205d7 = IVotingEscrow(_0x8fa21b)._0x99ab77(_0x0b9154, _0x4cbdaf);

        // Update contract's veTokenId to the first new token
        _0x0b9154 = _0x1205d7[0];
        if (block.timestamp > 0) { _0xe7a81c = _0x1205d7[1]; }
        uint256 _0x5acb24 = _0x1205d7[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x8fa21b)._0x0102e9(address(this), msg.sender, _0xe7a81c);
        IVotingEscrow(_0x8fa21b)._0x0102e9(address(this), Team, _0x5acb24);
        emit Withdraw(msg.sender, _0x1cefbb, _0xb75228, _0xda5899);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0x15e62d(uint256 _0x1a1a2f) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x1f9377(_0x8fa21b, type(uint256)._0x3a5082);
        uint256 _0x2ff0fd = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x0b9154 = IVotingEscrow(_0x8fa21b)._0xc1c8b2(_0x1a1a2f, _0x2ff0fd, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0xbc2693(uint256 _0x3e78fa) public view returns (uint256) {
        uint256 _0x5f13fd = _0xff09e8();
        uint256 _0xe85fc9 = _0x5a4f15();
        if (_0x5f13fd == 0 || _0xe85fc9 == 0) {
            return _0x3e78fa;
        }
        return (_0x3e78fa * _0x5f13fd) / _0xe85fc9;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0xfbf1d1(uint256 _0x1cefbb) public view returns (uint256) {
        uint256 _0x5f13fd = _0xff09e8();
        if (_0x5f13fd == 0) {
            return _0x1cefbb;
        }
        return (_0x1cefbb * _0x5a4f15()) / _0x5f13fd;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x5a4f15() public view returns (uint256) {
        if (_0x0b9154 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0x7b4544 = IVotingEscrow(_0x8fa21b)._0x7b4544(_0x0b9154);
        return uint256(int256(_0x7b4544._0x3e78fa));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0x461c4c(address _0x706102, uint256 _0x3e78fa) internal {
        uint256 _0xe64dd6 = block.timestamp + _0x92309b;
        _0xd935b4[_0x706102].push(UserLock({
            _0x3e78fa: _0x3e78fa,
            _0xe64dd6: _0xe64dd6
        }));
        _0x9c7b96[_0x706102] += _0x3e78fa;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x6c851c(address _0x706102) external view returns (uint256 _0xc781d2) {
        uint256 _0xf98768 = _0x60beef(_0x706102);
        uint256 _0x063554 = 0;

        UserLock[] storage _0x207b3d = _0xd935b4[_0x706102];
        for (uint256 i = 0; i < _0x207b3d.length; i++) {
            if (_0x207b3d[i]._0xe64dd6 > block.timestamp) {
                _0x063554 += _0x207b3d[i]._0x3e78fa;
            }
        }

        return _0xf98768 > _0x063554 ? _0xf98768 - _0x063554 : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0x515ca5(address _0x706102) internal returns (uint256 _0x78f82d) {
        UserLock[] storage _0x207b3d = _0xd935b4[_0x706102];
        uint256 _0xb338aa = _0x207b3d.length;
        if (_0xb338aa == 0) return 0;

        uint256 _0xd733df = 0;
        unchecked {
            for (uint256 i = 0; i < _0xb338aa; i++) {
                UserLock memory L = _0x207b3d[i];
                if (L._0xe64dd6 <= block.timestamp) {
                    _0x78f82d += L._0x3e78fa;
                } else {
                    if (_0xd733df != i) _0x207b3d[_0xd733df] = L;
                    _0xd733df++;
                }
            }
            if (_0x78f82d > 0) {
                _0x9c7b96[_0x706102] -= _0x78f82d;
            }
            while (_0x207b3d.length > _0xd733df) {
                _0x207b3d.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x614cb9(
        address from,
        address _0xb74438,
        uint256 _0x3e78fa
    ) internal override {
        super._0x614cb9(from, _0xb74438, _0x3e78fa);

        if (from != address(0) && _0xb74438 != address(0)) { // Not mint or burn
            uint256 _0xf98768 = _0x60beef(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0xdc5256 = _0xf98768 > _0x9c7b96[from] ? _0xf98768 - _0x9c7b96[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0xdc5256 >= _0x3e78fa) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0x515ca5(from);
            uint256 _0x8316d1 = _0xf98768 > _0x9c7b96[from] ? _0xf98768 - _0x9c7b96[from] : 0;

            // Step 4: Check final available balance
            require(_0x8316d1 >= _0x3e78fa, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0x81032f() external _0x82cbfa {
        require(_0x0d9a5d != address(0), "Voter not set");
        require(_0xd4835f != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0xa14458 = IRewardsDistributor(_0xd4835f)._0x27ca89(_0x0b9154);
        _0x9714cc += _0xa14458;
        // Claim bribes from voted pools
        address[] memory _0xcf8f08 = IVoter(_0x0d9a5d)._0x47efd1(_0x0b9154);

        for (uint256 i = 0; i < _0xcf8f08.length; i++) {
            if (_0xcf8f08[i] != address(0)) {
                address _0xf5bd2e = IGaugeManager(_0x3afc25)._0x73fcf4(_0xcf8f08[i]);

                if (_0xf5bd2e != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0xbafb4a = new address[](1);
                    address[][] memory _0x339b38 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0x8c0a57 = IGaugeManager(_0x3afc25)._0xf82df2(_0xf5bd2e);
                    if (_0x8c0a57 != address(0)) {
                        uint256 _0xe249e4 = IBribe(_0x8c0a57)._0x48b7e1();
                        if (_0xe249e4 > 0) {
                            address[] memory _0xe215e1 = new address[](_0xe249e4);
                            for (uint256 j = 0; j < _0xe249e4; j++) {
                                _0xe215e1[j] = IBribe(_0x8c0a57)._0xe215e1(j);
                            }
                            _0xbafb4a[0] = _0x8c0a57;
                            _0x339b38[0] = _0xe215e1;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x3afc25)._0x070d23(_0xbafb4a, _0x339b38, _0x0b9154);
                        }
                    }

                    // Claim external bribe
                    address _0x005e71 = IGaugeManager(_0x3afc25)._0x14f2c1(_0xf5bd2e);
                    if (_0x005e71 != address(0)) {
                        uint256 _0xe249e4 = IBribe(_0x005e71)._0x48b7e1();
                        if (_0xe249e4 > 0) {
                            address[] memory _0xe215e1 = new address[](_0xe249e4);
                            for (uint256 j = 0; j < _0xe249e4; j++) {
                                _0xe215e1[j] = IBribe(_0x005e71)._0xe215e1(j);
                            }
                            _0xbafb4a[0] = _0x005e71;
                            _0x339b38[0] = _0xe215e1;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x3afc25)._0x070d23(_0xbafb4a, _0x339b38, _0x0b9154);
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
    function _0xc2030a(ISwapper.SwapParams calldata _0x260d87) external _0x999d9d _0x82cbfa {
        require(address(_0xb86365) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x12ac24 = IERC20(_0x260d87._0x3842bb)._0x60beef(address(this));
        require(_0x12ac24 >= _0x260d87._0x27a151, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x260d87._0x3842bb)._0x2ab207(address(_0xb86365), _0x260d87._0x27a151);

        // Execute swap through swapper module
        uint256 _0x07666a = _0xb86365._0xdd7dab(_0x260d87);

        // Reset approval for safety
        IERC20(_0x260d87._0x3842bb)._0x2ab207(address(_0xb86365), 0);

        // HYBR is now in this contract, ready for compounding
        _0x7c0f51 += _0x07666a;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0xfbf683() external _0x82cbfa {

        // Get current HYBR balance
        uint256 _0xa41760 = IERC20(HYBR)._0x60beef(address(this));

        if (_0xa41760 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x2ab207(_0x8fa21b, _0xa41760);
            IVotingEscrow(_0x8fa21b)._0xc24414(_0x0b9154, _0xa41760);

            // Extend lock to maximum duration
            _0xa98711();

            _0x3b6a50 = block.timestamp;

            emit Compound(_0xa41760, _0x5a4f15());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0xb63650(address[] calldata _0xa53b14, uint256[] calldata _0x284840) external {
        require(msg.sender == _0xb63b84() || msg.sender == _0x3eedd2, "Not authorized");
        require(_0x0d9a5d != address(0), "Voter not set");

        IVoter(_0x0d9a5d)._0xb63650(_0x0b9154, _0xa53b14, _0x284840);
        if (1 == 1) { _0x889b9c = HybraTimeLibrary._0xa677ac(block.timestamp); }

    }

    /**
     * @notice Reset votes
     */
    function _0x146e4f() external {
        require(msg.sender == _0xb63b84() || msg.sender == _0x3eedd2, "Not authorized");
        require(_0x0d9a5d != address(0), "Voter not set");

        IVoter(_0x0d9a5d)._0x146e4f(_0x0b9154);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x4ac791(uint256 _0x3e78fa) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x3e78fa > 0) {
            IERC20(HYBR)._0x1f9377(_0x8fa21b, _0x3e78fa);

            if(_0x0b9154 == 0){
                _0x15e62d(_0x3e78fa);
            } else{
                IVotingEscrow(_0x8fa21b)._0xc24414(_0x0b9154, _0x3e78fa);

                // Extend lock to maximum duration
                _0xa98711();
            }
        }
        _0x3b47ca += _0x3e78fa;
        emit PenaltyRewardReceived(_0x3e78fa);
    }

    /**
     * @notice Set the voter contract
     */
    function _0x1a7314(address _0xa9ff5a) external _0x687b6f {
        require(_0xa9ff5a != address(0), "Invalid voter");
        _0x0d9a5d = _0xa9ff5a;
        emit VoterSet(_0xa9ff5a);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x899991(uint256 _0xf33fa6) external _0x687b6f {
        require(_0xf33fa6 >= MIN_LOCK_PERIOD && _0xf33fa6 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0xf9e0a8 = _0x92309b;
        _0x92309b = _0xf33fa6;
        emit TransferLockPeriodUpdated(_0xf9e0a8, _0xf33fa6);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0xf3cc92(uint256 _0xcc1d3c) external _0x687b6f {
        require(_0xcc1d3c >= MIN_WITHDRAW_FEE && _0xcc1d3c <= MAX_WITHDRAW_FEE, "Invalid fee");
        if (1 == 1) { _0x0dc53f = _0xcc1d3c; }
    }

    function _0x15ff63(uint256 _0x572685) external _0x687b6f {
        if (true) { _0x50805a = _0x572685; }
    }

    function _0x9f86f8(uint256 _0x572685) external _0x687b6f {
        if (block.timestamp > 0) { _0x520a67 = _0x572685; }
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x3a1d40(address _0x6978fb) external _0x687b6f {
        require(_0x6978fb != address(0), "Invalid swapper");
        address _0x83877a = address(_0xb86365);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xb86365 = ISwapper(_0x6978fb); }
        emit SwapperUpdated(_0x83877a, _0x6978fb);
    }

    /**
     * @notice Set the team address
     */
    function _0xf0cc46(address _0x3d68b3) external _0x687b6f {
        require(_0x3d68b3 != address(0), "Invalid team");
        if (gasleft() > 0) { Team = _0x3d68b3; }
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x5816a3(address _0x706102) external _0x82cbfa {
        delete _0xd935b4[_0x706102];
        _0x9c7b96[_0x706102] = 0;
        emit EmergencyUnlock(_0x706102);
    }

    /**
     * @notice Get user's locks info
     */
    function _0xf385a9(address _0x706102) external view returns (UserLock[] memory) {
        return _0xd935b4[_0x706102];
    }

    /**
     * @notice Set operator address
     */
    function _0x29ed3d(address _0xe5ea76) external _0x687b6f {
        require(_0xe5ea76 != address(0), "Invalid operator");
        address _0xa46488 = _0x3eedd2;
        _0x3eedd2 = _0xe5ea76;
        emit OperatorUpdated(_0xa46488, _0xe5ea76);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0x1c9d63() external view returns (uint256) {
        if (_0x0b9154 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x7b4544 = IVotingEscrow(_0x8fa21b)._0x7b4544(_0x0b9154);
        return uint256(_0x7b4544._0x889b5a);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0xa98711() internal {
        if (_0x0b9154 == 0) return;

        IVotingEscrow.LockedBalance memory _0x7b4544 = IVotingEscrow(_0x8fa21b)._0x7b4544(_0x0b9154);
        if (_0x7b4544._0x18f600 || _0x7b4544._0x889b5a <= block.timestamp) return;

        uint256 _0xe7a0c9 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0xe7a0c9 > _0x7b4544._0x889b5a + 2 hours) {
            try IVotingEscrow(_0x8fa21b)._0xb3148e(_0x0b9154, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}