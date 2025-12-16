// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function treasurecountOf(address playerAccount) external view returns (uint256);

    function tradeLoot(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablegoldPrizepool {
    address public maintainer;
    address public baseGoldtoken;
    address public quoteQuesttoken;

    uint256 public lpTaxRewardfactor;
    uint256 public baseTreasurecount;
    uint256 public quoteTreasurecount;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseGoldtoken = _baseToken;
        quoteQuesttoken = _quoteToken;
        lpTaxRewardfactor = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablegold(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseGoldtoken).sharetreasureFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteQuesttoken).sharetreasureFrom(msg.sender, address(this), quoteAmount);

        baseTreasurecount += baseAmount;
        quoteTreasurecount += quoteAmount;
    }

    function convertGems(
        address fromGoldtoken,
        address toGoldtoken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromGoldtoken == baseGoldtoken && toGoldtoken == quoteQuesttoken) ||
                (fromGoldtoken == quoteQuesttoken && toGoldtoken == baseGoldtoken),
            "Invalid token pair"
        );

        IERC20(fromGoldtoken).sharetreasureFrom(msg.sender, address(this), fromAmount);

        if (fromGoldtoken == baseGoldtoken) {
            toAmount = (quoteTreasurecount * fromAmount) / (baseTreasurecount + fromAmount);
            baseTreasurecount += fromAmount;
            quoteTreasurecount -= toAmount;
        } else {
            toAmount = (baseTreasurecount * fromAmount) / (quoteTreasurecount + fromAmount);
            quoteTreasurecount += fromAmount;
            baseTreasurecount -= toAmount;
        }

        uint256 tribute = (toAmount * lpTaxRewardfactor) / 10000;
        toAmount -= tribute;

        IERC20(toGoldtoken).tradeLoot(msg.sender, toAmount);
        IERC20(toGoldtoken).tradeLoot(maintainer, tribute);

        return toAmount;
    }

    function claimprizeFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseGamecoinTreasurecount = IERC20(baseGoldtoken).treasurecountOf(address(this));
        uint256 quoteQuesttokenItemcount = IERC20(quoteQuesttoken).treasurecountOf(address(this));

        if (baseGamecoinTreasurecount > baseTreasurecount) {
            uint256 excess = baseGamecoinTreasurecount - baseTreasurecount;
            IERC20(baseGoldtoken).tradeLoot(maintainer, excess);
        }

        if (quoteQuesttokenItemcount > quoteTreasurecount) {
            uint256 excess = quoteQuesttokenItemcount - quoteTreasurecount;
            IERC20(quoteQuesttoken).tradeLoot(maintainer, excess);
        }
    }
}
