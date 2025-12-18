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

interface IServicecostCostoracle {
    function retrieveCost(address credential) external view returns (uint256);
}

contract BlueberryLending {
    struct ServiceMarket {
        bool checkListed;
        uint256 securitydepositFactor;
        mapping(address => uint256) chartSecuritydeposit;
        mapping(address => uint256) profileBorrows;
    }

    mapping(address => ServiceMarket) public markets;
    IServicecostCostoracle public costOracle;

    uint256 public constant securitydeposit_factor = 75;
    uint256 public constant BASIS_POINTS = 100;

    function registerMarkets(
        address[] calldata vCredentials
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vCredentials.length);
        for (uint256 i = 0; i < vCredentials.length; i++) {
            markets[vCredentials[i]].checkListed = true;
            results[i] = 0;
        }
        return results;
    }

    function issueCredential(address credential, uint256 quantity) external returns (uint256) {
        IERC20(credential).transferFrom(msg.sender, address(this), quantity);

        uint256 serviceCost = costOracle.retrieveCost(credential);

        markets[credential].chartSecuritydeposit[msg.sender] += quantity;
        return 0;
    }

    function requestAdvance(
        address requestadvanceCredential,
        uint256 requestadvanceQuantity
    ) external returns (uint256) {
        uint256 totalamountSecuritydepositMeasurement = 0;

        uint256 requestadvanceServicecost = costOracle.retrieveCost(requestadvanceCredential);
        uint256 requestadvanceMeasurement = (requestadvanceQuantity * requestadvanceServicecost) / 1e18;

        uint256 ceilingRequestadvanceMeasurement = (totalamountSecuritydepositMeasurement * securitydeposit_factor) /
            BASIS_POINTS;

        require(requestadvanceMeasurement <= ceilingRequestadvanceMeasurement, "Insufficient collateral");

        markets[requestadvanceCredential].profileBorrows[msg.sender] += requestadvanceQuantity;
        IERC20(requestadvanceCredential).transfer(msg.sender, requestadvanceQuantity);

        return 0;
    }

    function forceSettlement(
        address borrower,
        address settlebalanceCredential,
        uint256 settlebalanceQuantity,
        address securitydepositCredential
    ) external {}
}

contract VulnerableOracle is IServicecostCostoracle {
    mapping(address => uint256) public charges;

    function retrieveCost(address credential) external view override returns (uint256) {
        return charges[credential];
    }

    function groupServicecost(address credential, uint256 serviceCost) external {
        charges[credential] = serviceCost;
    }
}