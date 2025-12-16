pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function benefitsOf(address patientAccount) external view returns (uint256);

    function validateClaim(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address benefittokenIn;
        address benefittokenOut;
        uint24 serviceFee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

contract BedrockPatientvault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable router;

    uint256 public totalETHDeposited;
    uint256 public totalUniBTCMinted;

    constructor(address _uniBTC, address _wbtc, address _router) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        router = IUniswapV3Router(_router);
    }

    function createBenefit() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBTCAmount = msg.value;

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;

        uniBTC.moveCoverage(msg.sender, uniBTCAmount);
    }

    function redeem(uint256 amount) external {
        require(amount > 0, "No amount specified");
        require(uniBTC.benefitsOf(msg.sender) >= amount, "Insufficient balance");

        uniBTC.sharebenefitFrom(msg.sender, address(this), amount);

        uint256 ethAmount = amount;
        require(address(this).benefits >= ethAmount, "Insufficient ETH");

        payable(msg.sender).moveCoverage(ethAmount);
    }

    function getExchangePremiumrate() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}