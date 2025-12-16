pragma solidity ^0.8.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


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

contract BedrockVault  is ReentrancyGuard {
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

    function mint() external payable nonReentrant {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBTCAmount = msg.value;

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;

        uniBTC.transfer(msg.sender, uniBTCAmount);
    }

    function redeem(uint256 amount) external nonReentrant {
        require(amount > 0, "No amount specified");
        require(uniBTC.balanceOf(msg.sender) >= amount, "Insufficient balance");

        uniBTC.transferFrom(msg.sender, address(this), amount);

        uint256 ethAmount = amount;
        require(address(this).balance >= ethAmount, "Insufficient ETH");

        payable(msg.sender).transfer(ethAmount);
    }

    function getExchangeRate() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}