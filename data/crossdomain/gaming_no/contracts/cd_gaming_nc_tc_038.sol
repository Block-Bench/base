pragma solidity ^0.8.0;

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address playerAccount) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address gameCoin) external view returns (uint256);
}

contract BlueberryGoldlending {
    struct Market {
        bool isListed;
        uint256 wagerFactor;
        mapping(address => uint256) playeraccountWager;
        mapping(address => uint256) playeraccountBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant pledge_factor = 75;
    uint256 public constant BASIS_POINTS = 100;

    function enterMarkets(
        address[] calldata vTokens
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vTokens.length);
        for (uint256 i = 0; i < vTokens.length; i++) {
            markets[vTokens[i]].isListed = true;
            results[i] = 0;
        }
        return results;
    }

    function craftGear(address gameCoin, uint256 amount) external returns (uint256) {
        IERC20(gameCoin).giveitemsFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(gameCoin);

        markets[gameCoin].playeraccountWager[msg.sender] += amount;
        return 0;
    }

    function requestLoan(
        address takeadvanceQuesttoken,
        uint256 takeadvanceAmount
    ) external returns (uint256) {
        uint256 totalWagerValue = 0;

        uint256 getloanPrice = oracle.getPrice(takeadvanceQuesttoken);
        uint256 getloanValue = (takeadvanceAmount * getloanPrice) / 1e18;

        uint256 maxRequestloanValue = (totalWagerValue * pledge_factor) /
            BASIS_POINTS;

        require(getloanValue <= maxRequestloanValue, "Insufficient collateral");

        markets[takeadvanceQuesttoken].playeraccountBorrows[msg.sender] += takeadvanceAmount;
        IERC20(takeadvanceQuesttoken).sendGold(msg.sender, takeadvanceAmount);

        return 0;
    }

    function forfeitWager(
        address creditUser,
        address settlescoreGamecoin,
        uint256 settlescoreAmount,
        address depositGoldtoken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address gameCoin) external view override returns (uint256) {
        return prices[gameCoin];
    }

    function setPrice(address gameCoin, uint256 price) external {
        prices[gameCoin] = price;
    }
}