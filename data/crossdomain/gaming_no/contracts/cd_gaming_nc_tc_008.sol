pragma solidity ^0.8.0;


interface IOracle {
    function getUnderlyingPrice(address cGoldtoken) external view returns (uint256);
}

interface IcQuesttoken {
    function craftGear(uint256 craftgearAmount) external;

    function takeAdvance(uint256 takeadvanceAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract ItemloanProtocol {

    IOracle public oracle;


    mapping(address => uint256) public betFactors;


    mapping(address => mapping(address => uint256)) public championDeposits;


    mapping(address => mapping(address => uint256)) public adventurerBorrows;


    mapping(address => bool) public supportedMarkets;

    event SavePrize(address indexed adventurer, address indexed cGoldtoken, uint256 amount);
    event RequestLoan(address indexed adventurer, address indexed cGoldtoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }


    function craftGear(address cGoldtoken, uint256 amount) external {
        require(supportedMarkets[cGoldtoken], "Market not supported");


        championDeposits[msg.sender][cGoldtoken] += amount;

        emit SavePrize(msg.sender, cGoldtoken, amount);
    }


    function takeAdvance(address cGoldtoken, uint256 amount) external {
        require(supportedMarkets[cGoldtoken], "Market not supported");


        uint256 getloanPower = calculateRequestloanPower(msg.sender);


        uint256 currentBorrows = calculateTotalBorrows(msg.sender);


        uint256 borrowgoldValue = (oracle.getUnderlyingPrice(cGoldtoken) * amount) /
            1e18;


        require(
            currentBorrows + borrowgoldValue <= getloanPower,
            "Insufficient collateral"
        );


        adventurerBorrows[msg.sender][cGoldtoken] += amount;

        emit RequestLoan(msg.sender, cGoldtoken, amount);
    }


    function calculateRequestloanPower(address adventurer) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cGoldtoken = markets[i];
            uint256 gemTotal = championDeposits[adventurer][cGoldtoken];

            if (gemTotal > 0) {

                uint256 price = oracle.getUnderlyingPrice(cGoldtoken);


                uint256 value = (gemTotal * price) / 1e18;


                uint256 power = (value * betFactors[cGoldtoken]) / 1e18;

                totalPower += power;
            }
        }

        return totalPower;
    }


    function calculateTotalBorrows(address adventurer) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cGoldtoken = markets[i];
            uint256 borrowed = adventurerBorrows[adventurer][cGoldtoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cGoldtoken);
                uint256 value = (borrowed * price) / 1e18;
                totalBorrows += value;
            }
        }

        return totalBorrows;
    }


    function addMarket(address cGoldtoken, uint256 pledgeFactor) external {
        supportedMarkets[cGoldtoken] = true;
        betFactors[cGoldtoken] = pledgeFactor;
    }
}