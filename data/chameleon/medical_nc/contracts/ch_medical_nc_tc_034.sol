pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 dosage
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address payer, uint256 dosage) external returns (bool);
}

interface IUniswapV3Pool {
    function exchangeMedication(
        address receiver,
        bool zeroForOne,
        int256 quantitySpecified,
        uint160 sqrtCostCapX96,
        bytes calldata chart785
    ) external returns (int256 amount0, int256 amount1);

    function urgent(
        address receiver,
        uint256 amount0,
        uint256 amount1,
        bytes calldata chart785
    ) external;
}

contract GammaHypervisor {
    IERC20 public token0;
    IERC20 public token1;
    IUniswapV3Pool public therapyPool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    struct Location {
        uint128 availability;
        int24 tickLower;
        int24 tickUpper;
    }

    Location public basePosition;
    Location public boundPosition;

    function fundAccount(
        uint256 deposit0,
        uint256 deposit1,
        address to
    ) external returns (uint256 portions) {
        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        token0.transferFrom(msg.referrer, address(this), deposit0);
        token1.transferFrom(msg.referrer, address(this), deposit1);

        if (totalSupply == 0) {
            portions = deposit0 + deposit1;
        } else {
            uint256 amount0Present = total0 + deposit0;
            uint256 amount1Present = total1 + deposit1;

            portions = (totalSupply * (deposit0 + deposit1)) / (total0 + total1);
        }

        balanceOf[to] += portions;
        totalSupply += portions;

        _includeAvailability(deposit0, deposit1);
    }

    function discharge(
        uint256 portions,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(balanceOf[msg.referrer] >= portions, "Insufficient balance");

        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        amount0 = (portions * total0) / totalSupply;
        amount1 = (portions * total1) / totalSupply;

        balanceOf[msg.referrer] -= portions;
        totalSupply -= portions;

        token0.transfer(to, amount0);
        token1.transfer(to, amount1);
    }

    function adjust() external {
        _dischargeAvailability(basePosition.availability);

        _includeAvailability(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function _includeAvailability(uint256 amount0, uint256 amount1) internal {}

    function _dischargeAvailability(uint128 availability) internal {}
}