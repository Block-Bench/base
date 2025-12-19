// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
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

interface IPriceFeed {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract BedrockVault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable router;
    IPriceFeed public immutable ethPriceFeed;
    IPriceFeed public immutable btcPriceFeed;

    uint256 public totalETHDeposited;
    uint256 public totalUniBTCMinted;

    constructor(
        address _uniBTC,
        address _wbtc,
        address _router,
        address _ethPriceFeed,
        address _btcPriceFeed
    ) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        router = IUniswapV3Router(_router);
        ethPriceFeed = IPriceFeed(_ethPriceFeed);
        btcPriceFeed = IPriceFeed(_btcPriceFeed);
    }

    function mint() external payable {
        require(msg.value > 0, "No ETH sent");

        (, int256 ethPrice,,,) = ethPriceFeed.latestRoundData();
        (, int256 btcPrice,,,) = btcPriceFeed.latestRoundData();
        require(ethPrice > 0 && btcPrice > 0, "Invalid price");

        uint256 uniBTCAmount = (msg.value * uint256(ethPrice)) / uint256(btcPrice);

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;

        uniBTC.transfer(msg.sender, uniBTCAmount);
    }

    function redeem(uint256 amount) external {
        require(amount > 0, "No amount specified");
        require(uniBTC.balanceOf(msg.sender) >= amount, "Insufficient balance");

        uniBTC.transferFrom(msg.sender, address(this), amount);

        (, int256 ethPrice,,,) = ethPriceFeed.latestRoundData();
        (, int256 btcPrice,,,) = btcPriceFeed.latestRoundData();
        require(ethPrice > 0 && btcPrice > 0, "Invalid price");

        uint256 ethAmount = (amount * uint256(btcPrice)) / uint256(ethPrice);
        require(address(this).balance >= ethAmount, "Insufficient ETH");

        payable(msg.sender).transfer(ethAmount);
    }

    function getExchangeRate() external view returns (uint256) {
        (, int256 ethPrice,,,) = ethPriceFeed.latestRoundData();
        (, int256 btcPrice,,,) = btcPriceFeed.latestRoundData();
        require(ethPrice > 0 && btcPrice > 0, "Invalid price");
        return (uint256(ethPrice) * 1e18) / uint256(btcPrice);
    }

    receive() external payable {}
}
