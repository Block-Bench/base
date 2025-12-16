// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 claimreserve0, uint112 claimreserve1, uint32 blockTimestampLast);

    function pooledBenefits() external view returns (uint256);
}

interface IERC20 {
    function benefitsOf(address coverageProfile) external view returns (uint256);

    function transferBenefit(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BenefitadvanceCoveragevault {
    struct Position {
        uint256 lpHealthtokenAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpCoveragetoken;
    address public stablecoin;
    uint256 public constant copay_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpCoveragetoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function payPremium(uint256 amount) external {
        IERC20(lpCoveragetoken).movecoverageFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpHealthtokenAmount += amount;
    }

    function accessCredit(uint256 amount) external {
        uint256 copayValue = getLpMedicalcreditValue(
            positions[msg.sender].lpHealthtokenAmount
        );
        uint256 maxTakehealthloan = (copayValue * 100) / copay_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxTakehealthloan,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).transferBenefit(msg.sender, amount);
    }

    function getLpMedicalcreditValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpCoveragetoken);

        (uint112 claimreserve0, uint112 claimreserve1, ) = pair.getReserves();
        uint256 pooledBenefits = pair.pooledBenefits();

        uint256 amount0 = (uint256(claimreserve0) * lpAmount) / pooledBenefits;
        uint256 amount1 = (uint256(claimreserve1) * lpAmount) / pooledBenefits;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function clearDebt(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).movecoverageFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function withdrawFunds(uint256 amount) external {
        require(
            positions[msg.sender].lpHealthtokenAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpHealthtokenAmount - amount;
        uint256 remainingValue = getLpMedicalcreditValue(remainingLP);
        uint256 maxTakehealthloan = (remainingValue * 100) / copay_ratio;

        require(
            positions[msg.sender].borrowed <= maxTakehealthloan,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpHealthtokenAmount -= amount;
        IERC20(lpCoveragetoken).transferBenefit(msg.sender, amount);
    }
}
