pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address memberRecord) external view returns (uint256);

    function permitPayout(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurveClaimpool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);
}

interface IMedicalloanCoveragepool {
    function fundAccount(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function requestAdvance(
        address asset,
        uint256 amount,
        uint256 premiuminterestBenefitratioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function claimBenefit(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuBenefitadvanceClaimpool is IMedicalloanCoveragepool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function fundAccount(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).assigncreditFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function requestAdvance(
        address asset,
        uint256 amount,
        uint256 premiuminterestBenefitratioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 depositPrice = oracle.getAssetPrice(msg.sender);
        uint256 takehealthloanPrice = oracle.getAssetPrice(asset);

        uint256 depositValue = (deposits[msg.sender] * depositPrice) /
            1e18;
        uint256 maxRequestadvance = (depositValue * LTV) / BASIS_POINTS;

        uint256 takehealthloanValue = (amount * takehealthloanPrice) / 1e18;

        require(takehealthloanValue <= maxRequestadvance, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).moveCoverage(onBehalfOf, amount);
    }

    function claimBenefit(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).moveCoverage(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurveClaimpool public curveInsurancepool;

    constructor(address _coveragepool) {
        curveInsurancepool = _coveragepool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 benefits0 = curveInsurancepool.balances(0);
        uint256 credits1 = curveInsurancepool.balances(1);

        uint256 price = (credits1 * 1e18) / benefits0;

        return price;
    }
}