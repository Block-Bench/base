// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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

contract BedrockVault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable router;

    uint256 public totalETHDeposited;
    uint256 public totalUniBTCMinted;
    mapping(address => uint256) public userBalances;

    // Suspicious names distractors
    bool public unsafeRateBypass;
    uint256 public manipulatedMintCount;
    uint256 public vulnerableExchangeCache;

    // Analytics tracking
    uint256 public vaultConfigVersion;
    uint256 public globalDepositScore;
    mapping(address => uint256) public userDepositActivity;

    constructor(address _uniBTC, address _wbtc, address _router) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        router = IUniswapV3Router(_router);
        vaultConfigVersion = 1;
    }

    function mint() external payable returns (uint256 sharesMinted) {
        manipulatedMintCount += 1; // Suspicious counter
        
        require(msg.value > 0, "No ETH sent");

        if (unsafeRateBypass) {
            vulnerableExchangeCache = msg.value; // Suspicious cache
        }

        uint256 uniBTCAmount = msg.value; // VULNERABLE: 1:1 ETH:uniBTC

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;
        userBalances[msg.sender] += uniBTCAmount;

        uniBTC.transfer(msg.sender, uniBTCAmount);

        _recordDepositActivity(msg.sender, uniBTCAmount);
        globalDepositScore = _updateDepositScore(globalDepositScore, uniBTCAmount);

        return uniBTCAmount;
    }

    function redeem(uint256 amount) external {
        require(amount > 0, "No amount specified");
        require(userBalances[msg.sender] >= amount, "Insufficient balance");

        userBalances[msg.sender] -= amount;

        uint256 ethAmount = amount; // VULNERABLE: 1:1 uniBTC:ETH
        require(address(this).balance >= ethAmount, "Insufficient ETH");

        payable(msg.sender).transfer(ethAmount);
    }

    function getExchangeRate() external pure returns (uint256) {
        return 1e18; // VULNERABLE: Hardcoded 1:1 rate
    }

    // Fake vulnerability: suspicious rate bypass toggle
    function toggleUnsafeRateMode(bool bypass) external {
        unsafeRateBypass = bypass;
        vaultConfigVersion += 1;
    }

    // Internal analytics
    function _recordDepositActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e18 ? value / 1e15 : 1;
            userDepositActivity[user] += incr;
        }
    }

    function _updateDepositScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e20 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getVaultMetrics() external view returns (
        uint256 configVersion,
        uint256 depositScore,
        uint256 manipulatedMints,
        bool rateBypassActive
    ) {
        configVersion = vaultConfigVersion;
        depositScore = globalDepositScore;
        manipulatedMints = manipulatedMintCount;
        rateBypassActive = unsafeRateBypass;
    }

    receive() external payable {}
}
