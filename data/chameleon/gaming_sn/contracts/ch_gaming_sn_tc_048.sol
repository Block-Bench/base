// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public aggregateBorrows;
    uint256 public fullStockpile;

    event Create(address forger, uint256 createQuantity, uint256 craftMedals);
    event TradeLoot(address redeemer, uint256 tradelootMeasure, uint256 convertprizeCrystals);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeFactor() public view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }

        uint256 cash = underlying.balanceOf(address(this));

        uint256 aggregateUnderlying = cash + aggregateBorrows - fullStockpile;

        return (aggregateUnderlying * 1e18) / totalSupply;
    }

    function craft(uint256 createQuantity) external returns (uint256) {
        require(createQuantity > 0, "Zero mint");

        uint256 exchangeRatioMantissa = exchangeFactor();

        uint256 craftMedals = (createQuantity * 1e18) / exchangeRatioMantissa;

        totalSupply += craftMedals;
        balanceOf[msg.initiator] += craftMedals;

        underlying.transferFrom(msg.initiator, address(this), createQuantity);

        emit Create(msg.initiator, createQuantity, craftMedals);
        return craftMedals;
    }

    function exchangeTokens(uint256 convertprizeCrystals) external returns (uint256) {
        require(balanceOf[msg.initiator] >= convertprizeCrystals, "Insufficient balance");

        uint256 exchangeRatioMantissa = exchangeFactor();

        uint256 tradelootMeasure = (convertprizeCrystals * exchangeRatioMantissa) / 1e18;

        balanceOf[msg.initiator] -= convertprizeCrystals;
        totalSupply -= convertprizeCrystals;

        underlying.transfer(msg.initiator, tradelootMeasure);

        emit TradeLoot(msg.initiator, tradelootMeasure, convertprizeCrystals);
        return tradelootMeasure;
    }

    function prizecountOfUnderlying(
        address character
    ) external view returns (uint256) {
        uint256 exchangeRatioMantissa = exchangeFactor();

        return (balanceOf[character] * exchangeRatioMantissa) / 1e18;
    }
}
