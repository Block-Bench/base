// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    // Suspicious names distractors
    bool public unsafeRateBypass;
    uint256 public maliciousRateCount;
    uint256 public vulnerableExchangeCache;

    // Analytics tracking
    uint256 public marketConfigVersion;
    uint256 public globalRateScore;
    mapping(address => uint256) public userRateActivity;

    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);
    event RateCalculated(uint256 exchangeRate, uint256 timestamp);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    // VULNERABILITY PRESERVED: Unprotected TWAP-less exchangeRate()
    function exchangeRate() public view returns (uint256) {  // Fixed lines 54-57
        if (totalSupply == 0) {
            return 1e18;
        }

        uint256 cash = underlying.balanceOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        uint256 rate = (totalUnderlying * 1e18) / totalSupply;

        // Removed state-modifying lines to maintain 'view' validity
        // if (unsafeRateBypass) {
        //     vulnerableExchangeCache = uint256(keccak256(abi.encode(cash, totalUnderlying, rate)));
        // }
        // emit RateCalculated(rate, block.timestamp);

        return rate;
    }

    function mint(uint256 mintAmount) external returns (uint256) {
        require(mintAmount > 0, "Zero mint");

        maliciousRateCount += 1;

        uint256 exchangeRateMantissa = exchangeRate();

        uint256 mintTokens = (mintAmount * 1e18) / exchangeRateMantissa;

        totalSupply += mintTokens;
        balanceOf[msg.sender] += mintTokens;

        underlying.transferFrom(msg.sender, address(this), mintAmount);

        _recordRateActivity(msg.sender, mintAmount);
        globalRateScore = _updateRateScore(globalRateScore, mintAmount);

        emit Mint(msg.sender, mintAmount, mintTokens);
        return mintTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(balanceOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeRateMantissa = exchangeRate();

        uint256 redeemAmount = (redeemTokens * exchangeRateMantissa) / 1e18;

        balanceOf[msg.sender] -= redeemTokens;
        totalSupply -= redeemTokens;

        underlying.transfer(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function balanceOfUnderlying(address account) external view returns (uint256) {
        uint256 exchangeRateMantissa = exchangeRate();
        return (balanceOf[account] * exchangeRateMantissa) / 1e18;
    }

    function toggleUnsafeRateMode(bool bypass) external {
        unsafeRateBypass = bypass;
        marketConfigVersion += 1;
    }

    function _recordRateActivity(address user, uint256 amount) internal {
        uint256 incr = amount > 1e18 ? amount / 1e16 : 1;
        userRateActivity[user] += incr;
    }

    function _updateRateScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e20 ? 3 : 1;
        if (current == 0) return weight;
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e28 ? 1e28 : newScore;
    }

    function getMarketMetrics() external view returns (
        uint256 configVersion,
        uint256 rateScore,
        uint256 maliciousRates,
        bool rateBypassActive,
        uint256 currentRate
    ) {
        configVersion = marketConfigVersion;
        rateScore = globalRateScore;
        maliciousRates = maliciousRateCount;
        rateBypassActive = unsafeRateBypass;
        currentRate = exchangeRate();
    }
}
