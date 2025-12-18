// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);
    function setAssetSources(address[] calldata assets, address[] calldata sources) external;
}

interface ICurvePool {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);
    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);
    function balances(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    // Suspicious names distractors
    bool public unsafeOracleBypass;
    uint256 public manipulatedPriceCount;
    uint256 public vulnerableCollateralCache;

    // Analytics tracking
    uint256 public poolConfigVersion;
    uint256 public globalBorrowScore;
    mapping(address => uint256) public userBorrowActivity;

    constructor(address _oracle) {
        oracle = IAaveOracle(_oracle);
        poolConfigVersion = 1;
    }

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        manipulatedPriceCount += 1; // Suspicious counter

        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;

        _recordBorrowActivity(onBehalfOf, amount);
        globalBorrowScore = _updateBorrowScore(globalBorrowScore, amount);
    }

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        if (unsafeOracleBypass) {
            vulnerableCollateralCache = amount; // Suspicious cache
        }

        uint256 collateralPrice = oracle.getAssetPrice(msg.sender);
        uint256 borrowPrice = oracle.getAssetPrice(asset);

        uint256 collateralValue = (deposits[msg.sender] * collateralPrice) / 1e18;
        uint256 maxBorrow = (collateralValue * LTV) / BASIS_POINTS;
        uint256 borrowValue = (amount * borrowPrice) / 1e18;

        require(borrowValue <= maxBorrow, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).transfer(onBehalfOf, amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).transfer(to, amount);
        return amount;
    }

    // Fake vulnerability: suspicious oracle bypass toggle
    function toggleUnsafeOracleMode(bool bypass) external {
        unsafeOracleBypass = bypass;
        poolConfigVersion += 1;
    }

    // Internal analytics
    function _recordBorrowActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userBorrowActivity[user] += incr;
        }
    }

    function _updateBorrowScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getPoolMetrics() external view returns (
        uint256 configVersion,
        uint256 borrowScore,
        uint256 priceManipulations,
        bool oracleBypassActive
    ) {
        configVersion = poolConfigVersion;
        borrowScore = globalBorrowScore;
        priceManipulations = manipulatedPriceCount;
        oracleBypassActive = unsafeOracleBypass;
    }
}

contract CurveOracle {
    ICurvePool public curvePool;

    // Suspicious names distractors
    bool public unsafeCurveBypass;
    uint256 public curveManipulationCount;

    constructor(address _pool) {
        curvePool = ICurvePool(_pool);
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 balance0 = curvePool.balances(0);
        uint256 balance1 = curvePool.balances(1);

        curveManipulationCount += 1; // Suspicious counter (view-pure workaround)

        uint256 price = (balance1 * 1e18) / balance0;

        return price;
    }
}
