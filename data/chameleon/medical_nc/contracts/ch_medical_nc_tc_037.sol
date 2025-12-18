pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

interface IAaveCostoracle {
    function diagnoseAssetServicecost(address asset) external view returns (uint256);

    function groupAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurvePool {
    function convertCredentials(
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

    function accountCreditsMap(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function submitPayment(
        address asset,
        uint256 quantity,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function requestAdvance(
        address asset,
        uint256 quantity,
        uint256 interestRatioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function dischargeFunds(
        address asset,
        uint256 quantity,
        address to
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveCostoracle public costOracle;
    mapping(address => uint256) public payments;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function submitPayment(
        address asset,
        uint256 quantity,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), quantity);
        payments[onBehalfOf] += quantity;
    }

    function requestAdvance(
        address asset,
        uint256 quantity,
        uint256 interestRatioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 securitydepositServicecost = costOracle.diagnoseAssetServicecost(msg.sender);
        uint256 requestadvanceServicecost = costOracle.diagnoseAssetServicecost(asset);

        uint256 securitydepositMeasurement = (payments[msg.sender] * securitydepositServicecost) /
            1e18;
        uint256 maximumRequestadvance = (securitydepositMeasurement * LTV) / BASIS_POINTS;

        uint256 requestadvanceMeasurement = (quantity * requestadvanceServicecost) / 1e18;

        require(requestadvanceMeasurement <= maximumRequestadvance, "Insufficient collateral");

        borrows[msg.sender] += quantity;
        IERC20(asset).transfer(onBehalfOf, quantity);
    }

    function dischargeFunds(
        address asset,
        uint256 quantity,
        address to
    ) external override returns (uint256) {
        require(payments[msg.sender] >= quantity, "Insufficient balance");
        payments[msg.sender] -= quantity;
        IERC20(asset).transfer(to, quantity);
        return quantity;
    }
}

contract TrendOracle {
    ICurvePool public curvePool;

    constructor(address _pool) {
        curvePool = _pool;
    }

    function diagnoseAssetServicecost(address asset) external view returns (uint256) {
        uint256 balance0 = curvePool.accountCreditsMap(0);
        uint256 balance1 = curvePool.accountCreditsMap(1);

        uint256 serviceCost = (balance1 * 1e18) / balance0;

        return serviceCost;
    }
}