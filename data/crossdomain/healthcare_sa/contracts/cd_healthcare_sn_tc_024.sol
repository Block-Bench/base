// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function creditsOf(address memberRecord) external view returns (uint256);

    function assignCredit(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveCoveragepool {
    function get_virtual_price() external view returns (uint256);

    function add_liquidfunds(
        uint256[3] calldata amounts,
        uint256 minAssigncoverageAmount
    ) external;
}

contract PriceOracle {
    ICurveCoveragepool public curveCoveragepool;

    constructor(address _curvePool) {
        curveCoveragepool = ICurveCoveragepool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveCoveragepool.get_virtual_price();
    }
}

contract HealthcreditProtocol {
    struct Position {
        uint256 deductible;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public deductibleHealthtoken;
    address public requestadvanceBenefittoken;
    address public oracle;

    uint256 public constant healthbond_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        deductibleHealthtoken = _collateralToken;
        requestadvanceBenefittoken = _borrowToken;
        oracle = _oracle;
    }

    function fundAccount(uint256 amount) external {
        IERC20(deductibleHealthtoken).movecoverageFrom(msg.sender, address(this), amount);
        positions[msg.sender].deductible += amount;
    }

    function requestAdvance(uint256 amount) external {
        uint256 securitybondValue = getCopayValue(msg.sender);
        uint256 maxBorrowcredit = (securitybondValue * healthbond_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxBorrowcredit,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(requestadvanceBenefittoken).assignCredit(msg.sender, amount);
    }

    function getCopayValue(address beneficiary) public view returns (uint256) {
        uint256 depositAmount = positions[beneficiary].deductible;
        uint256 price = PriceOracle(oracle).getPrice();

        return (depositAmount * price) / 1e18;
    }
}
