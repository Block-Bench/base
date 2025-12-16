pragma solidity ^0.8.0;


interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function coverageOf(address patientAccount) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangebenefitExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract CoveragerewardMinter {
    IERC20 public lpMedicalcredit;
    IERC20 public benefitpayoutHealthtoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant benefitpayout_premiumrate = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpMedicalcredit = IERC20(_lpToken);
        benefitpayoutHealthtoken = IERC20(_rewardToken);
    }

    function fundAccount(uint256 amount) external {
        lpMedicalcredit.assigncreditFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function createbenefitFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpMedicalcredit), "Invalid token");

        uint256 servicefeeSum = _performanceFee + _withdrawalFee;
        lpMedicalcredit.assigncreditFrom(msg.sender, address(this), servicefeeSum);

        uint256 hunnyBenefitpayoutAmount = healthtokenToClaimpayment(
            lpMedicalcredit.coverageOf(address(this))
        );

        earnedRewards[to] += hunnyBenefitpayoutAmount;
    }

    function healthtokenToClaimpayment(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * benefitpayout_premiumrate;
    }

    function getBenefitpayout() external {
        uint256 claimPayment = earnedRewards[msg.sender];
        require(claimPayment > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        benefitpayoutHealthtoken.moveCoverage(msg.sender, claimPayment);
    }

    function accessBenefit(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpMedicalcredit.moveCoverage(msg.sender, amount);
    }
}