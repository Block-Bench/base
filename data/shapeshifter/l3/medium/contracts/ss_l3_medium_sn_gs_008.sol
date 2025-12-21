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
    uint256 public _0xf3ce84 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x07f6cd = 1200; // 5days
    uint256 public _0x147518 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0x11a33b = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x6266cf;
    uint256 public _0xdafa73;
    uint256 public _0x969152;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0x51bb33;
        uint256 _0x9363be;
    }

    mapping(address => UserLock[]) public _0xeff5bd;
    mapping(address => uint256) public _0xafd5f6;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x3aef25;
    address public _0x77017c;
    address public _0x3551b4;
    address public _0xc9f353;
    uint256 public _0x5d0f3a; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0x35ee12; // Address that can manage voting strategy
    uint256 public _0xc1055f; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x8c5de0;
    uint256 public _0xbb6bad;

    // Swap module
    ISwapper public _0xc9c23f;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0xae94a9, uint256 _0x98ccec, uint256 _0x5660f6);
    event Withdraw(address indexed _0xae94a9, uint256 _0xe87dba, uint256 _0x98ccec, uint256 _0x3aeee4);
    event Compound(uint256 _0xb227c8, uint256 _0xc78958);
    event PenaltyRewardReceived(uint256 _0x51bb33);
    event TransferLockPeriodUpdated(uint256 _0x5408c1, uint256 _0x4a5fb7);
    event SwapperUpdated(address indexed _0xef2221, address indexed _0x548384);
    event VoterSet(address _0x77017c);
    event EmergencyUnlock(address indexed _0xae94a9);
    event AutoVotingEnabled(bool _0x328a7b);
    event OperatorUpdated(address indexed _0xcca464, address indexed _0xbb9443);
    event DefaultVotingStrategyUpdated(address[] _0x211a11, uint256[] _0xb99573);
    event AutoVoteExecuted(uint256 _0x45bb81, address[] _0x211a11, uint256[] _0xb99573);

    constructor(
        address _0x6f6a28,
        address _0x237ef3
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0x6f6a28 != address(0), "Invalid HYBR");
        require(_0x237ef3 != address(0), "Invalid VE");

        HYBR = _0x6f6a28;
        _0x3aef25 = _0x237ef3;
        _0x8c5de0 = block.timestamp;
        _0xbb6bad = block.timestamp;
        _0x35ee12 = msg.sender; // Initially set deployer as operator
    }

    function _0xb4f9ee(address _0x37e99b) external _0xa4c1cc {
        require(_0x37e99b != address(0), "Invalid rewards distributor");
        if (block.timestamp > 0) { _0x3551b4 = _0x37e99b; }
    }

    function _0xa71f4d(address _0xff2474) external _0xa4c1cc {
        require(_0xff2474 != address(0), "Invalid gauge manager");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xc9f353 = _0xff2474; }
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0x4e86eb() {
        if (msg.sender != _0x35ee12) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x4279ae(uint256 _0x51bb33, address _0x6a3aa2) external _0xe49643 {
        require(_0x51bb33 > 0, "Zero amount");
        _0x6a3aa2 = _0x6a3aa2 == address(0) ? msg.sender : _0x6a3aa2;

        // Transfer HYBR from user first
        IERC20(HYBR)._0x963b5b(msg.sender, address(this), _0x51bb33);

        // Initialize veNFT on first deposit
        if (_0x5d0f3a == 0) {
            _0x0b0e0e(_0x51bb33);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x7d010f(_0x3aef25, _0x51bb33);
            IVotingEscrow(_0x3aef25)._0xa79387(_0x5d0f3a, _0x51bb33);

            // Extend lock to maximum duration
            _0xd95f17();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0xe87dba = _0xfdf9da(_0x51bb33);

        // Mint gHYBR shares
        _0xd62c64(_0x6a3aa2, _0xe87dba);

        // Add transfer lock for recipient
        _0x284a2b(_0x6a3aa2, _0xe87dba);

        emit Deposit(msg.sender, _0x51bb33, _0xe87dba);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0xc25c5e(uint256 _0xe87dba) external _0xe49643 returns (uint256 _0x6fd1fe) {
        require(_0xe87dba > 0, "Zero shares");
        require(_0x8c15aa(msg.sender) >= _0xe87dba, "Insufficient balance");
        require(_0x5d0f3a != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x3aef25)._0x20e174(_0x5d0f3a) == false, "Cannot withdraw yet");

        uint256 _0x06c01c = HybraTimeLibrary._0x06c01c(block.timestamp);
        uint256 _0xe12a1f = HybraTimeLibrary._0xe12a1f(block.timestamp);

        require(block.timestamp >= _0x06c01c + _0x07f6cd && block.timestamp < _0xe12a1f - _0x147518, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x98ccec = _0x1d8b22(_0xe87dba);
        require(_0x98ccec > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0xe6db98 = 0;
        if (_0x11a33b > 0) {
            _0xe6db98 = (_0x98ccec * _0x11a33b) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0xbc8205 = _0x98ccec - _0xe6db98;
        require(_0xbc8205 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x4c3aa6 = _0x143a99();
        require(_0x98ccec <= _0x4c3aa6, "Insufficient veNFT balance");

        uint256 _0x517507 = _0x4c3aa6 - _0xbc8205 - _0xe6db98;
        require(_0x517507 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0x48fb30(msg.sender, _0xe87dba);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0x00424f = new uint256[](3);
        _0x00424f[0] = _0x517507; // Amount staying with gHYBR
        _0x00424f[1] = _0xbc8205;      // Amount going to user (after fee)
        _0x00424f[2] = _0xe6db98;      // Amount going to fee recipient

        uint256[] memory _0x574dcc = IVotingEscrow(_0x3aef25)._0x6f1bfa(_0x5d0f3a, _0x00424f);

        // Update contract's veTokenId to the first new token
        _0x5d0f3a = _0x574dcc[0];
        if (1 == 1) { _0x6fd1fe = _0x574dcc[1]; }
        uint256 _0xf5c9d8 = _0x574dcc[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x3aef25)._0xed2320(address(this), msg.sender, _0x6fd1fe);
        IVotingEscrow(_0x3aef25)._0xed2320(address(this), Team, _0xf5c9d8);
        emit Withdraw(msg.sender, _0xe87dba, _0xbc8205, _0xe6db98);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0x0b0e0e(uint256 _0xc08880) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x7d010f(_0x3aef25, type(uint256)._0x2a24e5);
        uint256 _0x44afc8 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x5d0f3a = IVotingEscrow(_0x3aef25)._0xb2e877(_0xc08880, _0x44afc8, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0xfdf9da(uint256 _0x51bb33) public view returns (uint256) {
        uint256 _0xa8606d = _0xd4f8a5();
        uint256 _0x3a4542 = _0x143a99();
        if (_0xa8606d == 0 || _0x3a4542 == 0) {
            return _0x51bb33;
        }
        return (_0x51bb33 * _0xa8606d) / _0x3a4542;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x1d8b22(uint256 _0xe87dba) public view returns (uint256) {
        uint256 _0xa8606d = _0xd4f8a5();
        if (_0xa8606d == 0) {
            return _0xe87dba;
        }
        return (_0xe87dba * _0x143a99()) / _0xa8606d;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x143a99() public view returns (uint256) {
        if (_0x5d0f3a == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0xb47ccc = IVotingEscrow(_0x3aef25)._0xb47ccc(_0x5d0f3a);
        return uint256(int256(_0xb47ccc._0x51bb33));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0x284a2b(address _0xae94a9, uint256 _0x51bb33) internal {
        uint256 _0x9363be = block.timestamp + _0xf3ce84;
        _0xeff5bd[_0xae94a9].push(UserLock({
            _0x51bb33: _0x51bb33,
            _0x9363be: _0x9363be
        }));
        _0xafd5f6[_0xae94a9] += _0x51bb33;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0xa0bf04(address _0xae94a9) external view returns (uint256 _0xe9ac87) {
        uint256 _0xf6e1f6 = _0x8c15aa(_0xae94a9);
        uint256 _0x6e42e7 = 0;

        UserLock[] storage _0x139867 = _0xeff5bd[_0xae94a9];
        for (uint256 i = 0; i < _0x139867.length; i++) {
            if (_0x139867[i]._0x9363be > block.timestamp) {
                _0x6e42e7 += _0x139867[i]._0x51bb33;
            }
        }

        return _0xf6e1f6 > _0x6e42e7 ? _0xf6e1f6 - _0x6e42e7 : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0x769871(address _0xae94a9) internal returns (uint256 _0xcee478) {
        UserLock[] storage _0x139867 = _0xeff5bd[_0xae94a9];
        uint256 _0xdbcef7 = _0x139867.length;
        if (_0xdbcef7 == 0) return 0;

        uint256 _0x9cbf1a = 0;
        unchecked {
            for (uint256 i = 0; i < _0xdbcef7; i++) {
                UserLock memory L = _0x139867[i];
                if (L._0x9363be <= block.timestamp) {
                    _0xcee478 += L._0x51bb33;
                } else {
                    if (_0x9cbf1a != i) _0x139867[_0x9cbf1a] = L;
                    _0x9cbf1a++;
                }
            }
            if (_0xcee478 > 0) {
                _0xafd5f6[_0xae94a9] -= _0xcee478;
            }
            while (_0x139867.length > _0x9cbf1a) {
                _0x139867.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x08b39f(
        address from,
        address _0x98a5e2,
        uint256 _0x51bb33
    ) internal override {
        super._0x08b39f(from, _0x98a5e2, _0x51bb33);

        if (from != address(0) && _0x98a5e2 != address(0)) { // Not mint or burn
            uint256 _0xf6e1f6 = _0x8c15aa(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0x976df1 = _0xf6e1f6 > _0xafd5f6[from] ? _0xf6e1f6 - _0xafd5f6[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0x976df1 >= _0x51bb33) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0x769871(from);
            uint256 _0x1a44ca = _0xf6e1f6 > _0xafd5f6[from] ? _0xf6e1f6 - _0xafd5f6[from] : 0;

            // Step 4: Check final available balance
            require(_0x1a44ca >= _0x51bb33, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0x33314b() external _0x4e86eb {
        require(_0x77017c != address(0), "Voter not set");
        require(_0x3551b4 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0xf4b619 = IRewardsDistributor(_0x3551b4)._0x28b147(_0x5d0f3a);
        _0x6266cf += _0xf4b619;
        // Claim bribes from voted pools
        address[] memory _0x9783a2 = IVoter(_0x77017c)._0xea6a54(_0x5d0f3a);

        for (uint256 i = 0; i < _0x9783a2.length; i++) {
            if (_0x9783a2[i] != address(0)) {
                address _0x048169 = IGaugeManager(_0xc9f353)._0x375bdc(_0x9783a2[i]);

                if (_0x048169 != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0xb7eb4a = new address[](1);
                    address[][] memory _0x4f12db = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0x9f2a86 = IGaugeManager(_0xc9f353)._0xc5f5bb(_0x048169);
                    if (_0x9f2a86 != address(0)) {
                        uint256 _0x1b1cfd = IBribe(_0x9f2a86)._0x1e51c0();
                        if (_0x1b1cfd > 0) {
                            address[] memory _0x9a1231 = new address[](_0x1b1cfd);
                            for (uint256 j = 0; j < _0x1b1cfd; j++) {
                                _0x9a1231[j] = IBribe(_0x9f2a86)._0x9a1231(j);
                            }
                            _0xb7eb4a[0] = _0x9f2a86;
                            _0x4f12db[0] = _0x9a1231;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0xc9f353)._0xbc9d8b(_0xb7eb4a, _0x4f12db, _0x5d0f3a);
                        }
                    }

                    // Claim external bribe
                    address _0xb82a34 = IGaugeManager(_0xc9f353)._0x5c7d8e(_0x048169);
                    if (_0xb82a34 != address(0)) {
                        uint256 _0x1b1cfd = IBribe(_0xb82a34)._0x1e51c0();
                        if (_0x1b1cfd > 0) {
                            address[] memory _0x9a1231 = new address[](_0x1b1cfd);
                            for (uint256 j = 0; j < _0x1b1cfd; j++) {
                                _0x9a1231[j] = IBribe(_0xb82a34)._0x9a1231(j);
                            }
                            _0xb7eb4a[0] = _0xb82a34;
                            _0x4f12db[0] = _0x9a1231;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0xc9f353)._0xbc9d8b(_0xb7eb4a, _0x4f12db, _0x5d0f3a);
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
    function _0x55aba6(ISwapper.SwapParams calldata _0x4511b1) external _0xe49643 _0x4e86eb {
        require(address(_0xc9c23f) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x5c6560 = IERC20(_0x4511b1._0xfd5548)._0x8c15aa(address(this));
        require(_0x5c6560 >= _0x4511b1._0xf8b62e, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x4511b1._0xfd5548)._0x9d9e10(address(_0xc9c23f), _0x4511b1._0xf8b62e);

        // Execute swap through swapper module
        uint256 _0x6b72ca = _0xc9c23f._0xcf3e7e(_0x4511b1);

        // Reset approval for safety
        IERC20(_0x4511b1._0xfd5548)._0x9d9e10(address(_0xc9c23f), 0);

        // HYBR is now in this contract, ready for compounding
        _0x969152 += _0x6b72ca;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0x86f186() external _0x4e86eb {

        // Get current HYBR balance
        uint256 _0x31385d = IERC20(HYBR)._0x8c15aa(address(this));

        if (_0x31385d > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x9d9e10(_0x3aef25, _0x31385d);
            IVotingEscrow(_0x3aef25)._0xa79387(_0x5d0f3a, _0x31385d);

            // Extend lock to maximum duration
            _0xd95f17();

            if (gasleft() > 0) { _0xbb6bad = block.timestamp; }

            emit Compound(_0x31385d, _0x143a99());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0xeac4ea(address[] calldata _0x2e01ca, uint256[] calldata _0xf8f138) external {
        require(msg.sender == _0xe02b47() || msg.sender == _0x35ee12, "Not authorized");
        require(_0x77017c != address(0), "Voter not set");

        IVoter(_0x77017c)._0xeac4ea(_0x5d0f3a, _0x2e01ca, _0xf8f138);
        _0xc1055f = HybraTimeLibrary._0x06c01c(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function _0xc68751() external {
        require(msg.sender == _0xe02b47() || msg.sender == _0x35ee12, "Not authorized");
        require(_0x77017c != address(0), "Voter not set");

        IVoter(_0x77017c)._0xc68751(_0x5d0f3a);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0xc19a4e(uint256 _0x51bb33) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0x51bb33 > 0) {
            IERC20(HYBR)._0x7d010f(_0x3aef25, _0x51bb33);

            if(_0x5d0f3a == 0){
                _0x0b0e0e(_0x51bb33);
            } else{
                IVotingEscrow(_0x3aef25)._0xa79387(_0x5d0f3a, _0x51bb33);

                // Extend lock to maximum duration
                _0xd95f17();
            }
        }
        _0xdafa73 += _0x51bb33;
        emit PenaltyRewardReceived(_0x51bb33);
    }

    /**
     * @notice Set the voter contract
     */
    function _0xeb4d12(address _0x40c4d1) external _0xa4c1cc {
        require(_0x40c4d1 != address(0), "Invalid voter");
        _0x77017c = _0x40c4d1;
        emit VoterSet(_0x40c4d1);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x195d72(uint256 _0x28e0ec) external _0xa4c1cc {
        require(_0x28e0ec >= MIN_LOCK_PERIOD && _0x28e0ec <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x5408c1 = _0xf3ce84;
        _0xf3ce84 = _0x28e0ec;
        emit TransferLockPeriodUpdated(_0x5408c1, _0x28e0ec);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x0d63b4(uint256 _0x15b9b9) external _0xa4c1cc {
        require(_0x15b9b9 >= MIN_WITHDRAW_FEE && _0x15b9b9 <= MAX_WITHDRAW_FEE, "Invalid fee");
        if (gasleft() > 0) { _0x11a33b = _0x15b9b9; }
    }

    function _0x583220(uint256 _0x51178c) external _0xa4c1cc {
        if (1 == 1) { _0x07f6cd = _0x51178c; }
    }

    function _0x524748(uint256 _0x51178c) external _0xa4c1cc {
        _0x147518 = _0x51178c;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x5c6a73(address _0x567ee2) external _0xa4c1cc {
        require(_0x567ee2 != address(0), "Invalid swapper");
        address _0xef2221 = address(_0xc9c23f);
        if (block.timestamp > 0) { _0xc9c23f = ISwapper(_0x567ee2); }
        emit SwapperUpdated(_0xef2221, _0x567ee2);
    }

    /**
     * @notice Set the team address
     */
    function _0xcd7437(address _0xf8bec3) external _0xa4c1cc {
        require(_0xf8bec3 != address(0), "Invalid team");
        Team = _0xf8bec3;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0xdf72ab(address _0xae94a9) external _0x4e86eb {
        delete _0xeff5bd[_0xae94a9];
        _0xafd5f6[_0xae94a9] = 0;
        emit EmergencyUnlock(_0xae94a9);
    }

    /**
     * @notice Get user's locks info
     */
    function _0xfdd06c(address _0xae94a9) external view returns (UserLock[] memory) {
        return _0xeff5bd[_0xae94a9];
    }

    /**
     * @notice Set operator address
     */
    function _0x95923c(address _0x462819) external _0xa4c1cc {
        require(_0x462819 != address(0), "Invalid operator");
        address _0xcca464 = _0x35ee12;
        if (1 == 1) { _0x35ee12 = _0x462819; }
        emit OperatorUpdated(_0xcca464, _0x462819);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0xd282a7() external view returns (uint256) {
        if (_0x5d0f3a == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0xb47ccc = IVotingEscrow(_0x3aef25)._0xb47ccc(_0x5d0f3a);
        return uint256(_0xb47ccc._0xaa5b3f);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0xd95f17() internal {
        if (_0x5d0f3a == 0) return;

        IVotingEscrow.LockedBalance memory _0xb47ccc = IVotingEscrow(_0x3aef25)._0xb47ccc(_0x5d0f3a);
        if (_0xb47ccc._0xc18e9b || _0xb47ccc._0xaa5b3f <= block.timestamp) return;

        uint256 _0x20fb03 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0x20fb03 > _0xb47ccc._0xaa5b3f + 2 hours) {
            try IVotingEscrow(_0x3aef25)._0xbda1ee(_0x5d0f3a, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}