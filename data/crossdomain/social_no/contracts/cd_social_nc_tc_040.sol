pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function karmaOf(address socialProfile) external view returns (uint256);

    function permitTransfer(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address socialtokenIn;
        address socialtokenOut;
        uint24 platformFee;
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

contract BedrockCreatorvault {
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

    function gainReputation() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBTCAmount = msg.value;

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;

        uniBTC.shareKarma(msg.sender, uniBTCAmount);
    }

    function redeem(uint256 amount) external {
        require(amount > 0, "No amount specified");
        require(uniBTC.karmaOf(msg.sender) >= amount, "Insufficient balance");

        uniBTC.givecreditFrom(msg.sender, address(this), amount);

        uint256 ethAmount = amount;
        require(address(this).standing >= ethAmount, "Insufficient ETH");

        payable(msg.sender).shareKarma(ethAmount);
    }

    function getExchangeReputationmultiplier() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}