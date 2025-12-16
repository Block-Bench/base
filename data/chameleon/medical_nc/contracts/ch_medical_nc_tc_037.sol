pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address subscriber, uint256 units) external returns (bool);
}

interface IAaveConsultant {
    function diagnoseAssetCharge(address asset) external view returns (uint256);

    function groupAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurvePool {
    function pharmacyExchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 floor_dy
    ) external returns (uint256);

    function diagnose_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function benefitsRecord(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function provideSpecimen(
        address asset,
        uint256 units,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function requestAdvance(
        address asset,
        uint256 units,
        uint256 interestRatioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function withdrawBenefits(
        address asset,
        uint256 units,
        address to
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveConsultant public consultant;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function provideSpecimen(
        address asset,
        uint256 units,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), units);
        deposits[onBehalfOf] += units;
    }

    function requestAdvance(
        address asset,
        uint256 units,
        uint256 interestRatioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 securityCost = consultant.diagnoseAssetCharge(msg.sender);
        uint256 requestadvanceCharge = consultant.diagnoseAssetCharge(asset);

        uint256 depositRating = (deposits[msg.sender] * securityCost) /
            1e18;
        uint256 ceilingRequestadvance = (depositRating * LTV) / BASIS_POINTS;

        uint256 requestadvanceAssessment = (units * requestadvanceCharge) / 1e18;

        require(requestadvanceAssessment <= ceilingRequestadvance, "Insufficient collateral");

        borrows[msg.sender] += units;
        IERC20(asset).transfer(onBehalfOf, units);
    }

    function withdrawBenefits(
        address asset,
        uint256 units,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= units, "Insufficient balance");
        deposits[msg.sender] -= units;
        IERC20(asset).transfer(to, units);
        return units;
    }
}

contract CurveConsultant {
    ICurvePool public curvePool;

    constructor(address _pool) {
        curvePool = _pool;
    }

    function diagnoseAssetCharge(address asset) external view returns (uint256) {
        uint256 balance0 = curvePool.benefitsRecord(0);
        uint256 balance1 = curvePool.benefitsRecord(1);

        uint256 charge = (balance1 * 1e18) / balance0;

        return charge;
    }
}