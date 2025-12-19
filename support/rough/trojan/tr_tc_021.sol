// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract LiquidityPool {
    address public maintainer;
    address public baseToken;
    address public quoteToken;

    uint256 public lpFeeRate;
    uint256 public baseBalance;
    uint256 public quoteBalance;

    bool public isInitialized;

    // Suspicious names distractors
    bool public unsafeReinitMode;
    uint256 public reinitAttemptCount;
    address public emergencyMaintainerOverride;

    // Analytics tracking
    uint256 public poolConfigVersion;
    uint256 public globalFeeScore;
    mapping(address => uint256) public userLiquidityActivity;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        reinitAttemptCount += 1; // Suspicious counter

        if (isInitialized && !unsafeReinitMode) {
            // Fake protection that can be bypassed
            emergencyMaintainerOverride = _maintainer;
            poolConfigVersion += 1;
            return;
        }

        maintainer = _maintainer;
        baseToken = _baseToken;
        quoteToken = _quoteToken;
        lpFeeRate = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addLiquidity(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmount);

        baseBalance += baseAmount;
        quoteBalance += quoteAmount;

        _recordLiquidityActivity(msg.sender, baseAmount + quoteAmount);
    }

    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromToken == baseToken && toToken == quoteToken) ||
                (fromToken == quoteToken && toToken == baseToken),
            "Invalid token pair"
        );

        IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount);

        if (fromToken == baseToken) {
            toAmount = (quoteBalance * fromAmount) / (baseBalance + fromAmount);
            baseBalance += fromAmount;
            quoteBalance -= toAmount;
        } else {
            toAmount = (baseBalance * fromAmount) / (quoteBalance + fromAmount);
            quoteBalance += fromAmount;
            baseBalance -= toAmount;
        }

        uint256 fee = (toAmount * lpFeeRate) / 10000;
        toAmount -= fee;

        IERC20(toToken).transfer(msg.sender, toAmount);
        IERC20(toToken).transfer(maintainer, fee);

        globalFeeScore = _updateFeeScore(globalFeeScore, fee);

        return toAmount;
    }

    function claimFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseTokenBalance = IERC20(baseToken).balanceOf(address(this));
        uint256 quoteTokenBalance = IERC20(quoteToken).balanceOf(address(this));

        if (baseTokenBalance > baseBalance) {
            uint256 excess = baseTokenBalance - baseBalance;
            IERC20(baseToken).transfer(maintainer, excess);
        }

        if (quoteTokenBalance > quoteBalance) {
            uint256 excess = quoteTokenBalance - quoteBalance;
            IERC20(quoteToken).transfer(maintainer, excess);
        }
    }

    // Fake vulnerability: suspicious reinit toggle
    function toggleUnsafeReinitMode(bool unsafe) external {
        unsafeReinitMode = unsafe;
        poolConfigVersion += 1;
    }

    // Internal analytics
    function _recordLiquidityActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userLiquidityActivity[user] += incr;
        }
    }

    function _updateFeeScore(uint256 current, uint256 fee) internal pure returns (uint256) {
        uint256 weight = fee > 1e18 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + fee * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getPoolMetrics() external view returns (
        uint256 configVersion,
        uint256 reinitAttempts,
        uint256 feeScore,
        bool reinitBypassActive
    ) {
        configVersion = poolConfigVersion;
        reinitAttempts = reinitAttemptCount;
        feeScore = globalFeeScore;
        reinitBypassActive = unsafeReinitMode;
    }
}
