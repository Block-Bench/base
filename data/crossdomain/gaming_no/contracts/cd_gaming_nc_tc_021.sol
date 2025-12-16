pragma solidity ^0.8.0;

interface IERC20 {
    function gemtotalOf(address playerAccount) external view returns (uint256);

    function giveItems(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablegoldRewardpool {
    address public maintainer;
    address public baseQuesttoken;
    address public quoteGoldtoken;

    uint256 public lpTributeMultiplier;
    uint256 public baseItemcount;
    uint256 public quoteGoldholding;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseQuesttoken = _baseToken;
        quoteGoldtoken = _quoteToken;
        lpTributeMultiplier = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablegold(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseQuesttoken).sharetreasureFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteGoldtoken).sharetreasureFrom(msg.sender, address(this), quoteAmount);

        baseItemcount += baseAmount;
        quoteGoldholding += quoteAmount;
    }

    function tradeItems(
        address fromRealmcoin,
        address toGamecoin,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromRealmcoin == baseQuesttoken && toGamecoin == quoteGoldtoken) ||
                (fromRealmcoin == quoteGoldtoken && toGamecoin == baseQuesttoken),
            "Invalid token pair"
        );

        IERC20(fromRealmcoin).sharetreasureFrom(msg.sender, address(this), fromAmount);

        if (fromRealmcoin == baseQuesttoken) {
            toAmount = (quoteGoldholding * fromAmount) / (baseItemcount + fromAmount);
            baseItemcount += fromAmount;
            quoteGoldholding -= toAmount;
        } else {
            toAmount = (baseItemcount * fromAmount) / (quoteGoldholding + fromAmount);
            quoteGoldholding += fromAmount;
            baseItemcount -= toAmount;
        }

        uint256 serviceFee = (toAmount * lpTributeMultiplier) / 10000;
        toAmount -= serviceFee;

        IERC20(toGamecoin).giveItems(msg.sender, toAmount);
        IERC20(toGamecoin).giveItems(maintainer, serviceFee);

        return toAmount;
    }

    function collectrewardFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseGoldtokenItemcount = IERC20(baseQuesttoken).gemtotalOf(address(this));
        uint256 quoteQuesttokenItemcount = IERC20(quoteGoldtoken).gemtotalOf(address(this));

        if (baseGoldtokenItemcount > baseItemcount) {
            uint256 excess = baseGoldtokenItemcount - baseItemcount;
            IERC20(baseQuesttoken).giveItems(maintainer, excess);
        }

        if (quoteQuesttokenItemcount > quoteGoldholding) {
            uint256 excess = quoteQuesttokenItemcount - quoteGoldholding;
            IERC20(quoteGoldtoken).giveItems(maintainer, excess);
        }
    }
}