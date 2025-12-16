pragma solidity ^0.8.0;

interface IERC20 {
    function benefitsOf(address patientAccount) external view returns (uint256);

    function assignCredit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveInsurancepool {
    function get_virtual_price() external view returns (uint256);

    function add_liquidfunds(
        uint256[3] calldata amounts,
        uint256 minIssuecoverageAmount
    ) external;
}

contract PriceOracle {
    ICurveInsurancepool public curveClaimpool;

    constructor(address _curvePool) {
        curveClaimpool = ICurveInsurancepool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveClaimpool.get_virtual_price();
    }
}

contract HealthcreditProtocol {
    struct Position {
        uint256 securityBond;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public copayCoveragetoken;
    address public accesscreditCoveragetoken;
    address public oracle;

    uint256 public constant deposit_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        copayCoveragetoken = _collateralToken;
        accesscreditCoveragetoken = _borrowToken;
        oracle = _oracle;
    }

    function fundAccount(uint256 amount) external {
        IERC20(copayCoveragetoken).assigncreditFrom(msg.sender, address(this), amount);
        positions[msg.sender].securityBond += amount;
    }

    function accessCredit(uint256 amount) external {
        uint256 securitybondValue = getDepositValue(msg.sender);
        uint256 maxRequestadvance = (securitybondValue * deposit_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxRequestadvance,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(accesscreditCoveragetoken).assignCredit(msg.sender, amount);
    }

    function getDepositValue(address participant) public view returns (uint256) {
        uint256 copayAmount = positions[participant].securityBond;
        uint256 price = PriceOracle(oracle).getPrice();

        return (copayAmount * price) / 1e18;
    }
}