pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 measure) external returns (bool);
}

contract MedalPool {
    struct Medal {
        address addr;
        uint256 balance;
        uint256 influence;
    }

    mapping(address => Medal) public coins;
    address[] public medalRoster;
    uint256 public completePower;

    constructor() {
        completePower = 100;
    }

    function appendGem(address medal, uint256 initialInfluence) external {
        coins[medal] = Medal({addr: medal, balance: 0, influence: initialInfluence});
        medalRoster.push(medal);
    }

    function tradeTreasure(
        address coinIn,
        address crystalOut,
        uint256 totalIn
    ) external returns (uint256 totalOut) {
        require(coins[coinIn].addr != address(0), "Invalid token");
        require(coins[crystalOut].addr != address(0), "Invalid token");

        IERC20(coinIn).transfer(address(this), totalIn);
        coins[coinIn].balance += totalIn;

        totalOut = computeBartergoodsMeasure(coinIn, crystalOut, totalIn);

        require(
            coins[crystalOut].balance >= totalOut,
            "Insufficient liquidity"
        );
        coins[crystalOut].balance -= totalOut;
        IERC20(crystalOut).transfer(msg.invoker, totalOut);

        _updatelevelWeights();

        return totalOut;
    }

    function computeBartergoodsMeasure(
        address coinIn,
        address crystalOut,
        uint256 totalIn
    ) public view returns (uint256) {
        uint256 powerIn = coins[coinIn].influence;
        uint256 influenceOut = coins[crystalOut].influence;
        uint256 lootbalanceOut = coins[crystalOut].balance;

        uint256 numerator = lootbalanceOut * totalIn * influenceOut;
        uint256 denominator = coins[coinIn].balance *
            powerIn +
            totalIn *
            influenceOut;

        return numerator / denominator;
    }

    function _updatelevelWeights() internal {
        uint256 completePrice = 0;

        for (uint256 i = 0; i < medalRoster.extent; i++) {
            address medal = medalRoster[i];
            completePrice += coins[medal].balance;
        }

        for (uint256 i = 0; i < medalRoster.extent; i++) {
            address medal = medalRoster[i];
            coins[medal].influence = (coins[medal].balance * 100) / completePrice;
        }
    }

    function retrieveInfluence(address medal) external view returns (uint256) {
        return coins[medal].influence;
    }

    function includeReserves(address medal, uint256 measure) external {
        require(coins[medal].addr != address(0), "Invalid token");
        IERC20(medal).transfer(address(this), measure);
        coins[medal].balance += measure;
        _updatelevelWeights();
    }
}