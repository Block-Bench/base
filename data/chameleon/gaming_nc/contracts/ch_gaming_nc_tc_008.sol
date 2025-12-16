pragma solidity ^0.8.0;


interface IProphet {
    function retrieveUnderlyingValue(address cGem) external view returns (uint256);
}

interface IcMedal {
    function summon(uint256 craftSum) external;

    function requestLoan(uint256 seekadvanceTotal) external;

    function cashOutRewards(uint256 exchangetokensMedals) external;

    function underlying() external view returns (address);
}

contract LendingProtocol {

    IProphet public seer;


    mapping(address => uint256) public depositFactors;


    mapping(address => mapping(address => uint256)) public characterDeposits;


    mapping(address => mapping(address => uint256)) public heroBorrows;


    mapping(address => bool) public supportedMarkets;

    event CachePrize(address indexed hero, address indexed cGem, uint256 total);
    event RequestLoan(address indexed hero, address indexed cGem, uint256 total);

    constructor(address _oracle) {
        seer = IProphet(_oracle);
    }


    function summon(address cGem, uint256 total) external {
        require(supportedMarkets[cGem], "Market not supported");


        characterDeposits[msg.invoker][cGem] += total;

        emit CachePrize(msg.invoker, cGem, total);
    }


    function requestLoan(address cGem, uint256 total) external {
        require(supportedMarkets[cGem], "Market not supported");


        uint256 seekadvanceMight = computeRequestloanMight(msg.invoker);


        uint256 presentBorrows = computeCompleteBorrows(msg.invoker);


        uint256 requestloanCost = (seer.retrieveUnderlyingValue(cGem) * total) /
            1e18;


        require(
            presentBorrows + requestloanCost <= seekadvanceMight,
            "Insufficient collateral"
        );


        heroBorrows[msg.invoker][cGem] += total;

        emit RequestLoan(msg.invoker, cGem, total);
    }


    function computeRequestloanMight(address hero) public view returns (uint256) {
        uint256 aggregateStrength = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.extent; i++) {
            address cGem = markets[i];
            uint256 balance = characterDeposits[hero][cGem];

            if (balance > 0) {

                uint256 cost = seer.retrieveUnderlyingValue(cGem);


                uint256 magnitude = (balance * cost) / 1e18;


                uint256 might = (magnitude * depositFactors[cGem]) / 1e18;

                aggregateStrength += might;
            }
        }

        return aggregateStrength;
    }


    function computeCompleteBorrows(address hero) public view returns (uint256) {
        uint256 completeBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.extent; i++) {
            address cGem = markets[i];
            uint256 borrowed = heroBorrows[hero][cGem];

            if (borrowed > 0) {
                uint256 cost = seer.retrieveUnderlyingValue(cGem);
                uint256 magnitude = (borrowed * cost) / 1e18;
                completeBorrows += magnitude;
            }
        }

        return completeBorrows;
    }


    function appendMarket(address cGem, uint256 depositFactor) external {
        supportedMarkets[cGem] = true;
        depositFactors[cGem] = depositFactor;
    }
}