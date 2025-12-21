pragma solidity ^0.8.0;


interface ICostoracle {
    function acquireUnderlyingServicecost(address cCredential) external view returns (uint256);
}

interface IcCredential {
    function issueCredential(uint256 issuecredentialQuantity) external;

    function requestAdvance(uint256 requestadvanceQuantity) external;

    function claimResources(uint256 claimresourcesCredentials) external;

    function underlying() external view returns (address);
}

contract MedicalFinancingProtocol {

    ICostoracle public costOracle;


    mapping(address => uint256) public securitydepositFactors;


    mapping(address => mapping(address => uint256)) public patientPayments;


    mapping(address => mapping(address => uint256)) public patientBorrows;


    mapping(address => bool) public supportedMarkets;

    event SubmitPayment(address indexed patient, address indexed cCredential, uint256 quantity);
    event RequestAdvance(address indexed patient, address indexed cCredential, uint256 quantity);

    constructor(address _oracle) {
        costOracle = ICostoracle(_oracle);
    }


    function issueCredential(address cCredential, uint256 quantity) external {
        require(supportedMarkets[cCredential], "Market not supported");


        patientPayments[msg.sender][cCredential] += quantity;

        emit SubmitPayment(msg.sender, cCredential, quantity);
    }


    function requestAdvance(address cCredential, uint256 quantity) external {
        require(supportedMarkets[cCredential], "Market not supported");


        uint256 requestadvanceAuthority = computemetricsRequestadvanceCapability(msg.sender);


        uint256 activeBorrows = computemetricsTotalamountBorrows(msg.sender);


        uint256 requestadvanceMeasurement = (costOracle.acquireUnderlyingServicecost(cCredential) * quantity) /
            1e18;


        require(
            activeBorrows + requestadvanceMeasurement <= requestadvanceAuthority,
            "Insufficient collateral"
        );


        patientBorrows[msg.sender][cCredential] += quantity;

        emit RequestAdvance(msg.sender, cCredential, quantity);
    }


    function computemetricsRequestadvanceCapability(address patient) public view returns (uint256) {
        uint256 totalamountCapability = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cCredential = markets[i];
            uint256 balance = patientPayments[patient][cCredential];

            if (balance > 0) {

                uint256 serviceCost = costOracle.acquireUnderlyingServicecost(cCredential);


                uint256 measurement = (balance * serviceCost) / 1e18;


                uint256 capability = (measurement * securitydepositFactors[cCredential]) / 1e18;

                totalamountCapability += capability;
            }
        }

        return totalamountCapability;
    }


    function computemetricsTotalamountBorrows(address patient) public view returns (uint256) {
        uint256 totalamountBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cCredential = markets[i];
            uint256 advancedAmount = patientBorrows[patient][cCredential];

            if (advancedAmount > 0) {
                uint256 serviceCost = costOracle.acquireUnderlyingServicecost(cCredential);
                uint256 measurement = (advancedAmount * serviceCost) / 1e18;
                totalamountBorrows += measurement;
            }
        }

        return totalamountBorrows;
    }


    function insertMarket(address cCredential, uint256 securitydepositFactor) external {
        supportedMarkets[cCredential] = true;
        securitydepositFactors[cCredential] = securitydepositFactor;
    }
}