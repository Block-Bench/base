// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address gamerProfile) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address realmCoin) external view returns (uint256);
}

contract BlueberryItemloan {
    struct Market {
        bool isListed;
        uint256 betFactor;
        mapping(address => uint256) gamerprofileDeposit;
        mapping(address => uint256) herorecordBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant bet_factor = 75;
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

    function generateLoot(address realmCoin, uint256 amount) external returns (uint256) {
        IERC20(realmCoin).tradelootFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(realmCoin);

        markets[realmCoin].gamerprofileDeposit[msg.sender] += amount;
        return 0;
    }

    function getLoan(
        address requestloanGoldtoken,
        uint256 getloanAmount
    ) external returns (uint256) {
        uint256 totalStakeValue = 0;

        uint256 takeadvancePrice = oracle.getPrice(requestloanGoldtoken);
        uint256 getloanValue = (getloanAmount * takeadvancePrice) / 1e18;

        uint256 maxGetloanValue = (totalStakeValue * bet_factor) /
            BASIS_POINTS;

        require(getloanValue <= maxGetloanValue, "Insufficient collateral");

        markets[requestloanGoldtoken].herorecordBorrows[msg.sender] += getloanAmount;
        IERC20(requestloanGoldtoken).giveItems(msg.sender, getloanAmount);

        return 0;
    }

    function surrenderStake(
        address debtor,
        address settlescoreGamecoin,
        uint256 settlescoreAmount,
        address stakeGoldtoken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address realmCoin) external view override returns (uint256) {
        return prices[realmCoin];
    }

    function setPrice(address realmCoin, uint256 price) external {
        prices[realmCoin] = price;
    }
}
