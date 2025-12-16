pragma solidity ^0.8.0;

interface IERC20 {
    function allowanceOf(address patientAccount) external view returns (uint256);

    function moveCoverage(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablebenefitInsurancepool {
    address public maintainer;
    address public baseBenefittoken;
    address public quoteCoveragetoken;

    uint256 public lpDeductibleCoveragerate;
    uint256 public baseRemainingbenefit;
    uint256 public quoteBenefits;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseBenefittoken = _baseToken;
        quoteCoveragetoken = _quoteToken;
        lpDeductibleCoveragerate = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablebenefit(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseBenefittoken).assigncreditFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteCoveragetoken).assigncreditFrom(msg.sender, address(this), quoteAmount);

        baseRemainingbenefit += baseAmount;
        quoteBenefits += quoteAmount;
    }

    function exchangeBenefit(
        address fromMedicalcredit,
        address toHealthtoken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromMedicalcredit == baseBenefittoken && toHealthtoken == quoteCoveragetoken) ||
                (fromMedicalcredit == quoteCoveragetoken && toHealthtoken == baseBenefittoken),
            "Invalid token pair"
        );

        IERC20(fromMedicalcredit).assigncreditFrom(msg.sender, address(this), fromAmount);

        if (fromMedicalcredit == baseBenefittoken) {
            toAmount = (quoteBenefits * fromAmount) / (baseRemainingbenefit + fromAmount);
            baseRemainingbenefit += fromAmount;
            quoteBenefits -= toAmount;
        } else {
            toAmount = (baseRemainingbenefit * fromAmount) / (quoteBenefits + fromAmount);
            quoteBenefits += fromAmount;
            baseRemainingbenefit -= toAmount;
        }

        uint256 serviceFee = (toAmount * lpDeductibleCoveragerate) / 10000;
        toAmount -= serviceFee;

        IERC20(toHealthtoken).moveCoverage(msg.sender, toAmount);
        IERC20(toHealthtoken).moveCoverage(maintainer, serviceFee);

        return toAmount;
    }

    function fileclaimFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseCoveragetokenRemainingbenefit = IERC20(baseBenefittoken).allowanceOf(address(this));
        uint256 quoteBenefittokenRemainingbenefit = IERC20(quoteCoveragetoken).allowanceOf(address(this));

        if (baseCoveragetokenRemainingbenefit > baseRemainingbenefit) {
            uint256 excess = baseCoveragetokenRemainingbenefit - baseRemainingbenefit;
            IERC20(baseBenefittoken).moveCoverage(maintainer, excess);
        }

        if (quoteBenefittokenRemainingbenefit > quoteBenefits) {
            uint256 excess = quoteBenefittokenRemainingbenefit - quoteBenefits;
            IERC20(quoteCoveragetoken).moveCoverage(maintainer, excess);
        }
    }
}