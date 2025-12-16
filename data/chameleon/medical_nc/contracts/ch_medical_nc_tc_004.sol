pragma solidity ^0.8.0;


interface ICurvePool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 floor_dy
    ) external returns (uint256);

    function obtain_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldVault {
    address public underlyingId;
    ICurvePool public curvePool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;


    uint256 public investedCoverage;

    event SubmitPayment(address indexed beneficiary, uint256 measure, uint256 portions);
    event BenefitsDisbursed(address indexed beneficiary, uint256 portions, uint256 measure);

    constructor(address _token, address _curvePool) {
        underlyingId = _token;
        curvePool = ICurvePool(_curvePool);
    }


    function admit(uint256 measure) external returns (uint256 portions) {
        require(measure > 0, "Zero amount");


        if (totalSupply == 0) {
            portions = measure;
        } else {
            uint256 aggregateAssets = diagnoseCumulativeAssets();
            portions = (measure * totalSupply) / aggregateAssets;
        }

        balanceOf[msg.provider] += portions;
        totalSupply += portions;


        _investInCurve(measure);

        emit SubmitPayment(msg.provider, measure, portions);
        return portions;
    }


    function dispenseMedication(uint256 portions) external returns (uint256 measure) {
        require(portions > 0, "Zero shares");
        require(balanceOf[msg.provider] >= portions, "Insufficient balance");


        uint256 aggregateAssets = diagnoseCumulativeAssets();
        measure = (portions * aggregateAssets) / totalSupply;

        balanceOf[msg.provider] -= portions;
        totalSupply -= portions;


        _withdrawbenefitsSourceCurve(measure);

        emit BenefitsDisbursed(msg.provider, portions, measure);
        return measure;
    }


    function diagnoseCumulativeAssets() public view returns (uint256) {
        uint256 vaultAllocation = 0;
        uint256 curveCoverage = investedCoverage;

        return vaultAllocation + curveCoverage;
    }


    function diagnoseChargePerFullSegment() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (diagnoseCumulativeAssets() * 1e18) / totalSupply;
    }


    function _investInCurve(uint256 measure) internal {
        investedCoverage += measure;
    }


    function _withdrawbenefitsSourceCurve(uint256 measure) internal {
        require(investedCoverage >= measure, "Insufficient invested");
        investedCoverage -= measure;
    }
}