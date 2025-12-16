pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address user, uint256 sum) external returns (bool);
}

interface IUniswapV3Pool {
    function barterGoods(
        address target,
        bool zeroForOne,
        int256 sumSpecified,
        uint160 sqrtValueBoundX96,
        bytes calldata info
    ) external returns (int256 amount0, int256 amount1);

    function quick(
        address target,
        uint256 amount0,
        uint256 amount1,
        bytes calldata info
    ) external;
}

contract GammaHypervisor {
    IERC20 public token0;
    IERC20 public token1;
    IUniswapV3Pool public rewardPool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    struct Coordinates {
        uint128 flow;
        int24 tickLower;
        int24 tickUpper;
    }

    Coordinates public basePosition;
    Coordinates public capPosition;

    function bankWinnings(
        uint256 deposit0,
        uint256 deposit1,
        address to
    ) external returns (uint256 slices) {
        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        token0.transferFrom(msg.invoker, address(this), deposit0);
        token1.transferFrom(msg.invoker, address(this), deposit1);

        if (totalSupply == 0) {
            slices = deposit0 + deposit1;
        } else {
            uint256 amount0Active = total0 + deposit0;
            uint256 amount1Present = total1 + deposit1;

            slices = (totalSupply * (deposit0 + deposit1)) / (total0 + total1);
        }

        balanceOf[to] += slices;
        totalSupply += slices;

        _appendFlow(deposit0, deposit1);
    }

    function gatherTreasure(
        uint256 slices,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(balanceOf[msg.invoker] >= slices, "Insufficient balance");

        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        amount0 = (slices * total0) / totalSupply;
        amount1 = (slices * total1) / totalSupply;

        balanceOf[msg.invoker] -= slices;
        totalSupply -= slices;

        token0.transfer(to, amount0);
        token1.transfer(to, amount1);
    }

    function adjust() external {
        _deleteReserves(basePosition.flow);

        _appendFlow(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function _appendFlow(uint256 amount0, uint256 amount1) internal {}

    function _deleteReserves(uint128 flow) internal {}
}