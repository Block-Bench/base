pragma solidity ^0.8.0;


interface IOracle {
    function getUnderlyingPrice(address cCoveragetoken) external view returns (uint256);
}

interface IcBenefittoken {
    function generateCredit(uint256 generatecreditAmount) external;

    function takeHealthLoan(uint256 takehealthloanAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract MedicalloanProtocol {

    IOracle public oracle;


    mapping(address => uint256) public depositFactors;


    mapping(address => mapping(address => uint256)) public subscriberDeposits;


    mapping(address => mapping(address => uint256)) public enrolleeBorrows;


    mapping(address => bool) public supportedMarkets;

    event PayPremium(address indexed enrollee, address indexed cCoveragetoken, uint256 amount);
    event RequestAdvance(address indexed enrollee, address indexed cCoveragetoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }


    function generateCredit(address cCoveragetoken, uint256 amount) external {
        require(supportedMarkets[cCoveragetoken], "Market not supported");


        subscriberDeposits[msg.sender][cCoveragetoken] += amount;

        emit PayPremium(msg.sender, cCoveragetoken, amount);
    }


    function takeHealthLoan(address cCoveragetoken, uint256 amount) external {
        require(supportedMarkets[cCoveragetoken], "Market not supported");


        uint256 accesscreditPower = calculateRequestadvancePower(msg.sender);


        uint256 currentBorrows = calculateTotalBorrows(msg.sender);


        uint256 borrowcreditValue = (oracle.getUnderlyingPrice(cCoveragetoken) * amount) /
            1e18;


        require(
            currentBorrows + borrowcreditValue <= accesscreditPower,
            "Insufficient collateral"
        );


        enrolleeBorrows[msg.sender][cCoveragetoken] += amount;

        emit RequestAdvance(msg.sender, cCoveragetoken, amount);
    }


    function calculateRequestadvancePower(address enrollee) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cCoveragetoken = markets[i];
            uint256 allowance = subscriberDeposits[enrollee][cCoveragetoken];

            if (allowance > 0) {

                uint256 price = oracle.getUnderlyingPrice(cCoveragetoken);


                uint256 value = (allowance * price) / 1e18;


                uint256 power = (value * depositFactors[cCoveragetoken]) / 1e18;

                totalPower += power;
            }
        }

        return totalPower;
    }


    function calculateTotalBorrows(address enrollee) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cCoveragetoken = markets[i];
            uint256 borrowed = enrolleeBorrows[enrollee][cCoveragetoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cCoveragetoken);
                uint256 value = (borrowed * price) / 1e18;
                totalBorrows += value;
            }
        }

        return totalBorrows;
    }


    function addMarket(address cCoveragetoken, uint256 securitybondFactor) external {
        supportedMarkets[cCoveragetoken] = true;
        depositFactors[cCoveragetoken] = securitybondFactor;
    }
}