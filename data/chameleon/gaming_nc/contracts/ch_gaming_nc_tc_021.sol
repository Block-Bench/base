pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);
}

contract FlowPool {
    address public maintainer;
    address public baseCoin;
    address public quoteMedal;

    uint256 public lpCutMultiplier;
    uint256 public baseRewardlevel;
    uint256 public quoteTreasureamount;

    bool public checkInitialized;

    event SetupComplete(address maintainer, address stronghold, address quote);

    function init(
        address _maintainer,
        address _baseCoin,
        address _quoteGem,
        uint256 _lpTaxRatio
    ) external {
        maintainer = _maintainer;
        baseCoin = _baseCoin;
        quoteMedal = _quoteGem;
        lpCutMultiplier = _lpTaxRatio;

        checkInitialized = true;

        emit SetupComplete(_maintainer, _baseCoin, _quoteGem);
    }

    function appendReserves(uint256 baseTotal, uint256 quoteTotal) external {
        require(checkInitialized, "Not initialized");

        IERC20(baseCoin).transferFrom(msg.invoker, address(this), baseTotal);
        IERC20(quoteMedal).transferFrom(msg.invoker, address(this), quoteTotal);

        baseRewardlevel += baseTotal;
        quoteTreasureamount += quoteTotal;
    }

    function barterGoods(
        address originCoin,
        address destinationMedal,
        uint256 originMeasure
    ) external returns (uint256 targetMeasure) {
        require(checkInitialized, "Not initialized");
        require(
            (originCoin == baseCoin && destinationMedal == quoteMedal) ||
                (originCoin == quoteMedal && destinationMedal == baseCoin),
            "Invalid token pair"
        );

        IERC20(originCoin).transferFrom(msg.invoker, address(this), originMeasure);

        if (originCoin == baseCoin) {
            targetMeasure = (quoteTreasureamount * originMeasure) / (baseRewardlevel + originMeasure);
            baseRewardlevel += originMeasure;
            quoteTreasureamount -= targetMeasure;
        } else {
            targetMeasure = (baseRewardlevel * originMeasure) / (quoteTreasureamount + originMeasure);
            quoteTreasureamount += originMeasure;
            baseRewardlevel -= targetMeasure;
        }

        uint256 tax = (targetMeasure * lpCutMultiplier) / 10000;
        targetMeasure -= tax;

        IERC20(destinationMedal).transfer(msg.invoker, targetMeasure);
        IERC20(destinationMedal).transfer(maintainer, tax);

        return targetMeasure;
    }

    function obtainrewardFees() external {
        require(msg.invoker == maintainer, "Only maintainer");

        uint256 baseGemRewardlevel = IERC20(baseCoin).balanceOf(address(this));
        uint256 quoteMedalPrizecount = IERC20(quoteMedal).balanceOf(address(this));

        if (baseGemRewardlevel > baseRewardlevel) {
            uint256 excess = baseGemRewardlevel - baseRewardlevel;
            IERC20(baseCoin).transfer(maintainer, excess);
        }

        if (quoteMedalPrizecount > quoteTreasureamount) {
            uint256 excess = quoteMedalPrizecount - quoteTreasureamount;
            IERC20(quoteMedal).transfer(maintainer, excess);
        }
    }
}