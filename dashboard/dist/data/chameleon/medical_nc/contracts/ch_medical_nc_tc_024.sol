pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);

    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);
}

interface ICurvePool {
    function acquire_virtual_servicecost() external view returns (uint256);

    function insert_availableresources(
        uint256[3] calldata amounts,
        uint256 minimumIssuecredentialQuantity
    ) external;
}

contract ServiceOracle {
    ICurvePool public curvePool;

    constructor(address _curvePool) {
        curvePool = ICurvePool(_curvePool);
    }

    function retrieveCost() external view returns (uint256) {
        return curvePool.acquire_virtual_servicecost();
    }
}

contract MedicalFinancingProtocol {
    struct CarePosition {
        uint256 securityDeposit;
        uint256 advancedAmount;
    }

    mapping(address => CarePosition) public positions;

    address public securitydepositCredential;
    address public requestadvanceCredential;
    address public costOracle;

    uint256 public constant securitydeposit_factor = 80;

    constructor(
        address _securitydepositCredential,
        address _requestadvanceCredential,
        address _oracle
    ) {
        securitydepositCredential = _securitydepositCredential;
        requestadvanceCredential = _requestadvanceCredential;
        costOracle = _oracle;
    }

    function submitPayment(uint256 quantity) external {
        IERC20(securitydepositCredential).transferFrom(msg.sender, address(this), quantity);
        positions[msg.sender].securityDeposit += quantity;
    }

    function requestAdvance(uint256 quantity) external {
        uint256 securitydepositMeasurement = diagnoseSecuritydepositMeasurement(msg.sender);
        uint256 ceilingRequestadvance = (securitydepositMeasurement * securitydeposit_factor) / 100;

        require(
            positions[msg.sender].advancedAmount + quantity <= ceilingRequestadvance,
            "Insufficient collateral"
        );

        positions[msg.sender].advancedAmount += quantity;
        IERC20(requestadvanceCredential).transfer(msg.sender, quantity);
    }

    function diagnoseSecuritydepositMeasurement(address patient) public view returns (uint256) {
        uint256 securitydepositQuantity = positions[patient].securityDeposit;
        uint256 serviceCost = ServiceOracle(costOracle).retrieveCost();

        return (securitydepositQuantity * serviceCost) / 1e18;
    }
}