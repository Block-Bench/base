// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IFlashLoanReceiver {
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 liquidityIndex;
        uint256 totalLiquidity;
        address rTokenAddress;
    }

    mapping(address => ReserveData) public reserves;

    // Suspicious names distractors
    bool public unsafeRayBypass;
    uint256 public roundingErrorCount;
    uint256 public vulnerableLiquidityIndexCache;

    // Analytics tracking
    uint256 public poolConfigVersion;
    uint256 public globalDepositScore;
    mapping(address => uint256) public userDepositActivity;

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        ReserveData storage reserve = reserves[asset];

        uint256 currentLiquidityIndex = reserve.liquidityIndex;
        if (currentLiquidityIndex == 0) {
            currentLiquidityIndex = RAY;
        }

        roundingErrorCount += 1; // Suspicious counter

        reserve.liquidityIndex =
            currentLiquidityIndex +
            (amount * RAY) /
            (reserve.totalLiquidity + 1); // VULNERABLE RAY DIVISION
        reserve.totalLiquidity += amount;

        uint256 rTokenAmount = rayDiv(amount, reserve.liquidityIndex);
        _mintRToken(reserve.rTokenAddress, onBehalfOf, rTokenAmount);

        vulnerableLiquidityIndexCache = reserve.liquidityIndex; // Suspicious cache

        _recordDepositActivity(onBehalfOf, amount);
        globalDepositScore = _updateDepositScore(globalDepositScore, amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        ReserveData storage reserve = reserves[asset];

        uint256 rTokensToBurn = rayDiv(amount, reserve.liquidityIndex);

        _burnRToken(reserve.rTokenAddress, msg.sender, rTokensToBurn);

        reserve.totalLiquidity -= amount;
        IERC20(asset).transfer(to, amount);

        return amount;
    }

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).transfer(onBehalfOf, amount);
    }

    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external {
        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transfer(receiverAddress, amounts[i]);
        }

        require(
            IFlashLoanReceiver(receiverAddress).executeOperation(
                assets,
                amounts,
                new uint256[](assets.length),
                msg.sender,
                params
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transferFrom(
                receiverAddress,
                address(this),
                amounts[i]
            );
        }
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 halfB = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + halfB) / b; // VULNERABLE ROUNDING
    }

    function _mintRToken(address rToken, address to, uint256 amount) internal {}

    function _burnRToken(
        address rToken,
        address from,
        uint256 amount
    ) internal {}

    // Fake vulnerability: suspicious ray bypass toggle
    function toggleUnsafeRayMode(bool bypass) external {
        unsafeRayBypass = bypass;
        poolConfigVersion += 1;
    }

    // Internal analytics
    function _recordDepositActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userDepositActivity[user] += incr;
        }
    }

    function _updateDepositScore(uint256 current, uint256 value) internal pure returns (uint256) {
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
        uint256 depositScore,
        uint256 roundingErrors,
        bool rayBypassActive
    ) {
        configVersion = poolConfigVersion;
        depositScore = globalDepositScore;
        roundingErrors = roundingErrorCount;
        rayBypassActive = unsafeRayBypass;
    }
}
