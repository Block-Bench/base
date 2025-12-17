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
    uint256 public _0xa1b2a7 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x0cb772 = 1200; // 5days
    uint256 public _0x6b330a = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0xe0872e = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x01c101;
    uint256 public _0x7f9bfd;
    uint256 public _0xd288fa;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0xb09ae8;
        uint256 _0xe96f59;
    }

    mapping(address => UserLock[]) public _0x34a1b0;
    mapping(address => uint256) public _0x0da85a;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0x9d6bf5;
    address public _0xf64f5e;
    address public _0xd8bd2c;
    address public _0x1d47be;
    uint256 public _0xe5f467; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0xaf5e74; // Address that can manage voting strategy
    uint256 public _0x597868; // Last epoch when we voted

    // Reward tracking
    uint256 public _0x778578;
    uint256 public _0x9831fd;

    // Swap module
    ISwapper public _0x66fdb4;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0x9bee0c, uint256 _0x229163, uint256 _0xc12547);
    event Withdraw(address indexed _0x9bee0c, uint256 _0x7b39bc, uint256 _0x229163, uint256 _0x1815e2);
    event Compound(uint256 _0xf91684, uint256 _0x837b13);
    event PenaltyRewardReceived(uint256 _0xb09ae8);
    event TransferLockPeriodUpdated(uint256 _0x1a2d32, uint256 _0x6e58d9);
    event SwapperUpdated(address indexed _0xceb5f7, address indexed _0x40685e);
    event VoterSet(address _0xf64f5e);
    event EmergencyUnlock(address indexed _0x9bee0c);
    event AutoVotingEnabled(bool _0x6467e5);
    event OperatorUpdated(address indexed _0xd26c79, address indexed _0xf26cec);
    event DefaultVotingStrategyUpdated(address[] _0xf28bf6, uint256[] _0xad51d8);
    event AutoVoteExecuted(uint256 _0x387d9a, address[] _0xf28bf6, uint256[] _0xad51d8);

    constructor(
        address _0xe67883,
        address _0x9313d7
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xe67883 != address(0), "Invalid HYBR");
        require(_0x9313d7 != address(0), "Invalid VE");

        HYBR = _0xe67883;
        _0x9d6bf5 = _0x9313d7;
        _0x778578 = block.timestamp;
        _0x9831fd = block.timestamp;
        _0xaf5e74 = msg.sender; // Initially set deployer as operator
    }

    function _0x5bee14(address _0x9f279d) external _0x13922f {
        require(_0x9f279d != address(0), "Invalid rewards distributor");
        _0xd8bd2c = _0x9f279d;
    }

    function _0xbb451b(address _0x71f1bb) external _0x13922f {
        require(_0x71f1bb != address(0), "Invalid gauge manager");
        _0x1d47be = _0x71f1bb;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0x02cff9() {
        if (msg.sender != _0xaf5e74) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0x7071de(uint256 _0xb09ae8, address _0xad58bc) external _0x9479ec {
        require(_0xb09ae8 > 0, "Zero amount");
        _0xad58bc = _0xad58bc == address(0) ? msg.sender : _0xad58bc;

        // Transfer HYBR from user first
        IERC20(HYBR)._0x342d48(msg.sender, address(this), _0xb09ae8);

        // Initialize veNFT on first deposit
        if (_0xe5f467 == 0) {
            _0xe6fe06(_0xb09ae8);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0xe3994f(_0x9d6bf5, _0xb09ae8);
            IVotingEscrow(_0x9d6bf5)._0x933d44(_0xe5f467, _0xb09ae8);

            // Extend lock to maximum duration
            _0x51fcde();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0x7b39bc = _0x988515(_0xb09ae8);

        // Mint gHYBR shares
        _0x45c8e3(_0xad58bc, _0x7b39bc);

        // Add transfer lock for recipient
        _0xd26650(_0xad58bc, _0x7b39bc);

        emit Deposit(msg.sender, _0xb09ae8, _0x7b39bc);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0x09bf5e(uint256 _0x7b39bc) external _0x9479ec returns (uint256 _0x60576a) {
        require(_0x7b39bc > 0, "Zero shares");
        require(_0xfee2c4(msg.sender) >= _0x7b39bc, "Insufficient balance");
        require(_0xe5f467 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x9d6bf5)._0xe0b107(_0xe5f467) == false, "Cannot withdraw yet");

        uint256 _0x07412e = HybraTimeLibrary._0x07412e(block.timestamp);
        uint256 _0x9bf67a = HybraTimeLibrary._0x9bf67a(block.timestamp);

        require(block.timestamp >= _0x07412e + _0x0cb772 && block.timestamp < _0x9bf67a - _0x6b330a, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x229163 = _0x500461(_0x7b39bc);
        require(_0x229163 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0xe406a0 = 0;
        if (_0xe0872e > 0) {
            _0xe406a0 = (_0x229163 * _0xe0872e) / BASIS;
        }

        // User receives amount minus fee
        uint256 _0x330746 = _0x229163 - _0xe406a0;
        require(_0x330746 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x427672 = _0x3466e5();
        require(_0x229163 <= _0x427672, "Insufficient veNFT balance");

        uint256 _0x79fbe7 = _0x427672 - _0x330746 - _0xe406a0;
        require(_0x79fbe7 >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0xe34c1e(msg.sender, _0x7b39bc);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0xd9cd9e = new uint256[](3);
        _0xd9cd9e[0] = _0x79fbe7; // Amount staying with gHYBR
        _0xd9cd9e[1] = _0x330746;      // Amount going to user (after fee)
        _0xd9cd9e[2] = _0xe406a0;      // Amount going to fee recipient

        uint256[] memory _0x01a2e1 = IVotingEscrow(_0x9d6bf5)._0x9ed611(_0xe5f467, _0xd9cd9e);

        // Update contract's veTokenId to the first new token
        _0xe5f467 = _0x01a2e1[0];
        _0x60576a = _0x01a2e1[1];
        uint256 _0x5e0da3 = _0x01a2e1[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0x9d6bf5)._0x2821b9(address(this), msg.sender, _0x60576a);
        IVotingEscrow(_0x9d6bf5)._0x2821b9(address(this), Team, _0x5e0da3);
        emit Withdraw(msg.sender, _0x7b39bc, _0x330746, _0xe406a0);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0xe6fe06(uint256 _0x2c640b) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0xe3994f(_0x9d6bf5, type(uint256)._0x40826b);
        uint256 _0x864753 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0xe5f467 = IVotingEscrow(_0x9d6bf5)._0x88e66a(_0x2c640b, _0x864753, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0x988515(uint256 _0xb09ae8) public view returns (uint256) {
        uint256 _0x1a5867 = _0xe4686c();
        uint256 _0x001a39 = _0x3466e5();
        if (_0x1a5867 == 0 || _0x001a39 == 0) {
            return _0xb09ae8;
        }
        return (_0xb09ae8 * _0x1a5867) / _0x001a39;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x500461(uint256 _0x7b39bc) public view returns (uint256) {
        uint256 _0x1a5867 = _0xe4686c();
        if (_0x1a5867 == 0) {
            return _0x7b39bc;
        }
        return (_0x7b39bc * _0x3466e5()) / _0x1a5867;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0x3466e5() public view returns (uint256) {
        if (_0xe5f467 == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0xbe56a6 = IVotingEscrow(_0x9d6bf5)._0xbe56a6(_0xe5f467);
        return uint256(int256(_0xbe56a6._0xb09ae8));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0xd26650(address _0x9bee0c, uint256 _0xb09ae8) internal {
        uint256 _0xe96f59 = block.timestamp + _0xa1b2a7;
        _0x34a1b0[_0x9bee0c].push(UserLock({
            _0xb09ae8: _0xb09ae8,
            _0xe96f59: _0xe96f59
        }));
        _0x0da85a[_0x9bee0c] += _0xb09ae8;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0xc6c45a(address _0x9bee0c) external view returns (uint256 _0x791e92) {
        uint256 _0x12b221 = _0xfee2c4(_0x9bee0c);
        uint256 _0x5a9a43 = 0;

        UserLock[] storage _0x3f4ccb = _0x34a1b0[_0x9bee0c];
        for (uint256 i = 0; i < _0x3f4ccb.length; i++) {
            if (_0x3f4ccb[i]._0xe96f59 > block.timestamp) {
                _0x5a9a43 += _0x3f4ccb[i]._0xb09ae8;
            }
        }

        return _0x12b221 > _0x5a9a43 ? _0x12b221 - _0x5a9a43 : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0x03f3f0(address _0x9bee0c) internal returns (uint256 _0x9b0478) {
        UserLock[] storage _0x3f4ccb = _0x34a1b0[_0x9bee0c];
        uint256 _0x12f470 = _0x3f4ccb.length;
        if (_0x12f470 == 0) return 0;

        uint256 _0x7824d5 = 0;
        unchecked {
            for (uint256 i = 0; i < _0x12f470; i++) {
                UserLock memory L = _0x3f4ccb[i];
                if (L._0xe96f59 <= block.timestamp) {
                    _0x9b0478 += L._0xb09ae8;
                } else {
                    if (_0x7824d5 != i) _0x3f4ccb[_0x7824d5] = L;
                    _0x7824d5++;
                }
            }
            if (_0x9b0478 > 0) {
                _0x0da85a[_0x9bee0c] -= _0x9b0478;
            }
            while (_0x3f4ccb.length > _0x7824d5) {
                _0x3f4ccb.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0xddd2b5(
        address from,
        address _0xd037c5,
        uint256 _0xb09ae8
    ) internal override {
        super._0xddd2b5(from, _0xd037c5, _0xb09ae8);

        if (from != address(0) && _0xd037c5 != address(0)) { // Not mint or burn
            uint256 _0x12b221 = _0xfee2c4(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0x7e51d1 = _0x12b221 > _0x0da85a[from] ? _0x12b221 - _0x0da85a[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0x7e51d1 >= _0xb09ae8) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0x03f3f0(from);
            uint256 _0x8f8232 = _0x12b221 > _0x0da85a[from] ? _0x12b221 - _0x0da85a[from] : 0;

            // Step 4: Check final available balance
            require(_0x8f8232 >= _0xb09ae8, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0x366ea7() external _0x02cff9 {
        require(_0xf64f5e != address(0), "Voter not set");
        require(_0xd8bd2c != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0xd10d31 = IRewardsDistributor(_0xd8bd2c)._0x887094(_0xe5f467);
        _0x01c101 += _0xd10d31;
        // Claim bribes from voted pools
        address[] memory _0xf48b59 = IVoter(_0xf64f5e)._0x778e70(_0xe5f467);

        for (uint256 i = 0; i < _0xf48b59.length; i++) {
            if (_0xf48b59[i] != address(0)) {
                address _0x2b95d2 = IGaugeManager(_0x1d47be)._0x31c653(_0xf48b59[i]);

                if (_0x2b95d2 != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0xe0342b = new address[](1);
                    address[][] memory _0x011a87 = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0xf70fa7 = IGaugeManager(_0x1d47be)._0xccc9c1(_0x2b95d2);
                    if (_0xf70fa7 != address(0)) {
                        uint256 _0x464e8d = IBribe(_0xf70fa7)._0xe05df4();
                        if (_0x464e8d > 0) {
                            address[] memory _0x105e5e = new address[](_0x464e8d);
                            for (uint256 j = 0; j < _0x464e8d; j++) {
                                _0x105e5e[j] = IBribe(_0xf70fa7)._0x105e5e(j);
                            }
                            _0xe0342b[0] = _0xf70fa7;
                            _0x011a87[0] = _0x105e5e;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x1d47be)._0x8ebe90(_0xe0342b, _0x011a87, _0xe5f467);
                        }
                    }

                    // Claim external bribe
                    address _0x5a62dd = IGaugeManager(_0x1d47be)._0xd3f41a(_0x2b95d2);
                    if (_0x5a62dd != address(0)) {
                        uint256 _0x464e8d = IBribe(_0x5a62dd)._0xe05df4();
                        if (_0x464e8d > 0) {
                            address[] memory _0x105e5e = new address[](_0x464e8d);
                            for (uint256 j = 0; j < _0x464e8d; j++) {
                                _0x105e5e[j] = IBribe(_0x5a62dd)._0x105e5e(j);
                            }
                            _0xe0342b[0] = _0x5a62dd;
                            _0x011a87[0] = _0x105e5e;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x1d47be)._0x8ebe90(_0xe0342b, _0x011a87, _0xe5f467);
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
    function _0x26c477(ISwapper.SwapParams calldata _0x222402) external _0x9479ec _0x02cff9 {
        require(address(_0x66fdb4) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x61fa61 = IERC20(_0x222402._0xbc9d79)._0xfee2c4(address(this));
        require(_0x61fa61 >= _0x222402._0xef92ff, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x222402._0xbc9d79)._0x01a4b4(address(_0x66fdb4), _0x222402._0xef92ff);

        // Execute swap through swapper module
        uint256 _0xfbca7b = _0x66fdb4._0x77430b(_0x222402);

        // Reset approval for safety
        IERC20(_0x222402._0xbc9d79)._0x01a4b4(address(_0x66fdb4), 0);

        // HYBR is now in this contract, ready for compounding
        _0xd288fa += _0xfbca7b;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0x61b5e7() external _0x02cff9 {

        // Get current HYBR balance
        uint256 _0xcb1065 = IERC20(HYBR)._0xfee2c4(address(this));

        if (_0xcb1065 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0x01a4b4(_0x9d6bf5, _0xcb1065);
            IVotingEscrow(_0x9d6bf5)._0x933d44(_0xe5f467, _0xcb1065);

            // Extend lock to maximum duration
            _0x51fcde();

            _0x9831fd = block.timestamp;

            emit Compound(_0xcb1065, _0x3466e5());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0x936f29(address[] calldata _0xa97893, uint256[] calldata _0x3ab879) external {
        require(msg.sender == _0x5ccb60() || msg.sender == _0xaf5e74, "Not authorized");
        require(_0xf64f5e != address(0), "Voter not set");

        IVoter(_0xf64f5e)._0x936f29(_0xe5f467, _0xa97893, _0x3ab879);
        _0x597868 = HybraTimeLibrary._0x07412e(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function _0xbd7011() external {
        require(msg.sender == _0x5ccb60() || msg.sender == _0xaf5e74, "Not authorized");
        require(_0xf64f5e != address(0), "Voter not set");

        IVoter(_0xf64f5e)._0xbd7011(_0xe5f467);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x08d0fc(uint256 _0xb09ae8) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0xb09ae8 > 0) {
            IERC20(HYBR)._0xe3994f(_0x9d6bf5, _0xb09ae8);

            if(_0xe5f467 == 0){
                _0xe6fe06(_0xb09ae8);
            } else{
                IVotingEscrow(_0x9d6bf5)._0x933d44(_0xe5f467, _0xb09ae8);

                // Extend lock to maximum duration
                _0x51fcde();
            }
        }
        _0x7f9bfd += _0xb09ae8;
        emit PenaltyRewardReceived(_0xb09ae8);
    }

    /**
     * @notice Set the voter contract
     */
    function _0xf18e1d(address _0x70f942) external _0x13922f {
        require(_0x70f942 != address(0), "Invalid voter");
        _0xf64f5e = _0x70f942;
        emit VoterSet(_0x70f942);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x602bcd(uint256 _0x0755aa) external _0x13922f {
        require(_0x0755aa >= MIN_LOCK_PERIOD && _0x0755aa <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x1a2d32 = _0xa1b2a7;
        _0xa1b2a7 = _0x0755aa;
        emit TransferLockPeriodUpdated(_0x1a2d32, _0x0755aa);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x40b620(uint256 _0xeda715) external _0x13922f {
        require(_0xeda715 >= MIN_WITHDRAW_FEE && _0xeda715 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0xe0872e = _0xeda715;
    }

    function _0x58bcb9(uint256 _0xc4049e) external _0x13922f {
        _0x0cb772 = _0xc4049e;
    }

    function _0x3fd515(uint256 _0xc4049e) external _0x13922f {
        _0x6b330a = _0xc4049e;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0xfa5fb5(address _0xbcb32f) external _0x13922f {
        require(_0xbcb32f != address(0), "Invalid swapper");
        address _0xceb5f7 = address(_0x66fdb4);
        _0x66fdb4 = ISwapper(_0xbcb32f);
        emit SwapperUpdated(_0xceb5f7, _0xbcb32f);
    }

    /**
     * @notice Set the team address
     */
    function _0x732fe6(address _0xd29880) external _0x13922f {
        require(_0xd29880 != address(0), "Invalid team");
        Team = _0xd29880;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x889770(address _0x9bee0c) external _0x02cff9 {
        delete _0x34a1b0[_0x9bee0c];
        _0x0da85a[_0x9bee0c] = 0;
        emit EmergencyUnlock(_0x9bee0c);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x22ab72(address _0x9bee0c) external view returns (UserLock[] memory) {
        return _0x34a1b0[_0x9bee0c];
    }

    /**
     * @notice Set operator address
     */
    function _0x8acfc5(address _0x771e7c) external _0x13922f {
        require(_0x771e7c != address(0), "Invalid operator");
        address _0xd26c79 = _0xaf5e74;
        _0xaf5e74 = _0x771e7c;
        emit OperatorUpdated(_0xd26c79, _0x771e7c);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0xde7b8f() external view returns (uint256) {
        if (_0xe5f467 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0xbe56a6 = IVotingEscrow(_0x9d6bf5)._0xbe56a6(_0xe5f467);
        return uint256(_0xbe56a6._0xa8d7d2);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0x51fcde() internal {
        if (_0xe5f467 == 0) return;

        IVotingEscrow.LockedBalance memory _0xbe56a6 = IVotingEscrow(_0x9d6bf5)._0xbe56a6(_0xe5f467);
        if (_0xbe56a6._0xe5c908 || _0xbe56a6._0xa8d7d2 <= block.timestamp) return;

        uint256 _0x4f1453 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0x4f1453 > _0xbe56a6._0xa8d7d2 + 2 hours) {
            try IVotingEscrow(_0x9d6bf5)._0xfe681c(_0xe5f467, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}