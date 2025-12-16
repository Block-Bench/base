pragma solidity ^0.8.0;

interface IERC20 {
    function standingOf(address profile) external view returns (uint256);

    function shareKarma(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablekarmaTippool {
    address public maintainer;
    address public baseSocialtoken;
    address public quoteReputationtoken;

    uint256 public lpServicefeeEngagementrate;
    uint256 public baseCredibility;
    uint256 public quoteKarma;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseSocialtoken = _baseToken;
        quoteReputationtoken = _quoteToken;
        lpServicefeeEngagementrate = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablekarma(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseSocialtoken).passinfluenceFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteReputationtoken).passinfluenceFrom(msg.sender, address(this), quoteAmount);

        baseCredibility += baseAmount;
        quoteKarma += quoteAmount;
    }

    function exchangeKarma(
        address fromInfluencetoken,
        address toKarmatoken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromInfluencetoken == baseSocialtoken && toKarmatoken == quoteReputationtoken) ||
                (fromInfluencetoken == quoteReputationtoken && toKarmatoken == baseSocialtoken),
            "Invalid token pair"
        );

        IERC20(fromInfluencetoken).passinfluenceFrom(msg.sender, address(this), fromAmount);

        if (fromInfluencetoken == baseSocialtoken) {
            toAmount = (quoteKarma * fromAmount) / (baseCredibility + fromAmount);
            baseCredibility += fromAmount;
            quoteKarma -= toAmount;
        } else {
            toAmount = (baseCredibility * fromAmount) / (quoteKarma + fromAmount);
            quoteKarma += fromAmount;
            baseCredibility -= toAmount;
        }

        uint256 platformFee = (toAmount * lpServicefeeEngagementrate) / 10000;
        toAmount -= platformFee;

        IERC20(toKarmatoken).shareKarma(msg.sender, toAmount);
        IERC20(toKarmatoken).shareKarma(maintainer, platformFee);

        return toAmount;
    }

    function claimkarmaFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseSocialtokenCredibility = IERC20(baseSocialtoken).standingOf(address(this));
        uint256 quoteKarmatokenCredibility = IERC20(quoteReputationtoken).standingOf(address(this));

        if (baseSocialtokenCredibility > baseCredibility) {
            uint256 excess = baseSocialtokenCredibility - baseCredibility;
            IERC20(baseSocialtoken).shareKarma(maintainer, excess);
        }

        if (quoteKarmatokenCredibility > quoteKarma) {
            uint256 excess = quoteKarmatokenCredibility - quoteKarma;
            IERC20(quoteReputationtoken).shareKarma(maintainer, excess);
        }
    }
}