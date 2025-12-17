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
    uint256 public _0x896d61 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0xafe2e7 = 1200; // 5days
    uint256 public _0x469e24 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0xef6dd5 = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0xc3c335;
    uint256 public _0xa17052;
    uint256 public _0x13b475;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x9d7941;
        uint256 _0xed88a6;
    }

    mapping(address => UserLock[]) public _0x589d57;
    mapping(address => uint256) public _0xfd6c74;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x876420;
    address public _0x8cf035;
    address public _0xdf3040;
    address public _0xab0b76;
    uint256 public _0x26eb90; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0x6bc69b; // Address that can manage voting strategy
    uint256 public _0x981cfe; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x9b15a4;
    uint256 public _0x8a8ab8;

    // Swap module
    ISwapper public _0xcc1560;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0x8f6438, uint256 _0x0f531d, uint256 _0xf6a9e8);
    event Withdraw(address indexed _0x8f6438, uint256 _0xc60cef, uint256 _0x0f531d, uint256 _0x808947);
    event Compound(uint256 _0x59b725, uint256 _0x3dda35);
    event PenaltyRewardReceived(uint256 _0x9d7941);
    event TransferLockPeriodUpdated(uint256 _0x96ed26, uint256 _0x0d2096);
    event SwapperUpdated(address indexed _0xf4dfec, address indexed _0xc7ef1b);
    event VoterSet(address _0x8cf035);
    event EmergencyUnlock(address indexed _0x8f6438);
    event AutoVotingEnabled(bool _0x7fe8f2);
    event OperatorUpdated(address indexed _0x3f1d81, address indexed _0xc7e162);
    event DefaultVotingStrategyUpdated(address[] _0x716516, uint256[] _0x874246);
    event AutoVoteExecuted(uint256 _0x9bc303, address[] _0x716516, uint256[] _0x874246);

    constructor(
        address _0xf51267,
        address _0xb3c4f7
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xf51267 != address(0), "Invalid HYBR");
        require(_0xb3c4f7 != address(0), "Invalid VE");

        HYBR = _0xf51267;
        _0x876420 = _0xb3c4f7;
        _0x9b15a4 = block.timestamp;
        _0x8a8ab8 = block.timestamp;
        _0x6bc69b = msg.sender; // Initially set deployer as operator
    }

    function _0x35359b(address _0xc38516) external _0x92cc6e {
        require(_0xc38516 != address(0), "Invalid rewards distributor");
        _0xdf3040 = _0xc38516;
    }

    function _0xfbadde(address _0x692940) external _0x92cc6e {
        require(_0x692940 != address(0), "Invalid gauge manager");
        _0xab0b76 = _0x692940;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0xc38ce8() {
        if (msg.sender != _0x6bc69b) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x3f0033(uint256 _0x9d7941, address _0x6c2c37) external _0xe6a668 {
        require(_0x9d7941 > 0, "Zero amount");
        _0x6c2c37 = _0x6c2c37 == address(0) ? msg.sender : _0x6c2c37;

        // Transfer HYBR from user first
        IERC20(HYBR)._0xe9b6dc(msg.sender, address(this), _0x9d7941);

        // Initialize veNFT on first deposit
        if (_0x26eb90 == 0) {
            _0x4011c6(_0x9d7941);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0xa7770b(_0x876420, _0x9d7941);
            IVotingEscrow(_0x876420)._0x9cbd13(_0x26eb90, _0x9d7941);

            // Extend lock to maximum duration
            _0xd565bf();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0xc60cef = _0xafb309(_0x9d7941);

        // Mint gHYBR shares
        _0x404ec1(_0x6c2c37, _0xc60cef);

        // Add transfer lock for recipient
        _0xba2be1(_0x6c2c37, _0xc60cef);

        emit Deposit(msg.sender, _0x9d7941, _0xc60cef);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0x178f1d(uint256 _0xc60cef) external _0xe6a668 returns (uint256 _0xb12741) {
        require(_0xc60cef > 0, "Zero shares");
        require(_0x3a6d79(msg.sender) >= _0xc60cef, "Insufficient balance");
        require(_0x26eb90 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x876420)._0xc25d10(_0x26eb90) == false, "Cannot withdraw yet");

        uint256 _0x99616b = HybraTimeLibrary._0x99616b(block.timestamp);
        uint256 _0x3c729a = HybraTimeLibrary._0x3c729a(block.timestamp);

        require(block.timestamp >= _0x99616b + _0xafe2e7 && block.timestamp < _0x3c729a - _0x469e24, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x0f531d = _0x5e453b(_0xc60cef);
        require(_0x0f531d > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0x11323e = 0;
        if (_0xef6dd5 > 0) {
            _0x11323e = (_0x0f531d * _0xef6dd5) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0x89166a = _0x0f531d - _0x11323e;
        require(_0x89166a > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x7e8925 = _0x7acd1f();
        require(_0x0f531d <= _0x7e8925, "Insufficient veNFT balance");

        uint256 _0x384ac4 = _0x7e8925 - _0x89166a - _0x11323e;
        require(_0x384ac4 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x6dc4c2(msg.sender, _0xc60cef);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0x9994a3 = new uint256[](3);
        _0x9994a3[0] = _0x384ac4; // Amount staying with gHYBR
        _0x9994a3[1] = _0x89166a;      // Amount going to user (after fee)
        _0x9994a3[2] = _0x11323e;      // Amount going to fee recipient

        uint256[] memory _0xeeb293 = IVotingEscrow(_0x876420)._0x546e37(_0x26eb90, _0x9994a3);

        // Update contract's veTokenId to the first new token
        _0x26eb90 = _0xeeb293[0];
        _0xb12741 = _0xeeb293[1];
        uint256 _0xda55b4 = _0xeeb293[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x876420)._0x23bf9a(address(this), msg.sender, _0xb12741);
        IVotingEscrow(_0x876420)._0x23bf9a(address(this), Team, _0xda55b4);
        emit Withdraw(msg.sender, _0xc60cef, _0x89166a, _0x11323e);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0x4011c6(uint256 _0xb55b53) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0xa7770b(_0x876420, type(uint256)._0x6e001f);
        uint256 _0x3b0dc6 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x26eb90 = IVotingEscrow(_0x876420)._0x17e7b3(_0xb55b53, _0x3b0dc6, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0xafb309(uint256 _0x9d7941) public view returns (uint256) {
        uint256 _0x3e20c3 = _0x4b258c();
        uint256 _0x4e726c = _0x7acd1f();
        if (_0x3e20c3 == 0 || _0x4e726c == 0) {
            return _0x9d7941;
        }
        return (_0x9d7941 * _0x3e20c3) / _0x4e726c;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x5e453b(uint256 _0xc60cef) public view returns (uint256) {
        uint256 _0x3e20c3 = _0x4b258c();
        if (_0x3e20c3 == 0) {
            return _0xc60cef;
        }
        return (_0xc60cef * _0x7acd1f()) / _0x3e20c3;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x7acd1f() public view returns (uint256) {
        if (_0x26eb90 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0xe35423 = IVotingEscrow(_0x876420)._0xe35423(_0x26eb90);
        return uint256(int256(_0xe35423._0x9d7941));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0xba2be1(address _0x8f6438, uint256 _0x9d7941) internal {
        uint256 _0xed88a6 = block.timestamp + _0x896d61;
        _0x589d57[_0x8f6438].push(UserLock({
            _0x9d7941: _0x9d7941,
            _0xed88a6: _0xed88a6
        }));
        _0xfd6c74[_0x8f6438] += _0x9d7941;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x5bfb61(address _0x8f6438) external view returns (uint256 _0x74a013) {
        uint256 _0x439c16 = _0x3a6d79(_0x8f6438);
        uint256 _0x6202a4 = 0;

        UserLock[] storage _0xd429db = _0x589d57[_0x8f6438];
        for (uint256 i = 0; i < _0xd429db.length; i++) {
            if (_0xd429db[i]._0xed88a6 > block.timestamp) {
                _0x6202a4 += _0xd429db[i]._0x9d7941;
            }
        }

        return _0x439c16 > _0x6202a4 ? _0x439c16 - _0x6202a4 : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xda306e(address _0x8f6438) internal returns (uint256 _0x7e85da) {
        UserLock[] storage _0xd429db = _0x589d57[_0x8f6438];
        uint256 _0xdce897 = _0xd429db.length;
        if (_0xdce897 == 0) return 0;

        uint256 _0x03e8ab = 0;
        unchecked {
            for (uint256 i = 0; i < _0xdce897; i++) {
                UserLock memory L = _0xd429db[i];
                if (L._0xed88a6 <= block.timestamp) {
                    _0x7e85da += L._0x9d7941;
                } else {
                    if (_0x03e8ab != i) _0xd429db[_0x03e8ab] = L;
                    _0x03e8ab++;
                }
            }
            if (_0x7e85da > 0) {
                _0xfd6c74[_0x8f6438] -= _0x7e85da;
            }
            while (_0xd429db.length > _0x03e8ab) {
                _0xd429db.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x5fcdea(
        address from,
        address _0xefb685,
        uint256 _0x9d7941
    ) internal override {
        super._0x5fcdea(from, _0xefb685, _0x9d7941);

        if (from != address(0) && _0xefb685 != address(0)) { // Not mint or burn
            uint256 _0x439c16 = _0x3a6d79(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0x377fec = _0x439c16 > _0xfd6c74[from] ? _0x439c16 - _0xfd6c74[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0x377fec >= _0x9d7941) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xda306e(from);
            uint256 _0xbae5d4 = _0x439c16 > _0xfd6c74[from] ? _0x439c16 - _0xfd6c74[from] : 0;

            // Step 4: Check final available balance
            require(_0xbae5d4 >= _0x9d7941, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0xdea582() external _0xc38ce8 {
        require(_0x8cf035 != address(0), "Voter not set");
        require(_0xdf3040 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x7c0aba = IRewardsDistributor(_0xdf3040)._0x60639c(_0x26eb90);
        _0xc3c335 += _0x7c0aba;
        // Claim bribes from voted pools
        address[] memory _0x902e8f = IVoter(_0x8cf035)._0xe62bb4(_0x26eb90);

        for (uint256 i = 0; i < _0x902e8f.length; i++) {
            if (_0x902e8f[i] != address(0)) {
                address _0x99c6a4 = IGaugeManager(_0xab0b76)._0x433e8c(_0x902e8f[i]);

                if (_0x99c6a4 != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0x403c24 = new address[](1);
                    address[][] memory _0x506867 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0xf2d61e = IGaugeManager(_0xab0b76)._0x8705fb(_0x99c6a4);
                    if (_0xf2d61e != address(0)) {
                        uint256 _0x0d7a3a = IBribe(_0xf2d61e)._0xf2327a();
                        if (_0x0d7a3a > 0) {
                            address[] memory _0x2b6c81 = new address[](_0x0d7a3a);
                            for (uint256 j = 0; j < _0x0d7a3a; j++) {
                                _0x2b6c81[j] = IBribe(_0xf2d61e)._0x2b6c81(j);
                            }
                            _0x403c24[0] = _0xf2d61e;
                            _0x506867[0] = _0x2b6c81;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0xab0b76)._0x4d3830(_0x403c24, _0x506867, _0x26eb90);
                        }
                    }

                    // Claim external bribe
                    address _0x461f97 = IGaugeManager(_0xab0b76)._0xccf906(_0x99c6a4);
                    if (_0x461f97 != address(0)) {
                        uint256 _0x0d7a3a = IBribe(_0x461f97)._0xf2327a();
                        if (_0x0d7a3a > 0) {
                            address[] memory _0x2b6c81 = new address[](_0x0d7a3a);
                            for (uint256 j = 0; j < _0x0d7a3a; j++) {
                                _0x2b6c81[j] = IBribe(_0x461f97)._0x2b6c81(j);
                            }
                            _0x403c24[0] = _0x461f97;
                            _0x506867[0] = _0x2b6c81;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0xab0b76)._0x4d3830(_0x403c24, _0x506867, _0x26eb90);
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
    function _0x099db4(ISwapper.SwapParams calldata _0xeffda0) external _0xe6a668 _0xc38ce8 {
        require(address(_0xcc1560) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x5e4a25 = IERC20(_0xeffda0._0xf43233)._0x3a6d79(address(this));
        require(_0x5e4a25 >= _0xeffda0._0x790e7e, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0xeffda0._0xf43233)._0x6e7eb1(address(_0xcc1560), _0xeffda0._0x790e7e);

        // Execute swap through swapper module
        uint256 _0xe2774e = _0xcc1560._0x17d4f4(_0xeffda0);

        // Reset approval for safety
        IERC20(_0xeffda0._0xf43233)._0x6e7eb1(address(_0xcc1560), 0);

        // HYBR is now in this contract, ready for compounding
        _0x13b475 += _0xe2774e;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0xd10886() external _0xc38ce8 {

        // Get current HYBR balance
        uint256 _0x1956f9 = IERC20(HYBR)._0x3a6d79(address(this));

        if (_0x1956f9 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x6e7eb1(_0x876420, _0x1956f9);
            IVotingEscrow(_0x876420)._0x9cbd13(_0x26eb90, _0x1956f9);

            // Extend lock to maximum duration
            _0xd565bf();

            _0x8a8ab8 = block.timestamp;

            emit Compound(_0x1956f9, _0x7acd1f());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0xbcf658(address[] calldata _0x7ea76c, uint256[] calldata _0xd3c00e) external {
        require(msg.sender == _0xe98e42() || msg.sender == _0x6bc69b, "Not authorized");
        require(_0x8cf035 != address(0), "Voter not set");

        IVoter(_0x8cf035)._0xbcf658(_0x26eb90, _0x7ea76c, _0xd3c00e);
        _0x981cfe = HybraTimeLibrary._0x99616b(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function _0x74f8af() external {
        require(msg.sender == _0xe98e42() || msg.sender == _0x6bc69b, "Not authorized");
        require(_0x8cf035 != address(0), "Voter not set");

        IVoter(_0x8cf035)._0x74f8af(_0x26eb90);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0xf4a64a(uint256 _0x9d7941) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x9d7941 > 0) {
            IERC20(HYBR)._0xa7770b(_0x876420, _0x9d7941);

            if(_0x26eb90 == 0){
                _0x4011c6(_0x9d7941);
            } else{
                IVotingEscrow(_0x876420)._0x9cbd13(_0x26eb90, _0x9d7941);

                // Extend lock to maximum duration
                _0xd565bf();
            }
        }
        _0xa17052 += _0x9d7941;
        emit PenaltyRewardReceived(_0x9d7941);
    }

    /**
     * @notice Set the voter contract
     */
    function _0x3ee376(address _0x6371cc) external _0x92cc6e {
        require(_0x6371cc != address(0), "Invalid voter");
        _0x8cf035 = _0x6371cc;
        emit VoterSet(_0x6371cc);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0xfbd70a(uint256 _0x401e9e) external _0x92cc6e {
        require(_0x401e9e >= MIN_LOCK_PERIOD && _0x401e9e <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x96ed26 = _0x896d61;
        _0x896d61 = _0x401e9e;
        emit TransferLockPeriodUpdated(_0x96ed26, _0x401e9e);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0xf7df47(uint256 _0x8f3bb2) external _0x92cc6e {
        require(_0x8f3bb2 >= MIN_WITHDRAW_FEE && _0x8f3bb2 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0xef6dd5 = _0x8f3bb2;
    }

    function _0x8795f8(uint256 _0x1d0043) external _0x92cc6e {
        _0xafe2e7 = _0x1d0043;
    }

    function _0xe4622a(uint256 _0x1d0043) external _0x92cc6e {
        _0x469e24 = _0x1d0043;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x2d51ae(address _0xea20e2) external _0x92cc6e {
        require(_0xea20e2 != address(0), "Invalid swapper");
        address _0xf4dfec = address(_0xcc1560);
        _0xcc1560 = ISwapper(_0xea20e2);
        emit SwapperUpdated(_0xf4dfec, _0xea20e2);
    }

    /**
     * @notice Set the team address
     */
    function _0x75c5d7(address _0xd1d947) external _0x92cc6e {
        require(_0xd1d947 != address(0), "Invalid team");
        Team = _0xd1d947;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x0e8156(address _0x8f6438) external _0xc38ce8 {
        delete _0x589d57[_0x8f6438];
        _0xfd6c74[_0x8f6438] = 0;
        emit EmergencyUnlock(_0x8f6438);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x2cb4d0(address _0x8f6438) external view returns (UserLock[] memory) {
        return _0x589d57[_0x8f6438];
    }

    /**
     * @notice Set operator address
     */
    function _0xa34313(address _0x9ac460) external _0x92cc6e {
        require(_0x9ac460 != address(0), "Invalid operator");
        address _0x3f1d81 = _0x6bc69b;
        _0x6bc69b = _0x9ac460;
        emit OperatorUpdated(_0x3f1d81, _0x9ac460);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0x841920() external view returns (uint256) {
        if (_0x26eb90 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0xe35423 = IVotingEscrow(_0x876420)._0xe35423(_0x26eb90);
        return uint256(_0xe35423._0x71bf9e);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0xd565bf() internal {
        if (_0x26eb90 == 0) return;

        IVotingEscrow.LockedBalance memory _0xe35423 = IVotingEscrow(_0x876420)._0xe35423(_0x26eb90);
        if (_0xe35423._0x3aeeab || _0xe35423._0x71bf9e <= block.timestamp) return;

        uint256 _0x964768 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0x964768 > _0xe35423._0x71bf9e + 2 hours) {
            try IVotingEscrow(_0x876420)._0xe8c4b1(_0x26eb90, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}