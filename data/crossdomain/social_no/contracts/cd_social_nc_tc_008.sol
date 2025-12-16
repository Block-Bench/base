pragma solidity ^0.8.0;


interface IOracle {
    function getUnderlyingPrice(address cReputationtoken) external view returns (uint256);
}

interface IcSocialtoken {
    function buildInfluence(uint256 buildinfluenceAmount) external;

    function seekFunding(uint256 seekfundingAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract KarmaloanProtocol {

    IOracle public oracle;


    mapping(address => uint256) public bondFactors;


    mapping(address => mapping(address => uint256)) public contributorDeposits;


    mapping(address => mapping(address => uint256)) public patronBorrows;


    mapping(address => bool) public supportedMarkets;

    event Support(address indexed patron, address indexed cReputationtoken, uint256 amount);
    event RequestSupport(address indexed patron, address indexed cReputationtoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }


    function buildInfluence(address cReputationtoken, uint256 amount) external {
        require(supportedMarkets[cReputationtoken], "Market not supported");


        contributorDeposits[msg.sender][cReputationtoken] += amount;

        emit Support(msg.sender, cReputationtoken, amount);
    }


    function seekFunding(address cReputationtoken, uint256 amount) external {
        require(supportedMarkets[cReputationtoken], "Market not supported");


        uint256 askforbackingPower = calculateAskforbackingPower(msg.sender);


        uint256 currentBorrows = calculateTotalBorrows(msg.sender);


        uint256 seekfundingValue = (oracle.getUnderlyingPrice(cReputationtoken) * amount) /
            1e18;


        require(
            currentBorrows + seekfundingValue <= askforbackingPower,
            "Insufficient collateral"
        );


        patronBorrows[msg.sender][cReputationtoken] += amount;

        emit RequestSupport(msg.sender, cReputationtoken, amount);
    }


    function calculateAskforbackingPower(address patron) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cReputationtoken = markets[i];
            uint256 reputation = contributorDeposits[patron][cReputationtoken];

            if (reputation > 0) {

                uint256 price = oracle.getUnderlyingPrice(cReputationtoken);


                uint256 value = (reputation * price) / 1e18;


                uint256 power = (value * bondFactors[cReputationtoken]) / 1e18;

                totalPower += power;
            }
        }

        return totalPower;
    }


    function calculateTotalBorrows(address patron) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cReputationtoken = markets[i];
            uint256 borrowed = patronBorrows[patron][cReputationtoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cReputationtoken);
                uint256 value = (borrowed * price) / 1e18;
                totalBorrows += value;
            }
        }

        return totalBorrows;
    }


    function addMarket(address cReputationtoken, uint256 guaranteeFactor) external {
        supportedMarkets[cReputationtoken] = true;
        bondFactors[cReputationtoken] = guaranteeFactor;
    }
}