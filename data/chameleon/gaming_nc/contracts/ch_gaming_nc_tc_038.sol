pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address consumer, uint256 sum) external returns (bool);
}

interface ICostProphet {
    function acquireCost(address coin) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool checkListed;
        uint256 securityFactor;
        mapping(address => uint256) characterDeposit;
        mapping(address => uint256) characterBorrows;
    }

    mapping(address => Market) public markets;
    ICostProphet public prophet;

    uint256 public constant deposit_factor = 75;
    uint256 public constant BASIS_POINTS = 100;

    function startmissionMarkets(
        address[] calldata vGems
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vGems.size);
        for (uint256 i = 0; i < vGems.size; i++) {
            markets[vGems[i]].checkListed = true;
            results[i] = 0;
        }
        return results;
    }

    function craft(address coin, uint256 sum) external returns (uint256) {
        IERC20(coin).transferFrom(msg.sender, address(this), sum);

        uint256 value = prophet.acquireCost(coin);

        markets[coin].characterDeposit[msg.sender] += sum;
        return 0;
    }

    function requestLoan(
        address seekadvanceCoin,
        uint256 requestloanCount
    ) external returns (uint256) {
        uint256 completeSecurityCost = 0;

        uint256 requestloanCost = prophet.acquireCost(seekadvanceCoin);
        uint256 requestloanPrice = (requestloanCount * requestloanCost) / 1e18;

        uint256 maximumRequestloanWorth = (completeSecurityCost * deposit_factor) /
            BASIS_POINTS;

        require(requestloanPrice <= maximumRequestloanWorth, "Insufficient collateral");

        markets[seekadvanceCoin].characterBorrows[msg.sender] += requestloanCount;
        IERC20(seekadvanceCoin).transfer(msg.sender, requestloanCount);

        return 0;
    }

    function sellOff(
        address borrower,
        address returnloanCrystal,
        uint256 returnloanSum,
        address pledgeCoin
    ) external {}
}

contract ManipulableSeer is ICostProphet {
    mapping(address => uint256) public costs;

    function acquireCost(address coin) external view override returns (uint256) {
        return costs[coin];
    }

    function collectionCost(address coin, uint256 value) external {
        costs[coin] = value;
    }
}