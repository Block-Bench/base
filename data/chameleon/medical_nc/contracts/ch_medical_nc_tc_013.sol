pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangemedicationExactBadgesForCredentials(
        uint measureIn,
        uint dosageOut,
        address[] calldata route,
        address to,
        uint dueDate
    ) external returns (uint[] memory amounts);
}

contract BenefitIssuer {
    IERC20 public lpBadge;
    IERC20 public creditId;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public gatheredRewards;

    uint256 public constant credit_factor = 100;

    constructor(address _lpBadge, address _creditCredential) {
        lpBadge = IERC20(_lpBadge);
        creditId = IERC20(_creditCredential);
    }

    function provideSpecimen(uint256 quantity) external {
        lpBadge.transferFrom(msg.sender, address(this), quantity);
        depositedLP[msg.sender] += quantity;
    }

    function generaterecordFor(
        address flip,
        uint256 _withdrawalPremium,
        uint256 _performancePremium,
        address to,
        uint256
    ) external {
        require(flip == address(lpBadge), "Invalid token");

        uint256 deductibleSum = _performancePremium + _withdrawalPremium;
        lpBadge.transferFrom(msg.sender, address(this), deductibleSum);

        uint256 hunnyCoverageUnits = badgeDestinationBenefit(
            lpBadge.balanceOf(address(this))
        );

        gatheredRewards[to] += hunnyCoverageUnits;
    }

    function badgeDestinationBenefit(uint256 lpMeasure) internal pure returns (uint256) {
        return lpMeasure * credit_factor;
    }

    function obtainBenefit() external {
        uint256 coverage = gatheredRewards[msg.sender];
        require(coverage > 0, "No rewards");

        gatheredRewards[msg.sender] = 0;
        creditId.transfer(msg.sender, coverage);
    }

    function dispenseMedication(uint256 quantity) external {
        require(depositedLP[msg.sender] >= quantity, "Insufficient balance");
        depositedLP[msg.sender] -= quantity;
        lpBadge.transfer(msg.sender, quantity);
    }
}