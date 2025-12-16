// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function creditsOf(address patientAccount) external view returns (uint256);

    function shareBenefit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablebenefitBenefitpool {
    address public maintainer;
    address public baseCoveragetoken;
    address public quoteBenefittoken;

    uint256 public lpCopayReimbursementrate;
    uint256 public baseCredits;
    uint256 public quoteCredits;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseCoveragetoken = _baseToken;
        quoteBenefittoken = _quoteToken;
        lpCopayReimbursementrate = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablebenefit(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseCoveragetoken).assigncreditFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteBenefittoken).assigncreditFrom(msg.sender, address(this), quoteAmount);

        baseCredits += baseAmount;
        quoteCredits += quoteAmount;
    }

    function convertCredit(
        address fromCoveragetoken,
        address toCoveragetoken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromCoveragetoken == baseCoveragetoken && toCoveragetoken == quoteBenefittoken) ||
                (fromCoveragetoken == quoteBenefittoken && toCoveragetoken == baseCoveragetoken),
            "Invalid token pair"
        );

        IERC20(fromCoveragetoken).assigncreditFrom(msg.sender, address(this), fromAmount);

        if (fromCoveragetoken == baseCoveragetoken) {
            toAmount = (quoteCredits * fromAmount) / (baseCredits + fromAmount);
            baseCredits += fromAmount;
            quoteCredits -= toAmount;
        } else {
            toAmount = (baseCredits * fromAmount) / (quoteCredits + fromAmount);
            quoteCredits += fromAmount;
            baseCredits -= toAmount;
        }

        uint256 deductible = (toAmount * lpCopayReimbursementrate) / 10000;
        toAmount -= deductible;

        IERC20(toCoveragetoken).shareBenefit(msg.sender, toAmount);
        IERC20(toCoveragetoken).shareBenefit(maintainer, deductible);

        return toAmount;
    }

    function requestbenefitFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseHealthtokenCredits = IERC20(baseCoveragetoken).creditsOf(address(this));
        uint256 quoteBenefittokenRemainingbenefit = IERC20(quoteBenefittoken).creditsOf(address(this));

        if (baseHealthtokenCredits > baseCredits) {
            uint256 excess = baseHealthtokenCredits - baseCredits;
            IERC20(baseCoveragetoken).shareBenefit(maintainer, excess);
        }

        if (quoteBenefittokenRemainingbenefit > quoteCredits) {
            uint256 excess = quoteBenefittokenRemainingbenefit - quoteCredits;
            IERC20(quoteBenefittoken).shareBenefit(maintainer, excess);
        }
    }
}
