pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract RewardMinter {
    IERC20 public lpToken;
    IERC20 public rewardToken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant REWARD_RATE = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
    }

    function deposit(uint256 amount) external {
        lpToken.transferFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function mintFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpToken), "Invalid token");

        uint256 feeSum = _performanceFee + _withdrawalFee;
        lpToken.transferFrom(msg.sender, address(this), feeSum);

        uint256 hunnyRewardAmount = tokenToReward(
            lpToken.balanceOf(address(this))
        );

        earnedRewards[to] += hunnyRewardAmount;
    }

    function tokenToReward(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * REWARD_RATE;
    }

    function getReward() external {
        uint256 reward = earnedRewards[msg.sender];
        require(reward > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
    }

    function withdraw(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpToken.transfer(msg.sender, amount);
    }

    // Unified dispatcher - merged from: mintFor
    // Selectors: mintFor=0
    function execute(uint8 _selector, address flip, address to, uint256 , uint256 _performanceFee, uint256 _withdrawalFee) public {
        // Original: mintFor()
        if (_selector == 0) {
            require(flip == address(lpToken), "Invalid token");
            uint256 feeSum = _performanceFee + _withdrawalFee;
            lpToken.transferFrom(msg.sender, address(this), feeSum);
            uint256 hunnyRewardAmount = tokenToReward(
            lpToken.balanceOf(address(this))
            );
            earnedRewards[to] += hunnyRewardAmount;
        }
    }
}