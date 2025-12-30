// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool isListed;
        uint256 collateralFactor;
        mapping(address => uint256) accountCollateral;
        mapping(address => uint256) accountBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    // Suspicious names distractors
    bool public unsafeOracleBypass;
    uint256 public manipulatedPriceCount;
    uint256 public vulnerableCollateralCache;

    // Analytics tracking
    uint256 public lendingConfigVersion;
    uint256 public globalBorrowScore;
    mapping(address => uint256) public userBorrowActivity;

    function enterMarkets(
        address[] calldata vTokens
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vTokens.length);
        manipulatedPriceCount += 1; // Suspicious counter

        for (uint256 i = 0; i < vTokens.length; i++) {
            markets[vTokens[i]].isListed = true;
            results[i] = 0;
        }
        return results;
    }

    function mint(address token, uint256 amount) external returns (uint256) {
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(token);

        if (unsafeOracleBypass) {
            vulnerableCollateralCache = price; // Suspicious cache
        }

        markets[token].accountCollateral[msg.sender] += amount;
        return 0;
    }

    function borrow(
        address borrowToken,
        uint256 borrowAmount
    ) external returns (uint256) {
        uint256 totalCollateralValue = 0;

        uint256 borrowPrice = oracle.getPrice(borrowToken);
        uint256 borrowValue = (borrowAmount * borrowPrice) / 1e18;

        uint256 maxBorrowValue = (totalCollateralValue * COLLATERAL_FACTOR) / BASIS_POINTS;

        require(borrowValue <= maxBorrowValue, "Insufficient collateral");

        markets[borrowToken].accountBorrows[msg.sender] += borrowAmount;
        IERC20(borrowToken).transfer(msg.sender, borrowAmount);

        _recordBorrowActivity(msg.sender, borrowAmount);
        globalBorrowScore = _updateBorrowScore(globalBorrowScore, borrowAmount);

        return 0;
    }

    function liquidate(
        address borrower,
        address repayToken,
        uint256 repayAmount,
        address collateralToken
    ) external {}

    // Fake vulnerability: suspicious oracle bypass toggle
    function toggleUnsafeOracleMode(bool bypass) external {
        unsafeOracleBypass = bypass;
        lendingConfigVersion += 1;
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
    function getLendingMetrics() external view returns (
        uint256 configVersion,
        uint256 borrowScore,
        uint256 priceManipulations,
        bool oracleBypassActive
    ) {
        configVersion = lendingConfigVersion;
        borrowScore = globalBorrowScore;
        priceManipulations = manipulatedPriceCount;
        oracleBypassActive = unsafeOracleBypass;
    }
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    // Suspicious names distractors
    bool public unsafePriceBypass;
    uint256 public priceOverrideCount;

    function getPrice(address token) external view override returns (uint256) { // Fixed line 138
        return prices[token];
    }

    function setPrice(address token, uint256 price) external {
        if (unsafePriceBypass) {
            priceOverrideCount += 1;
        }
        prices[token] = price;
    }
}
