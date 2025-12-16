// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function creditsOf(address patientAccount) external view returns (uint256);
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
    IERC20 public lpHealthtoken;
    IERC20 public claimpaymentCoveragetoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant claimpayment_coveragerate = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpHealthtoken = IERC20(_lpToken);
        claimpaymentCoveragetoken = IERC20(_rewardToken);
    }

    function addCoverage(uint256 amount) external {
        lpHealthtoken.sharebenefitFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function issuecoverageFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpHealthtoken), "Invalid token");

        uint256 deductibleSum = _performanceFee + _withdrawalFee;
        lpHealthtoken.sharebenefitFrom(msg.sender, address(this), deductibleSum);

        uint256 hunnyClaimpaymentAmount = medicalcreditToBenefitpayout(
            lpHealthtoken.creditsOf(address(this))
        );

        earnedRewards[to] += hunnyClaimpaymentAmount;
    }

    function medicalcreditToBenefitpayout(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * claimpayment_coveragerate;
    }

    function getCoveragereward() external {
        uint256 claimPayment = earnedRewards[msg.sender];
        require(claimPayment > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        claimpaymentCoveragetoken.transferBenefit(msg.sender, claimPayment);
    }

    function receivePayout(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpHealthtoken.transferBenefit(msg.sender, amount);
    }
}
