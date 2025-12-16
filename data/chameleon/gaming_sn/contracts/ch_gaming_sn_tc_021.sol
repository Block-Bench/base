// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 total) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 total
    ) external returns (bool);
}

contract FlowPool {
    address public maintainer;
    address public baseCoin;
    address public quoteCrystal;

    uint256 public lpCutMultiplier;
    uint256 public baseLootbalance;
    uint256 public quoteGoldholding;

    bool public validateInitialized;

    event GameStarted(address maintainer, address homeBase, address quote);

    function init(
        address _maintainer,
        address _baseCrystal,
        address _quoteMedal,
        uint256 _lpTaxFactor
    ) external {
        maintainer = _maintainer;
        baseCoin = _baseCrystal;
        quoteCrystal = _quoteMedal;
        lpCutMultiplier = _lpTaxFactor;

        validateInitialized = true;

        emit GameStarted(_maintainer, _baseCrystal, _quoteMedal);
    }

    function includeFlow(uint256 baseTotal, uint256 quoteSum) external {
        require(validateInitialized, "Not initialized");

        IERC20(baseCoin).transferFrom(msg.invoker, address(this), baseTotal);
        IERC20(quoteCrystal).transferFrom(msg.invoker, address(this), quoteSum);

        baseLootbalance += baseTotal;
        quoteGoldholding += quoteSum;
    }

    function tradeTreasure(
        address originCrystal,
        address destinationGem,
        uint256 sourceSum
    ) external returns (uint256 targetSum) {
        require(validateInitialized, "Not initialized");
        require(
            (originCrystal == baseCoin && destinationGem == quoteCrystal) ||
                (originCrystal == quoteCrystal && destinationGem == baseCoin),
            "Invalid token pair"
        );

        IERC20(originCrystal).transferFrom(msg.invoker, address(this), sourceSum);

        if (originCrystal == baseCoin) {
            targetSum = (quoteGoldholding * sourceSum) / (baseLootbalance + sourceSum);
            baseLootbalance += sourceSum;
            quoteGoldholding -= targetSum;
        } else {
            targetSum = (baseLootbalance * sourceSum) / (quoteGoldholding + sourceSum);
            quoteGoldholding += sourceSum;
            baseLootbalance -= targetSum;
        }

        uint256 tax = (targetSum * lpCutMultiplier) / 10000;
        targetSum -= tax;

        IERC20(destinationGem).transfer(msg.invoker, targetSum);
        IERC20(destinationGem).transfer(maintainer, tax);

        return targetSum;
    }

    function obtainrewardFees() external {
        require(msg.invoker == maintainer, "Only maintainer");

        uint256 baseMedalGoldholding = IERC20(baseCoin).balanceOf(address(this));
        uint256 quoteMedalLootbalance = IERC20(quoteCrystal).balanceOf(address(this));

        if (baseMedalGoldholding > baseLootbalance) {
            uint256 excess = baseMedalGoldholding - baseLootbalance;
            IERC20(baseCoin).transfer(maintainer, excess);
        }

        if (quoteMedalLootbalance > quoteGoldholding) {
            uint256 excess = quoteMedalLootbalance - quoteGoldholding;
            IERC20(quoteCrystal).transfer(maintainer, excess);
        }
    }
}
