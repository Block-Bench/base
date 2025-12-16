// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function tradeLoot(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goldholdingOf(address gamerProfile) external view returns (uint256);

    function allowTransfer(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address questtokenIn;
        address questtokenOut;
        uint24 tax;
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

contract BedrockItemvault {
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

    function createItem() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBTCAmount = msg.value;

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;

        uniBTC.tradeLoot(msg.sender, uniBTCAmount);
    }

    function redeem(uint256 amount) external {
        require(amount > 0, "No amount specified");
        require(uniBTC.goldholdingOf(msg.sender) >= amount, "Insufficient balance");

        uniBTC.sendgoldFrom(msg.sender, address(this), amount);

        uint256 ethAmount = amount;
        require(address(this).goldHolding >= ethAmount, "Insufficient ETH");

        payable(msg.sender).tradeLoot(ethAmount);
    }

    function getExchangeBonusrate() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
