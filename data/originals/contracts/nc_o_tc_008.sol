pragma solidity ^0.8.0;

interface IOracle {
    function getUnderlyingPrice(address cToken) external view returns (uint256);
}

interface ICToken {
    function mint(uint256 mintAmount) external;

    function borrow(uint256 borrowAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract VulnerableCreamLending {

    IOracle public oracle;


    mapping(address => uint256) public collateralFactors;


    mapping(address => mapping(address => uint256)) public userDeposits;


    mapping(address => mapping(address => uint256)) public userBorrows;


    mapping(address => bool) public supportedMarkets;

    event Deposit(address indexed user, address indexed cToken, uint256 amount);
    event Borrow(address indexed user, address indexed cToken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }


    function mint(address cToken, uint256 amount) external {
        require(supportedMarkets[cToken], "Market not supported");






        userDeposits[msg.sender][cToken] += amount;

        emit Deposit(msg.sender, cToken, amount);
    }


    function borrow(address cToken, uint256 amount) external {
        require(supportedMarkets[cToken], "Market not supported");


        uint256 borrowPower = calculateBorrowPower(msg.sender);


        uint256 currentBorrows = calculateTotalBorrows(msg.sender);



        uint256 borrowValue = (oracle.getUnderlyingPrice(cToken) * amount) /
            1e18;


        require(
            currentBorrows + borrowValue <= borrowPower,
            "Insufficient collateral"
        );


        userBorrows[msg.sender][cToken] += amount;





        emit Borrow(msg.sender, cToken, amount);
    }


    function calculateBorrowPower(address user) public view returns (uint256) {
        uint256 totalPower = 0;



        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cToken = markets[i];
            uint256 balance = userDeposits[user][cToken];

            if (balance > 0) {


                uint256 price = oracle.getUnderlyingPrice(cToken);


                uint256 value = (balance * price) / 1e18;


                uint256 power = (value * collateralFactors[cToken]) / 1e18;

                totalPower += power;
            }
        }

        return totalPower;
    }


    function calculateTotalBorrows(address user) public view returns (uint256) {
        uint256 totalBorrows = 0;


        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cToken = markets[i];
            uint256 borrowed = userBorrows[user][cToken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cToken);
                uint256 value = (borrowed * price) / 1e18;
                totalBorrows += value;
            }
        }

        return totalBorrows;
    }


    function addMarket(address cToken, uint256 collateralFactor) external {
        supportedMarkets[cToken] = true;
        collateralFactors[cToken] = collateralFactor;
    }
}

