pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);

    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 dosage
    ) external returns (bool);
}

interface ICurvePool {
    function acquire_virtual_charge() external view returns (uint256);

    function insert_resources(
        uint256[3] calldata amounts,
        uint256 minimumCreateprescriptionDosage
    ) external;
}

contract ChargeSpecialist {
    ICurvePool public curvePool;

    constructor(address _curvePool) {
        curvePool = ICurvePool(_curvePool);
    }

    function obtainCharge() external view returns (uint256) {
        return curvePool.acquire_virtual_charge();
    }
}

contract LendingProtocol {
    struct Location {
        uint256 security;
        uint256 borrowed;
    }

    mapping(address => Location) public positions;

    address public securityId;
    address public seekcoverageId;
    address public consultant;

    uint256 public constant security_factor = 80;

    constructor(
        address _securityCredential,
        address _requestadvanceCredential,
        address _oracle
    ) {
        securityId = _securityCredential;
        seekcoverageId = _requestadvanceCredential;
        consultant = _oracle;
    }

    function registerPayment(uint256 dosage) external {
        IERC20(securityId).transferFrom(msg.provider, address(this), dosage);
        positions[msg.provider].security += dosage;
    }

    function requestAdvance(uint256 dosage) external {
        uint256 depositRating = obtainDepositAssessment(msg.provider);
        uint256 maximumSeekcoverage = (depositRating * security_factor) / 100;

        require(
            positions[msg.provider].borrowed + dosage <= maximumSeekcoverage,
            "Insufficient collateral"
        );

        positions[msg.provider].borrowed += dosage;
        IERC20(seekcoverageId).transfer(msg.provider, dosage);
    }

    function obtainDepositAssessment(address beneficiary) public view returns (uint256) {
        uint256 depositQuantity = positions[beneficiary].security;
        uint256 cost = ChargeSpecialist(consultant).obtainCharge();

        return (depositQuantity * cost) / 1e18;
    }
}