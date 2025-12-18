pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/IPair.sol';
import './interfaces/IBribe.sol';
import "./libraries/Math.sol";

import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import './interfaces/IRHYBR.sol';
interface IRewarder {
    function onReward(
        address user,
        address recipient,
        uint256 userBalance
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable isForPair;
    bool public emergency;

    IERC20 public immutable rewardToken;
    IERC20 public immutable TOKEN;
    address public immutable rHYBR;
    address public VE;
    address public DISTRIBUTION;
    address public gaugeRewarder;
    address public internal_bribe;
    address public external_bribe;

    uint256 public DURATION;
    uint256 internal _periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) public maturityTime;

    event RewardAdded(uint256 reward);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 reward);

    event ClaimFees(address indexed from, uint256 claimed0, uint256 claimed1);
    event EmergencyActivated(address indexed gauge, uint256 timestamp);
    event EmergencyDeactivated(address indexed gauge, uint256 timestamp);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyDistribution() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier isNotEmergency() {
        require(emergency == false, "EMER");
        _;
    }

    constructor(address _rewardToken,address _rHYBR,address _ve,address _token,address _distribution, address _internal_bribe, address _external_bribe, bool _isForPair) {
        rewardToken = IERC20(_rewardToken);
        rHYBR = _rHYBR;
        VE = _ve;
        TOKEN = IERC20(_token);
        DISTRIBUTION = _distribution;
        DURATION = HybraTimeLibrary.WEEK;

        internal_bribe = _internal_bribe;
        external_bribe = _external_bribe;

        isForPair = _isForPair;

        emergency = false;

    }


    function setDistribution(address _distribution) external onlyOwner {
        require(_distribution != address(0), "ZA");
        require(_distribution != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _distribution;
    }


    function setGaugeRewarder(address _gaugeRewarder) external onlyOwner {
        require(_gaugeRewarder != gaugeRewarder, "SAME_ADDR");
        gaugeRewarder = _gaugeRewarder;
    }


    function setInternalBribe(address _int) external onlyOwner {
        require(_int >= address(0), "ZA");
        internal_bribe = _int;
    }

    function activateEmergencyMode() external onlyOwner {
        require(emergency == false, "EMER");
        emergency = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function stopEmergencyMode() external onlyOwner {

        require(emergency == true,"EMER");

        emergency = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf(account);
    }

    function _balanceOf(address account) internal view returns (uint256) {

        return _balances[account];
    }


    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, _periodFinish);
    }


    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        } else {
            return rewardPerTokenStored + (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / _totalSupply;
        }
    }


    function earned(address account) public view returns (uint256) {
        return rewards[account] + _balanceOf(account) * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18;
    }


    function rewardForDuration() external view returns (uint256) {
        return rewardRate * DURATION;
    }

    function periodFinish() external view returns (uint256) {
        return _periodFinish;
    }


    function depositAll() external {
        _deposit(TOKEN.balanceOf(msg.sender), msg.sender);
    }


    function deposit(uint256 amount) external {
        _deposit(amount, msg.sender);
    }


    function _deposit(uint256 amount, address account) internal nonReentrant isNotEmergency updateReward(account) {
        require(amount > 0, "ZV");

        _balances[account] = _balances[account] + amount;
        _totalSupply = _totalSupply + amount;
        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onReward(account, account, _balanceOf(account));
        }

        TOKEN.safeTransferFrom(account, address(this), amount);

        emit Deposit(account, amount);
    }


    function withdrawAll() external {
        _withdraw(_balanceOf(msg.sender));
    }


    function withdraw(uint256 amount) external {
        _withdraw(amount);
    }


    function _withdraw(uint256 amount) internal nonReentrant isNotEmergency updateReward(msg.sender) {
        require(amount > 0, "ZV");
        require(_balanceOf(msg.sender) > 0, "ZV");
        require(block.timestamp >= maturityTime[msg.sender], "!MATURE");

        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;

        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onReward(msg.sender, msg.sender,_balanceOf(msg.sender));
        }

        TOKEN.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    function emergencyWithdraw() external nonReentrant {
        require(emergency, "EMER");
        uint256 _amount = _balanceOf(msg.sender);
        require(_amount > 0, "ZV");
        _totalSupply = _totalSupply - _amount;

        _balances[msg.sender] = 0;

        TOKEN.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdrawAmount(uint256 _amount) external nonReentrant {

        require(emergency, "EMER");
        _totalSupply = _totalSupply - _amount;

        _balances[msg.sender] = _balances[msg.sender] - _amount;

        TOKEN.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }


    function withdrawAllAndHarvest(uint8 _redeemType) external {
        _withdraw(_balanceOf(msg.sender));
        getReward(_redeemType);
    }


    function getReward(address _user, uint8 _redeemType) public nonReentrant onlyDistribution updateReward(_user) {
        uint256 reward = rewards[_user];
        if (reward > 0) {
            rewards[_user] = 0;
            IERC20(rewardToken).safeApprove(rHYBR, reward);
            IRHYBR(rHYBR).depostionEmissionsToken(reward);
            IRHYBR(rHYBR).redeemFor(reward, _redeemType, _user);
            emit Harvest(_user, reward);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onReward(_user, _user, _balanceOf(_user));
        }
    }


    function getReward(uint8 _redeemType) public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            IERC20(rewardToken).safeApprove(rHYBR, reward);
            IRHYBR(rHYBR).depostionEmissionsToken(reward);
            IRHYBR(rHYBR).redeemFor(reward, _redeemType, msg.sender);
            emit Harvest(msg.sender, reward);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onReward(msg.sender, msg.sender, _balanceOf(msg.sender));
        }
    }


    function notifyRewardAmount(address token, uint256 reward) external nonReentrant isNotEmergency onlyDistribution updateReward(address(0)) {
        require(token == address(rewardToken), "IA");
        rewardToken.safeTransferFrom(DISTRIBUTION, address(this), reward);

        if (block.timestamp >= _periodFinish) {
            rewardRate = reward / DURATION;
        } else {
            uint256 remaining = _periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / DURATION;
        }


        uint256 balance = rewardToken.balanceOf(address(this));
        require(rewardRate <= balance / DURATION, "REWARD_HIGH");

        lastUpdateTime = block.timestamp;
        _periodFinish = block.timestamp + DURATION;
        emit RewardAdded(reward);
    }

    function claimFees() external nonReentrant returns (uint256 claimed0, uint256 claimed1) {
        return _claimFees();
    }

     function _claimFees() internal returns (uint256 claimed0, uint256 claimed1) {
        if (!isForPair) {
            return (0, 0);
        }
        address _token = address(TOKEN);
        (claimed0, claimed1) = IPair(_token).claimFees();
        if (claimed0 > 0 || claimed1 > 0) {

            uint256 _fees0 = claimed0;
            uint256 _fees1 = claimed1;

            (address _token0, address _token1) = IPair(_token).tokens();

            if (_fees0  > 0) {
                IERC20(_token0).safeApprove(internal_bribe, 0);
                IERC20(_token0).safeApprove(internal_bribe, _fees0);
                IBribe(internal_bribe).notifyRewardAmount(_token0, _fees0);
            }
            if (_fees1  > 0) {
                IERC20(_token1).safeApprove(internal_bribe, 0);
                IERC20(_token1).safeApprove(internal_bribe, _fees1);
                IBribe(internal_bribe).notifyRewardAmount(_token1, _fees1);
            }
            emit ClaimFees(msg.sender, claimed0, claimed1);
        }
    }


    // Unified dispatcher - merged from: emergencyWithdraw, setDistribution
    // Selectors: emergencyWithdraw=0, setDistribution=2
    function execute(uint8 _selector, address _distribution) public {
        // Original: emergencyWithdraw()
        if (_selector == 0) {
            require(emergency, "EMER");
            uint256 _amount = _balanceOf(msg.sender);
            require(_amount > 0, "ZV");
            _totalSupply = _totalSupply - _amount;
            _balances[msg.sender] = 0;
            TOKEN.safeTransfer(msg.sender, _amount);
            emit Withdraw(msg.sender, _amount);
        }
        // Original: setDistribution()
        else if (_selector == 1) {
            require(_distribution != address(0), "ZA");
            require(_distribution != DISTRIBUTION, "SAME_ADDR");
            DISTRIBUTION = _distribution;
        }
    }
}