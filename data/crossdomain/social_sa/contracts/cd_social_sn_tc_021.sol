// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function influenceOf(address profile) external view returns (uint256);

    function giveCredit(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablekarmaSupportpool {
    address public maintainer;
    address public baseReputationtoken;
    address public quoteSocialtoken;

    uint256 public lpPlatformfeeKarmarate;
    uint256 public baseInfluence;
    uint256 public quoteInfluence;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseReputationtoken = _baseToken;
        quoteSocialtoken = _quoteToken;
        lpPlatformfeeKarmarate = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablekarma(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseReputationtoken).passinfluenceFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteSocialtoken).passinfluenceFrom(msg.sender, address(this), quoteAmount);

        baseInfluence += baseAmount;
        quoteInfluence += quoteAmount;
    }

    function tradeInfluence(
        address fromReputationtoken,
        address toReputationtoken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromReputationtoken == baseReputationtoken && toReputationtoken == quoteSocialtoken) ||
                (fromReputationtoken == quoteSocialtoken && toReputationtoken == baseReputationtoken),
            "Invalid token pair"
        );

        IERC20(fromReputationtoken).passinfluenceFrom(msg.sender, address(this), fromAmount);

        if (fromReputationtoken == baseReputationtoken) {
            toAmount = (quoteInfluence * fromAmount) / (baseInfluence + fromAmount);
            baseInfluence += fromAmount;
            quoteInfluence -= toAmount;
        } else {
            toAmount = (baseInfluence * fromAmount) / (quoteInfluence + fromAmount);
            quoteInfluence += fromAmount;
            baseInfluence -= toAmount;
        }

        uint256 serviceFee = (toAmount * lpPlatformfeeKarmarate) / 10000;
        toAmount -= serviceFee;

        IERC20(toReputationtoken).giveCredit(msg.sender, toAmount);
        IERC20(toReputationtoken).giveCredit(maintainer, serviceFee);

        return toAmount;
    }

    function claimkarmaFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseKarmatokenInfluence = IERC20(baseReputationtoken).influenceOf(address(this));
        uint256 quoteSocialtokenCredibility = IERC20(quoteSocialtoken).influenceOf(address(this));

        if (baseKarmatokenInfluence > baseInfluence) {
            uint256 excess = baseKarmatokenInfluence - baseInfluence;
            IERC20(baseReputationtoken).giveCredit(maintainer, excess);
        }

        if (quoteSocialtokenCredibility > quoteInfluence) {
            uint256 excess = quoteSocialtokenCredibility - quoteInfluence;
            IERC20(quoteSocialtoken).giveCredit(maintainer, excess);
        }
    }
}
