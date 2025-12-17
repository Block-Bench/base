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
    uint256 public _0xf5009e = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x4447b0 = 1200; // 5days
    uint256 public _0xfea910 = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public _0x59137c = 100; // 1% default fee
    uint256 public constant MIN_WITHDRAW_FEE = 10; // 0.1% minimum
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public _0x524a0f;
    uint256 public _0xc7ce62;
    uint256 public _0x180b9f;
    // User deposit tracking for transfer locks
    struct UserLock {
        uint256 _0xc9a9d4;
        uint256 _0x4e608e;
    }

    mapping(address => UserLock[]) public _0x2b4298;
    mapping(address => uint256) public _0xd4de7b;

    // Core contracts
    address public immutable HYBR;
    address public immutable _0xbaecfc;
    address public _0x24116f;
    address public _0x67bef5;
    address public _0x77b462;
    uint256 public _0x69621a; // The veNFT owned by this contract

    // Auto-voting strategy
    address public _0xeb35c7; // Address that can manage voting strategy
    uint256 public _0x7ccd7c; // Last epoch when we voted

    // Reward tracking
    uint256 public _0xf97bb8;
    uint256 public _0xeaac9b;

    // Swap module
    ISwapper public _0x519653;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event Deposit(address indexed _0x2d93cd, uint256 _0x21ddc2, uint256 _0x5b03fa);
    event Withdraw(address indexed _0x2d93cd, uint256 _0x709ac9, uint256 _0x21ddc2, uint256 _0xa0b006);
    event Compound(uint256 _0x5fa7c8, uint256 _0xc881a1);
    event PenaltyRewardReceived(uint256 _0xc9a9d4);
    event TransferLockPeriodUpdated(uint256 _0xc21160, uint256 _0xfb9baa);
    event SwapperUpdated(address indexed _0x349373, address indexed _0xc7335c);
    event VoterSet(address _0x24116f);
    event EmergencyUnlock(address indexed _0x2d93cd);
    event AutoVotingEnabled(bool _0xb8c163);
    event OperatorUpdated(address indexed _0x58ef1b, address indexed _0xb05dce);
    event DefaultVotingStrategyUpdated(address[] _0x667cab, uint256[] _0x140f85);
    event AutoVoteExecuted(uint256 _0x9a2f31, address[] _0x667cab, uint256[] _0x140f85);

    constructor(
        address _0xb5b5c1,
        address _0x3bdb65
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xb5b5c1 != address(0), "Invalid HYBR");
        require(_0x3bdb65 != address(0), "Invalid VE");

        HYBR = _0xb5b5c1;
        _0xbaecfc = _0x3bdb65;
        _0xf97bb8 = block.timestamp;
        _0xeaac9b = block.timestamp;
        _0xeb35c7 = msg.sender; // Initially set deployer as operator
    }

    function _0x6d0db3(address _0xbe697e) external _0x0b25bc {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        require(_0xbe697e != address(0), "Invalid rewards distributor");
        _0x67bef5 = _0xbe697e;
    }

    function _0x32e5af(address _0x72ade1) external _0x0b25bc {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        require(_0x72ade1 != address(0), "Invalid gauge manager");
        _0x77b462 = _0x72ade1;
    }

      /**
     * @notice Modifier to check authorization (owner or operator)
     */
    modifier _0xe55088() {
        if (msg.sender != _0xeb35c7) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice Deposit HYBR and receive gHYBR shares
     * @param amount Amount of HYBR to deposit
     * @param recipient Recipient of gHYBR shares
     */
    function _0xa0a74e(uint256 _0xc9a9d4, address _0x3acff2) external _0x4ce5b6 {
        require(_0xc9a9d4 > 0, "Zero amount");
        _0x3acff2 = _0x3acff2 == address(0) ? msg.sender : _0x3acff2;

        // Transfer HYBR from user first
        IERC20(HYBR)._0xce599e(msg.sender, address(this), _0xc9a9d4);

        // Initialize veNFT on first deposit
        if (_0x69621a == 0) {
            _0xc66ece(_0xc9a9d4);
        } else {
            // Add to existing veNFT
            IERC20(HYBR)._0x6a2a81(_0xbaecfc, _0xc9a9d4);
            IVotingEscrow(_0xbaecfc)._0x68a45c(_0x69621a, _0xc9a9d4);

            // Extend lock to maximum duration
            _0x908ae7();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 _0x709ac9 = _0xbf21b9(_0xc9a9d4);

        // Mint gHYBR shares
        _0xea8b98(_0x3acff2, _0x709ac9);

        // Add transfer lock for recipient
        _0xe87adf(_0x3acff2, _0x709ac9);

        emit Deposit(msg.sender, _0xc9a9d4, _0x709ac9);
    }

    /**
     * @notice Withdraw gHYBR shares and receive a new veNFT with proportional HYBR
     * @dev Creates new veNFT using multiSplit to maintain proportional ownership
     * @param shares Amount of gHYBR shares to burn
     * @return userTokenId The ID of the new veNFT created for the user
     */
    function _0xb47781(uint256 _0x709ac9) external _0x4ce5b6 returns (uint256 _0x0df91c) {
        require(_0x709ac9 > 0, "Zero shares");
        require(_0xa1b8f8(msg.sender) >= _0x709ac9, "Insufficient balance");
        require(_0x69621a != 0, "No veNFT initialized");
        require(IVotingEscrow(_0xbaecfc)._0xaa8a16(_0x69621a) == false, "Cannot withdraw yet");

        uint256 _0xa0ac4c = HybraTimeLibrary._0xa0ac4c(block.timestamp);
        uint256 _0x88d1aa = HybraTimeLibrary._0x88d1aa(block.timestamp);

        require(block.timestamp >= _0xa0ac4c + _0x4447b0 && block.timestamp < _0x88d1aa - _0xfea910, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 _0x21ddc2 = _0x09fce3(_0x709ac9);
        require(_0x21ddc2 > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 _0x05bba0 = 0;
        if (_0x59137c > 0) {
            if (true) { _0x05bba0 = (_0x21ddc2 * _0x59137c) / BASIS; }
        }

        // User receives amount minus fee
        uint256 _0xc5d205 = _0x21ddc2 - _0x05bba0;
        require(_0xc5d205 > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 _0x0e6bd5 = _0xfbc965();
        require(_0x21ddc2 <= _0x0e6bd5, "Insufficient veNFT balance");

        uint256 _0xa212fb = _0x0e6bd5 - _0xc5d205 - _0x05bba0;
        require(_0xa212fb >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _0xbeb91e(msg.sender, _0x709ac9);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory _0xa6598e = new uint256[](3);
        _0xa6598e[0] = _0xa212fb; // Amount staying with gHYBR
        _0xa6598e[1] = _0xc5d205;      // Amount going to user (after fee)
        _0xa6598e[2] = _0x05bba0;      // Amount going to fee recipient

        uint256[] memory _0x9754d0 = IVotingEscrow(_0xbaecfc)._0x9ebc31(_0x69621a, _0xa6598e);

        // Update contract's veTokenId to the first new token
        _0x69621a = _0x9754d0[0];
        _0x0df91c = _0x9754d0[1];
        uint256 _0xbc1650 = _0x9754d0[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(_0xbaecfc)._0x3d8cdc(address(this), msg.sender, _0x0df91c);
        IVotingEscrow(_0xbaecfc)._0x3d8cdc(address(this), Team, _0xbc1650);
        emit Withdraw(msg.sender, _0x709ac9, _0xc5d205, _0x05bba0);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _0xc66ece(uint256 _0x377ff2) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR)._0x6a2a81(_0xbaecfc, type(uint256)._0x8f3649);
        uint256 _0x151007 = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        _0x69621a = IVotingEscrow(_0xbaecfc)._0x4ecef8(_0x377ff2, _0x151007, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function _0xbf21b9(uint256 _0xc9a9d4) public view returns (uint256) {
        uint256 _0xf59193 = _0x3cc523();
        uint256 _0x746fd2 = _0xfbc965();
        if (_0xf59193 == 0 || _0x746fd2 == 0) {
            return _0xc9a9d4;
        }
        return (_0xc9a9d4 * _0xf59193) / _0x746fd2;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function _0x09fce3(uint256 _0x709ac9) public view returns (uint256) {
        uint256 _0xf59193 = _0x3cc523();
        if (_0xf59193 == 0) {
            return _0x709ac9;
        }
        return (_0x709ac9 * _0xfbc965()) / _0xf59193;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function _0xfbc965() public view returns (uint256) {
        if (_0x69621a == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory _0x1a61c6 = IVotingEscrow(_0xbaecfc)._0x1a61c6(_0x69621a);
        return uint256(int256(_0x1a61c6._0xc9a9d4));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _0xe87adf(address _0x2d93cd, uint256 _0xc9a9d4) internal {
        uint256 _0x4e608e = block.timestamp + _0xf5009e;
        _0x2b4298[_0x2d93cd].push(UserLock({
            _0xc9a9d4: _0xc9a9d4,
            _0x4e608e: _0x4e608e
        }));
        _0xd4de7b[_0x2d93cd] += _0xc9a9d4;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function _0x7ab2c0(address _0x2d93cd) external view returns (uint256 _0x6bd5ed) {
        uint256 _0xdc0b8e = _0xa1b8f8(_0x2d93cd);
        uint256 _0x4529ff = 0;

        UserLock[] storage _0xfc4dd4 = _0x2b4298[_0x2d93cd];
        for (uint256 i = 0; i < _0xfc4dd4.length; i++) {
            if (_0xfc4dd4[i]._0x4e608e > block.timestamp) {
                _0x4529ff += _0xfc4dd4[i]._0xc9a9d4;
            }
        }

        return _0xdc0b8e > _0x4529ff ? _0xdc0b8e - _0x4529ff : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _0xefc12a(address _0x2d93cd) internal returns (uint256 _0xb1cdfd) {
        UserLock[] storage _0xfc4dd4 = _0x2b4298[_0x2d93cd];
        uint256 _0x6b9c23 = _0xfc4dd4.length;
        if (_0x6b9c23 == 0) return 0;

        uint256 _0xfff43d = 0;
        unchecked {
            for (uint256 i = 0; i < _0x6b9c23; i++) {
                UserLock memory L = _0xfc4dd4[i];
                if (L._0x4e608e <= block.timestamp) {
                    _0xb1cdfd += L._0xc9a9d4;
                } else {
                    if (_0xfff43d != i) _0xfc4dd4[_0xfff43d] = L;
                    _0xfff43d++;
                }
            }
            if (_0xb1cdfd > 0) {
                _0xd4de7b[_0x2d93cd] -= _0xb1cdfd;
            }
            while (_0xfc4dd4.length > _0xfff43d) {
                _0xfc4dd4.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _0xbc3265(
        address from,
        address _0x1943a0,
        uint256 _0xc9a9d4
    ) internal override {
        super._0xbc3265(from, _0x1943a0, _0xc9a9d4);

        if (from != address(0) && _0x1943a0 != address(0)) { // Not mint or burn
            uint256 _0xdc0b8e = _0xa1b8f8(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 _0x7995c1 = _0xdc0b8e > _0xd4de7b[from] ? _0xdc0b8e - _0xd4de7b[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (_0x7995c1 >= _0xc9a9d4) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _0xefc12a(from);
            uint256 _0x5c8093 = _0xdc0b8e > _0xd4de7b[from] ? _0xdc0b8e - _0xd4de7b[from] : 0;

            // Step 4: Check final available balance
            require(_0x5c8093 >= _0xc9a9d4, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function _0x3b7f13() external _0xe55088 {
        require(_0x24116f != address(0), "Voter not set");
        require(_0x67bef5 != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  _0x9fc08f = IRewardsDistributor(_0x67bef5)._0x82cedb(_0x69621a);
        _0x524a0f += _0x9fc08f;
        // Claim bribes from voted pools
        address[] memory _0xc0afe5 = IVoter(_0x24116f)._0xbe6c02(_0x69621a);

        for (uint256 i = 0; i < _0xc0afe5.length; i++) {
            if (_0xc0afe5[i] != address(0)) {
                address _0x351de0 = IGaugeManager(_0x77b462)._0xdda5d1(_0xc0afe5[i]);

                if (_0x351de0 != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory _0x6374fd = new address[](1);
                    address[][] memory _0x77a12f = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address _0x2b2794 = IGaugeManager(_0x77b462)._0x02cadb(_0x351de0);
                    if (_0x2b2794 != address(0)) {
                        uint256 _0x211c4a = IBribe(_0x2b2794)._0x8695bc();
                        if (_0x211c4a > 0) {
                            address[] memory _0x04a85f = new address[](_0x211c4a);
                            for (uint256 j = 0; j < _0x211c4a; j++) {
                                _0x04a85f[j] = IBribe(_0x2b2794)._0x04a85f(j);
                            }
                            _0x6374fd[0] = _0x2b2794;
                            _0x77a12f[0] = _0x04a85f;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x77b462)._0x262dc1(_0x6374fd, _0x77a12f, _0x69621a);
                        }
                    }

                    // Claim external bribe
                    address _0x89fa93 = IGaugeManager(_0x77b462)._0xb84b3d(_0x351de0);
                    if (_0x89fa93 != address(0)) {
                        uint256 _0x211c4a = IBribe(_0x89fa93)._0x8695bc();
                        if (_0x211c4a > 0) {
                            address[] memory _0x04a85f = new address[](_0x211c4a);
                            for (uint256 j = 0; j < _0x211c4a; j++) {
                                _0x04a85f[j] = IBribe(_0x89fa93)._0x04a85f(j);
                            }
                            _0x6374fd[0] = _0x89fa93;
                            _0x77a12f[0] = _0x04a85f;
                            // Call claimBribes for this single bribe
                            IGaugeManager(_0x77b462)._0x262dc1(_0x6374fd, _0x77a12f, _0x69621a);
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
    function _0x7ccc27(ISwapper.SwapParams calldata _0x08ebd6) external _0x4ce5b6 _0xe55088 {
        require(address(_0x519653) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 _0x2c9e89 = IERC20(_0x08ebd6._0x45346b)._0xa1b8f8(address(this));
        require(_0x2c9e89 >= _0x08ebd6._0x60761c, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_0x08ebd6._0x45346b)._0xd6d08c(address(_0x519653), _0x08ebd6._0x60761c);

        // Execute swap through swapper module
        uint256 _0x93b8b5 = _0x519653._0x0e239a(_0x08ebd6);

        // Reset approval for safety
        IERC20(_0x08ebd6._0x45346b)._0xd6d08c(address(_0x519653), 0);

        // HYBR is now in this contract, ready for compounding
        _0x180b9f += _0x93b8b5;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function _0xba3ee3() external _0xe55088 {

        // Get current HYBR balance
        uint256 _0x513232 = IERC20(HYBR)._0xa1b8f8(address(this));

        if (_0x513232 > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR)._0xd6d08c(_0xbaecfc, _0x513232);
            IVotingEscrow(_0xbaecfc)._0x68a45c(_0x69621a, _0x513232);

            // Extend lock to maximum duration
            _0x908ae7();

            _0xeaac9b = block.timestamp;

            emit Compound(_0x513232, _0xfbc965());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function _0x19aeec(address[] calldata _0x053c17, uint256[] calldata _0xf7502f) external {
        require(msg.sender == _0x3ca2ed() || msg.sender == _0xeb35c7, "Not authorized");
        require(_0x24116f != address(0), "Voter not set");

        IVoter(_0x24116f)._0x19aeec(_0x69621a, _0x053c17, _0xf7502f);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x7ccd7c = HybraTimeLibrary._0xa0ac4c(block.timestamp); }

    }

    /**
     * @notice Reset votes
     */
    function _0xdfa6c6() external {
        require(msg.sender == _0x3ca2ed() || msg.sender == _0xeb35c7, "Not authorized");
        require(_0x24116f != address(0), "Voter not set");

        IVoter(_0x24116f)._0xdfa6c6(_0x69621a);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function _0x3d4ac6(uint256 _0xc9a9d4) external {

        // Auto-compound penalty rewards to existing veNFT
        if (_0xc9a9d4 > 0) {
            IERC20(HYBR)._0x6a2a81(_0xbaecfc, _0xc9a9d4);

            if(_0x69621a == 0){
                _0xc66ece(_0xc9a9d4);
            } else{
                IVotingEscrow(_0xbaecfc)._0x68a45c(_0x69621a, _0xc9a9d4);

                // Extend lock to maximum duration
                _0x908ae7();
            }
        }
        _0xc7ce62 += _0xc9a9d4;
        emit PenaltyRewardReceived(_0xc9a9d4);
    }

    /**
     * @notice Set the voter contract
     */
    function _0xd4a776(address _0xa5721e) external _0x0b25bc {
        require(_0xa5721e != address(0), "Invalid voter");
        _0x24116f = _0xa5721e;
        emit VoterSet(_0xa5721e);
    }

    /**
     * @notice Update transfer lock period
     */
    function _0x92c548(uint256 _0xddf9a1) external _0x0b25bc {
        require(_0xddf9a1 >= MIN_LOCK_PERIOD && _0xddf9a1 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0xc21160 = _0xf5009e;
        _0xf5009e = _0xddf9a1;
        emit TransferLockPeriodUpdated(_0xc21160, _0xddf9a1);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function _0x937497(uint256 _0x6f36a0) external _0x0b25bc {
        require(_0x6f36a0 >= MIN_WITHDRAW_FEE && _0x6f36a0 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x59137c = _0x6f36a0;
    }

    function _0x3d996f(uint256 _0x08f856) external _0x0b25bc {
        if (gasleft() > 0) { _0x4447b0 = _0x08f856; }
    }

    function _0xc1b87d(uint256 _0x08f856) external _0x0b25bc {
        _0xfea910 = _0x08f856;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function _0x9a8c62(address _0xd4854c) external _0x0b25bc {
        require(_0xd4854c != address(0), "Invalid swapper");
        address _0x349373 = address(_0x519653);
        if (1 == 1) { _0x519653 = ISwapper(_0xd4854c); }
        emit SwapperUpdated(_0x349373, _0xd4854c);
    }

    /**
     * @notice Set the team address
     */
    function _0x6aebc6(address _0xe3248a) external _0x0b25bc {
        require(_0xe3248a != address(0), "Invalid team");
        Team = _0xe3248a;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function _0x5b5d7c(address _0x2d93cd) external _0xe55088 {
        delete _0x2b4298[_0x2d93cd];
        _0xd4de7b[_0x2d93cd] = 0;
        emit EmergencyUnlock(_0x2d93cd);
    }

    /**
     * @notice Get user's locks info
     */
    function _0x15efa1(address _0x2d93cd) external view returns (UserLock[] memory) {
        return _0x2b4298[_0x2d93cd];
    }

    /**
     * @notice Set operator address
     */
    function _0xe7876c(address _0x3d3b19) external _0x0b25bc {
        require(_0x3d3b19 != address(0), "Invalid operator");
        address _0x58ef1b = _0xeb35c7;
        _0xeb35c7 = _0x3d3b19;
        emit OperatorUpdated(_0x58ef1b, _0x3d3b19);
    }

    /**
     * @notice Get veNFT lock end time
     */
    function _0xe04960() external view returns (uint256) {
        if (_0x69621a == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x1a61c6 = IVotingEscrow(_0xbaecfc)._0x1a61c6(_0x69621a);
        return uint256(_0x1a61c6._0x4778ef);
    }

    /**
     * @notice Internal helper to safely extend lock to maximum duration
     * @dev Calculates exact duration needed to reach max allowed unlock time
     */
    function _0x908ae7() internal {
        if (_0x69621a == 0) return;

        IVotingEscrow.LockedBalance memory _0x1a61c6 = IVotingEscrow(_0xbaecfc)._0x1a61c6(_0x69621a);
        if (_0x1a61c6._0xe0e480 || _0x1a61c6._0x4778ef <= block.timestamp) return;

        uint256 _0x2044a9 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (_0x2044a9 > _0x1a61c6._0x4778ef + 2 hours) {
            try IVotingEscrow(_0xbaecfc)._0x899a9a(_0x69621a, HybraTimeLibrary.MAX_LOCK_DURATION) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}