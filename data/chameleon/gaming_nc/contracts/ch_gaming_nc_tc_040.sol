pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 sum) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactSubmissionSingleParameters {
        address coinIn;
        address gemOut;
        uint24 tribute;
        address target;
        uint256 timeLimit;
        uint256 quantityIn;
        uint256 measureOutMinimum;
        uint160 sqrtCostCapX96;
    }

    function exactEntrySingle(
        ExactSubmissionSingleParameters calldata settings
    ) external payable returns (uint256 measureOut);
}

contract BedrockVault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable questRouter;

    uint256 public aggregateEthDeposited;
    uint256 public combinedUniBtcMinted;

    constructor(address _uniBTC, address _wbtc, address _router) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        questRouter = IUniswapV3Router(_router);
    }

    function craft() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBtcMeasure = msg.value;

        aggregateEthDeposited += msg.value;
        combinedUniBtcMinted += uniBtcMeasure;

        uniBTC.transfer(msg.sender, uniBtcMeasure);
    }

    function tradeLoot(uint256 sum) external {
        require(sum > 0, "No amount specified");
        require(uniBTC.balanceOf(msg.sender) >= sum, "Insufficient balance");

        uniBTC.transferFrom(msg.sender, address(this), sum);

        uint256 ethMeasure = sum;
        require(address(this).balance >= ethMeasure, "Insufficient ETH");

        payable(msg.sender).transfer(ethMeasure);
    }

    function fetchExchangeRatio() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}