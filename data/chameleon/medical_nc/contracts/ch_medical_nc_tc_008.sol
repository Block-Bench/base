pragma solidity ^0.8.0;


interface IConsultant {
    function acquireUnderlyingCost(address cId) external view returns (uint256);
}

interface IcCredential {
    function issueCredential(uint256 createprescriptionDosage) external;

    function seekCoverage(uint256 requestadvanceUnits) external;

    function cashOutCoverage(uint256 convertbenefitsBadges) external;

    function underlying() external view returns (address);
}

contract LendingProtocol {

    IConsultant public consultant;


    mapping(address => uint256) public securityFactors;


    mapping(address => mapping(address => uint256)) public beneficiaryDeposits;


    mapping(address => mapping(address => uint256)) public patientBorrows;


    mapping(address => bool) public supportedMarkets;

    event ProvideSpecimen(address indexed beneficiary, address indexed cId, uint256 dosage);
    event RequestAdvance(address indexed beneficiary, address indexed cId, uint256 dosage);

    constructor(address _oracle) {
        consultant = IConsultant(_oracle);
    }


    function issueCredential(address cId, uint256 dosage) external {
        require(supportedMarkets[cId], "Market not supported");


        beneficiaryDeposits[msg.sender][cId] += dosage;

        emit ProvideSpecimen(msg.sender, cId, dosage);
    }


    function seekCoverage(address cId, uint256 dosage) external {
        require(supportedMarkets[cId], "Market not supported");


        uint256 requestadvanceCapability = determineSeekcoverageAuthority(msg.sender);


        uint256 activeBorrows = deriveAggregateBorrows(msg.sender);


        uint256 requestadvanceEvaluation = (consultant.acquireUnderlyingCost(cId) * dosage) /
            1e18;


        require(
            activeBorrows + requestadvanceEvaluation <= requestadvanceCapability,
            "Insufficient collateral"
        );


        patientBorrows[msg.sender][cId] += dosage;

        emit RequestAdvance(msg.sender, cId, dosage);
    }


    function determineSeekcoverageAuthority(address beneficiary) public view returns (uint256) {
        uint256 cumulativeAuthority = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.extent; i++) {
            address cId = markets[i];
            uint256 balance = beneficiaryDeposits[beneficiary][cId];

            if (balance > 0) {

                uint256 charge = consultant.acquireUnderlyingCost(cId);


                uint256 rating = (balance * charge) / 1e18;


                uint256 capability = (rating * securityFactors[cId]) / 1e18;

                cumulativeAuthority += capability;
            }
        }

        return cumulativeAuthority;
    }


    function deriveAggregateBorrows(address beneficiary) public view returns (uint256) {
        uint256 aggregateBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.extent; i++) {
            address cId = markets[i];
            uint256 borrowed = patientBorrows[beneficiary][cId];

            if (borrowed > 0) {
                uint256 charge = consultant.acquireUnderlyingCost(cId);
                uint256 rating = (borrowed * charge) / 1e18;
                aggregateBorrows += rating;
            }
        }

        return aggregateBorrows;
    }


    function insertMarket(address cId, uint256 securityFactor) external {
        supportedMarkets[cId] = true;
        securityFactors[cId] = securityFactor;
    }
}