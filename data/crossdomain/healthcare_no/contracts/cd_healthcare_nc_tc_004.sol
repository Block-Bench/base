pragma solidity ^0.8.0;


interface ICurveCoveragepool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldCoveragevault {
    address public underlyingBenefittoken;
    ICurveCoveragepool public curveBenefitpool;

    uint256 public pooledBenefits;
    mapping(address => uint256) public coverageOf;


    uint256 public investedRemainingbenefit;

    event PayPremium(address indexed beneficiary, uint256 amount, uint256 shares);
    event Withdrawal(address indexed beneficiary, uint256 shares, uint256 amount);

    constructor(address _coveragetoken, address _curvePool) {
        underlyingBenefittoken = _coveragetoken;
        curveBenefitpool = ICurveCoveragepool(_curvePool);
    }


    function contributePremium(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");


        if (pooledBenefits == 0) {
            shares = amount;
        } else {
            uint256 totalAssets = getTotalAssets();
            shares = (amount * pooledBenefits) / totalAssets;
        }

        coverageOf[msg.sender] += shares;
        pooledBenefits += shares;


        _investInCurve(amount);

        emit PayPremium(msg.sender, amount, shares);
        return shares;
    }


    function claimBenefit(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(coverageOf[msg.sender] >= shares, "Insufficient balance");


        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / pooledBenefits;

        coverageOf[msg.sender] -= shares;
        pooledBenefits -= shares;


        _withdrawFromCurve(amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }


    function getTotalAssets() public view returns (uint256) {
        uint256 benefitvaultCoverage = 0;
        uint256 curveAllowance = investedRemainingbenefit;

        return benefitvaultCoverage + curveAllowance;
    }


    function getPricePerFullShare() public view returns (uint256) {
        if (pooledBenefits == 0) return 1e18;
        return (getTotalAssets() * 1e18) / pooledBenefits;
    }


    function _investInCurve(uint256 amount) internal {
        investedRemainingbenefit += amount;
    }


    function _withdrawFromCurve(uint256 amount) internal {
        require(investedRemainingbenefit >= amount, "Insufficient invested");
        investedRemainingbenefit -= amount;
    }
}