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
    uint256 public _0xe0eef7 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x220a62 = 1200; // 5days
    uint256 public _0x0de0a1 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0xc2c2ac = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x14b0c0;
    uint256 public _0x5f49b2;
    uint256 public _0xe4ece7;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0xff82c9;
        uint256 _0xf23477;
    }

    mapping(address => UserLock[]) public _0xab9311;
    mapping(address => uint256) public _0x4a3a45;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x58d027;
    address public _0x4f9b99;
    address public _0x718751;
    address public _0x1569db;
    uint256 public _0xad72c4; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0xc4e758; // Address that can manage voting strategy
    uint256 public _0xc33e8b; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x04fdae;
    uint256 public _0x082728;

    // Swap module
    ISwapper public _0xa7566b;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0x08bb5b, uint256 _0xc3f280, uint256 _0xcc5ce1);
    event Withdraw(address indexed _0x08bb5b, uint256 _0xe9fdd8, uint256 _0xc3f280, uint256 _0x3b28cc);
    event Compound(uint256 _0x948c6d, uint256 _0x6cea88);
    event PenaltyRewardReceived(uint256 _0xff82c9);
    event TransferLockPeriodUpdated(uint256 _0x8a3880, uint256 _0x63965e);
    event SwapperUpdated(address indexed _0x1cc1a7, address indexed _0x39351b);
    event VoterSet(address _0x4f9b99);
    event EmergencyUnlock(address indexed _0x08bb5b);
    event AutoVotingEnabled(bool _0xad8fb7);
    event OperatorUpdated(address indexed _0x6734af, address indexed _0x04d483);
    event DefaultVotingStrategyUpdated(address[] _0x126c3e, uint256[] _0xe05eee);
    event AutoVoteExecuted(uint256 _0xa6a6ac, address[] _0x126c3e, uint256[] _0xe05eee);

    constructor(
        address _0x946451,
        address _0xa548a2
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0x946451 != address(0), "Invalid HYBR");
        require(_0xa548a2 != address(0), "Invalid VE");

        HYBR = _0x946451;
        _0x58d027 = _0xa548a2;
        _0x04fdae = block.timestamp;
        _0x082728 = block.timestamp;
        _0xc4e758 = msg.sender; // Initially set deployer as operator
    }

    function _0x1042d0(address _0x321c05) external _0x00e107 {
        require(_0x321c05 != address(0), "Invalid rewards distributor");
        if (gasleft() > 0) { _0x718751 = _0x321c05; }
    }

    function _0x565c1a(address _0x5c0b7d) external _0x00e107 {
        require(_0x5c0b7d != address(0), "Invalid gauge manager");
        if (gasleft() > 0) { _0x1569db = _0x5c0b7d; }
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0x9b489e() {
        if (msg.sender != _0xc4e758) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0xcd7c26(uint256 _0xff82c9, address _0x2056ce) external _0x52335a {
        require(_0xff82c9 > 0, "Zero amount");
        _0x2056ce = _0x2056ce == address(0) ? msg.sender : _0x2056ce;

        // Transfer HYBR from user first
        IERC20(HYBR)._0x324ea5(msg.sender, address(this), _0xff82c9);

        // Initialize veNFT on first deposit
        if (_0xad72c4 == 0) {
            _0xe604e1(_0xff82c9);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0xe03fed(_0x58d027, _0xff82c9);
            IVotingEscrow(_0x58d027)._0xdac168(_0xad72c4, _0xff82c9);

            // Extend lock to maximum duration
            _0x7dbf21();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0xe9fdd8 = _0xfe91e2(_0xff82c9);

        // Mint gHYBR shares
        _0xa22fd6(_0x2056ce, _0xe9fdd8);

        // Add transfer lock for recipient
        _0x2f5716(_0x2056ce, _0xe9fdd8);

        emit Deposit(msg.sender, _0xff82c9, _0xe9fdd8);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0x8f2ceb(uint256 _0xe9fdd8) external _0x52335a returns (uint256 _0xa1215c) {
        require(_0xe9fdd8 > 0, "Zero shares");
        require(_0x857aeb(msg.sender) >= _0xe9fdd8, "Insufficient balance");
        require(_0xad72c4 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x58d027)._0x16ad4d(_0xad72c4) == false, "Cannot withdraw yet");

        uint256 _0x89411a = HybraTimeLibrary._0x89411a(block.timestamp);
        uint256 _0x098e4f = HybraTimeLibrary._0x098e4f(block.timestamp);

        require(block.timestamp >= _0x89411a + _0x220a62 && block.timestamp < _0x098e4f - _0x0de0a1, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0xc3f280 = _0x8574ef(_0xe9fdd8);
        require(_0xc3f280 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0xfb503e = 0;
        if (_0xc2c2ac > 0) {
            _0xfb503e = (_0xc3f280 * _0xc2c2ac) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0xd6abea = _0xc3f280 - _0xfb503e;
        require(_0xd6abea > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x1fd3ec = _0x457b1a();
        require(_0xc3f280 <= _0x1fd3ec, "Insufficient veNFT balance");

        uint256 _0xea77e2 = _0x1fd3ec - _0xd6abea - _0xfb503e;
        require(_0xea77e2 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0xa55b13(msg.sender, _0xe9fdd8);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0x68fb10 = new uint256[](3);
        _0x68fb10[0] = _0xea77e2; // Amount staying with gHYBR
        _0x68fb10[1] = _0xd6abea;      // Amount going to user (after fee)
        _0x68fb10[2] = _0xfb503e;      // Amount going to fee recipient

        uint256[] memory _0x8b1c51 = IVotingEscrow(_0x58d027)._0xf871b6(_0xad72c4, _0x68fb10);

        // Update contract's veTokenId to the first new token
        _0xad72c4 = _0x8b1c51[0];
        _0xa1215c = _0x8b1c51[1];
        uint256 _0x3d99e1 = _0x8b1c51[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x58d027)._0xeb4b6e(address(this), msg.sender, _0xa1215c);
        IVotingEscrow(_0x58d027)._0xeb4b6e(address(this), Team, _0x3d99e1);
        emit Withdraw(msg.sender, _0xe9fdd8, _0xd6abea, _0xfb503e);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0xe604e1(uint256 _0x0dcf1c) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0xe03fed(_0x58d027, type(uint256)._0x461195);
        uint256 _0xd041d6 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0xad72c4 = IVotingEscrow(_0x58d027)._0xa35319(_0x0dcf1c, _0xd041d6, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0xfe91e2(uint256 _0xff82c9) public view returns (uint256) {
        uint256 _0x89fa13 = _0x697d50();
        uint256 _0xb83531 = _0x457b1a();
        if (_0x89fa13 == 0 || _0xb83531 == 0) {
            return _0xff82c9;
        }
        return (_0xff82c9 * _0x89fa13) / _0xb83531;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x8574ef(uint256 _0xe9fdd8) public view returns (uint256) {
        uint256 _0x89fa13 = _0x697d50();
        if (_0x89fa13 == 0) {
            return _0xe9fdd8;
        }
        return (_0xe9fdd8 * _0x457b1a()) / _0x89fa13;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x457b1a() public view returns (uint256) {
        if (_0xad72c4 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0x037e61 = IVotingEscrow(_0x58d027)._0x037e61(_0xad72c4);
        return uint256(int256(_0x037e61._0xff82c9));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0x2f5716(address _0x08bb5b, uint256 _0xff82c9) internal {
        uint256 _0xf23477 = block.timestamp + _0xe0eef7;
        _0xab9311[_0x08bb5b].push(UserLock({
            _0xff82c9: _0xff82c9,
            _0xf23477: _0xf23477
        }));
        _0x4a3a45[_0x08bb5b] += _0xff82c9;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x551e29(address _0x08bb5b) external view returns (uint256 _0xb02078) {
        uint256 _0x227d88 = _0x857aeb(_0x08bb5b);
        uint256 _0x8b7d3e = 0;

        UserLock[] storage _0xedf23f = _0xab9311[_0x08bb5b];
        for (uint256 i = 0; i < _0xedf23f.length; i++) {
            if (_0xedf23f[i]._0xf23477 > block.timestamp) {
                _0x8b7d3e += _0xedf23f[i]._0xff82c9;
            }
        }

        return _0x227d88 > _0x8b7d3e ? _0x227d88 - _0x8b7d3e : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xc9ca8a(address _0x08bb5b) internal returns (uint256 _0x23fc6e) {
        UserLock[] storage _0xedf23f = _0xab9311[_0x08bb5b];
        uint256 _0x43dd7b = _0xedf23f.length;
        if (_0x43dd7b == 0) return 0;

        uint256 _0x0ffccc = 0;
        unchecked {
            for (uint256 i = 0; i < _0x43dd7b; i++) {
                UserLock memory L = _0xedf23f[i];
                if (L._0xf23477 <= block.timestamp) {
                    _0x23fc6e += L._0xff82c9;
                } else {
                    if (_0x0ffccc != i) _0xedf23f[_0x0ffccc] = L;
                    _0x0ffccc++;
                }
            }
            if (_0x23fc6e > 0) {
                _0x4a3a45[_0x08bb5b] -= _0x23fc6e;
            }
            while (_0xedf23f.length > _0x0ffccc) {
                _0xedf23f.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0x3a3579(
        address from,
        address _0xb8c4a5,
        uint256 _0xff82c9
    ) internal override {
        super._0x3a3579(from, _0xb8c4a5, _0xff82c9);

        if (from != address(0) && _0xb8c4a5 != address(0)) { // Not mint or burn
            uint256 _0x227d88 = _0x857aeb(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0x10cadb = _0x227d88 > _0x4a3a45[from] ? _0x227d88 - _0x4a3a45[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0x10cadb >= _0xff82c9) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xc9ca8a(from);
            uint256 _0x4f676d = _0x227d88 > _0x4a3a45[from] ? _0x227d88 - _0x4a3a45[from] : 0;

            // Step 4: Check final available balance
            require(_0x4f676d >= _0xff82c9, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0xeedb0c() external _0x9b489e {
        require(_0x4f9b99 != address(0), "Voter not set");
        require(_0x718751 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x1f65c6 = IRewardsDistributor(_0x718751)._0x4c122e(_0xad72c4);
        _0x14b0c0 += _0x1f65c6;
        // Claim bribes from voted pools
        address[] memory _0x00a6fe = IVoter(_0x4f9b99)._0xd4a7dd(_0xad72c4);

        for (uint256 i = 0; i < _0x00a6fe.length; i++) {
            if (_0x00a6fe[i] != address(0)) {
                address _0x1039dc = IGaugeManager(_0x1569db)._0x144b0e(_0x00a6fe[i]);

                if (_0x1039dc != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0x6d7b3b = new address[](1);
                    address[][] memory _0xe85560 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0x26fedb = IGaugeManager(_0x1569db)._0x219aff(_0x1039dc);
                    if (_0x26fedb != address(0)) {
                        uint256 _0x6dcc9e = IBribe(_0x26fedb)._0x024058();
                        if (_0x6dcc9e > 0) {
                            address[] memory _0x08becb = new address[](_0x6dcc9e);
                            for (uint256 j = 0; j < _0x6dcc9e; j++) {
                                _0x08becb[j] = IBribe(_0x26fedb)._0x08becb(j);
                            }
                            _0x6d7b3b[0] = _0x26fedb;
                            _0xe85560[0] = _0x08becb;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x1569db)._0xb80dcd(_0x6d7b3b, _0xe85560, _0xad72c4);
                        }
                    }

                    // Claim external bribe
                    address _0xf86f07 = IGaugeManager(_0x1569db)._0x064b9f(_0x1039dc);
                    if (_0xf86f07 != address(0)) {
                        uint256 _0x6dcc9e = IBribe(_0xf86f07)._0x024058();
                        if (_0x6dcc9e > 0) {
                            address[] memory _0x08becb = new address[](_0x6dcc9e);
                            for (uint256 j = 0; j < _0x6dcc9e; j++) {
                                _0x08becb[j] = IBribe(_0xf86f07)._0x08becb(j);
                            }
                            _0x6d7b3b[0] = _0xf86f07;
                            _0xe85560[0] = _0x08becb;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x1569db)._0xb80dcd(_0x6d7b3b, _0xe85560, _0xad72c4);
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
    function _0x17d6a3(ISwapper.SwapParams calldata _0x676893) external _0x52335a _0x9b489e {
        require(address(_0xa7566b) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x0bfa0a = IERC20(_0x676893._0xd54330)._0x857aeb(address(this));
        require(_0x0bfa0a >= _0x676893._0x8e512a, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x676893._0xd54330)._0xf38950(address(_0xa7566b), _0x676893._0x8e512a);

        // Execute swap through swapper module
        uint256 _0x138abc = _0xa7566b._0xf0a2f7(_0x676893);

        // Reset approval for safety
        IERC20(_0x676893._0xd54330)._0xf38950(address(_0xa7566b), 0);

        // HYBR is now in this contract, ready for compounding
        _0xe4ece7 += _0x138abc;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0xa56aa6() external _0x9b489e {

        // Get current HYBR balance
        uint256 _0x93a345 = IERC20(HYBR)._0x857aeb(address(this));

        if (_0x93a345 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0xf38950(_0x58d027, _0x93a345);
            IVotingEscrow(_0x58d027)._0xdac168(_0xad72c4, _0x93a345);

            // Extend lock to maximum duration
            _0x7dbf21();

            if (true) { _0x082728 = block.timestamp; }

            emit Compound(_0x93a345, _0x457b1a());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0xa9816c(address[] calldata _0x65f60b, uint256[] calldata _0x19b88f) external {
        require(msg.sender == _0x4d2699() || msg.sender == _0xc4e758, "Not authorized");
        require(_0x4f9b99 != address(0), "Voter not set");

        IVoter(_0x4f9b99)._0xa9816c(_0xad72c4, _0x65f60b, _0x19b88f);
        if (gasleft() > 0) { _0xc33e8b = HybraTimeLibrary._0x89411a(block.timestamp); }

    }

    /**
     * @notice Reset votes
     */
    function _0x1e1ddf() external {
        require(msg.sender == _0x4d2699() || msg.sender == _0xc4e758, "Not authorized");
        require(_0x4f9b99 != address(0), "Voter not set");

        IVoter(_0x4f9b99)._0x1e1ddf(_0xad72c4);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0xdd8f90(uint256 _0xff82c9) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0xff82c9 > 0) {
            IERC20(HYBR)._0xe03fed(_0x58d027, _0xff82c9);

            if(_0xad72c4 == 0){
                _0xe604e1(_0xff82c9);
            } else{
                IVotingEscrow(_0x58d027)._0xdac168(_0xad72c4, _0xff82c9);

                // Extend lock to maximum duration
                _0x7dbf21();
            }
        }
        _0x5f49b2 += _0xff82c9;
        emit PenaltyRewardReceived(_0xff82c9);
    }

    /**
     * @notice Set the voter contract
     */
    function _0x9fc35b(address _0xad999c) external _0x00e107 {
        require(_0xad999c != address(0), "Invalid voter");
        _0x4f9b99 = _0xad999c;
        emit VoterSet(_0xad999c);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x86dc7e(uint256 _0x2b1b08) external _0x00e107 {
        require(_0x2b1b08 >= MIN_LOCK_PERIOD && _0x2b1b08 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x8a3880 = _0xe0eef7;
        _0xe0eef7 = _0x2b1b08;
        emit TransferLockPeriodUpdated(_0x8a3880, _0x2b1b08);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x085cca(uint256 _0x127eeb) external _0x00e107 {
        require(_0x127eeb >= MIN_WITHDRAW_FEE && _0x127eeb <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0xc2c2ac = _0x127eeb;
    }

    function _0x4e1fdc(uint256 _0x6f62d0) external _0x00e107 {
        _0x220a62 = _0x6f62d0;
    }

    function _0x1b6a81(uint256 _0x6f62d0) external _0x00e107 {
        _0x0de0a1 = _0x6f62d0;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x9fe9ee(address _0xd5c1ba) external _0x00e107 {
        require(_0xd5c1ba != address(0), "Invalid swapper");
        address _0x1cc1a7 = address(_0xa7566b);
        _0xa7566b = ISwapper(_0xd5c1ba);
        emit SwapperUpdated(_0x1cc1a7, _0xd5c1ba);
    }

    /**
     * @notice Set the team address
     */
    function _0xf43353(address _0xf1906f) external _0x00e107 {
        require(_0xf1906f != address(0), "Invalid team");
        if (1 == 1) { Team = _0xf1906f; }
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0xb33f99(address _0x08bb5b) external _0x9b489e {
        delete _0xab9311[_0x08bb5b];
        _0x4a3a45[_0x08bb5b] = 0;
        emit EmergencyUnlock(_0x08bb5b);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x50f90a(address _0x08bb5b) external view returns (UserLock[] memory) {
        return _0xab9311[_0x08bb5b];
    }

    /**
     * @notice Set operator address
     */
    function _0xa44ff3(address _0x35979b) external _0x00e107 {
        require(_0x35979b != address(0), "Invalid operator");
        address _0x6734af = _0xc4e758;
        if (true) { _0xc4e758 = _0x35979b; }
        emit OperatorUpdated(_0x6734af, _0x35979b);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0xd2fe26() external view returns (uint256) {
        if (_0xad72c4 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x037e61 = IVotingEscrow(_0x58d027)._0x037e61(_0xad72c4);
        return uint256(_0x037e61._0xbaed85);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0x7dbf21() internal {
        if (_0xad72c4 == 0) return;

        IVotingEscrow.LockedBalance memory _0x037e61 = IVotingEscrow(_0x58d027)._0x037e61(_0xad72c4);
        if (_0x037e61._0xd96ef7 || _0x037e61._0xbaed85 <= block.timestamp) return;

        uint256 _0xc0b5e6 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0xc0b5e6 > _0x037e61._0xbaed85 + 2 hours) {
            try IVotingEscrow(_0x58d027)._0x0cbb8f(_0xad72c4, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}