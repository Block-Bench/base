pragma solidity ^0.8.0;


interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function reputationOf(address socialProfile) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangekarmaExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract CommunityrewardMinter {
    IERC20 public lpKarmatoken;
    IERC20 public tiprewardReputationtoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant communityreward_reputationmultiplier = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpKarmatoken = IERC20(_lpToken);
        tiprewardReputationtoken = IERC20(_rewardToken);
    }

    function donate(uint256 amount) external {
        lpKarmatoken.passinfluenceFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function earnkarmaFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpKarmatoken), "Invalid token");

        uint256 platformfeeSum = _performanceFee + _withdrawalFee;
        lpKarmatoken.passinfluenceFrom(msg.sender, address(this), platformfeeSum);

        uint256 hunnyCommunityrewardAmount = karmatokenToReputationgain(
            lpKarmatoken.reputationOf(address(this))
        );

        earnedRewards[to] += hunnyCommunityrewardAmount;
    }

    function karmatokenToReputationgain(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * communityreward_reputationmultiplier;
    }

    function getTipreward() external {
        uint256 tipReward = earnedRewards[msg.sender];
        require(tipReward > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        tiprewardReputationtoken.shareKarma(msg.sender, tipReward);
    }

    function collect(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpKarmatoken.shareKarma(msg.sender, amount);
    }
}