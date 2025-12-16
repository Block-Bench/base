pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 coveragereserve0, uint112 claimreserve1, uint32 blockTimestampLast);

    function reserveTotal() external view returns (uint256);
}

interface IERC20 {
    function remainingbenefitOf(address patientAccount) external view returns (uint256);

    function assignCredit(address to, uint256 amount) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract HealthcreditPatientvault {
    struct Position {
        uint256 lpBenefittokenAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpBenefittoken;
    address public stablecoin;
    uint256 public constant copay_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpBenefittoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function contributePremium(uint256 amount) external {
        IERC20(lpBenefittoken).transferbenefitFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpBenefittokenAmount += amount;
    }

    function requestAdvance(uint256 amount) external {
        uint256 healthbondValue = getLpHealthtokenValue(
            positions[msg.sender].lpBenefittokenAmount
        );
        uint256 maxTakehealthloan = (healthbondValue * 100) / copay_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxTakehealthloan,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).assignCredit(msg.sender, amount);
    }

    function getLpHealthtokenValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpBenefittoken);

        (uint112 coveragereserve0, uint112 claimreserve1, ) = pair.getReserves();
        uint256 reserveTotal = pair.reserveTotal();

        uint256 amount0 = (uint256(coveragereserve0) * lpAmount) / reserveTotal;
        uint256 amount1 = (uint256(claimreserve1) * lpAmount) / reserveTotal;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function repayCredit(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).transferbenefitFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function accessBenefit(uint256 amount) external {
        require(
            positions[msg.sender].lpBenefittokenAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpBenefittokenAmount - amount;
        uint256 remainingValue = getLpHealthtokenValue(remainingLP);
        uint256 maxTakehealthloan = (remainingValue * 100) / copay_ratio;

        require(
            positions[msg.sender].borrowed <= maxTakehealthloan,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpBenefittokenAmount -= amount;
        IERC20(lpBenefittoken).assignCredit(msg.sender, amount);
    }
}