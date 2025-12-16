pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public completeBorrows;
    uint256 public aggregateBackup;

    event Craft(address forger, uint256 spawnQuantity, uint256 spawnCoins);
    event ExchangeTokens(address redeemer, uint256 cashoutrewardsQuantity, uint256 tradelootMedals);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeRatio() public view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }

        uint256 cash = underlying.balanceOf(address(this));

        uint256 combinedUnderlying = cash + completeBorrows - aggregateBackup;

        return (combinedUnderlying * 1e18) / totalSupply;
    }

    function summon(uint256 spawnQuantity) external returns (uint256) {
        require(spawnQuantity > 0, "Zero mint");

        uint256 exchangeMultiplierMantissa = exchangeRatio();

        uint256 spawnCoins = (spawnQuantity * 1e18) / exchangeMultiplierMantissa;

        totalSupply += spawnCoins;
        balanceOf[msg.caster] += spawnCoins;

        underlying.transferFrom(msg.caster, address(this), spawnQuantity);

        emit Craft(msg.caster, spawnQuantity, spawnCoins);
        return spawnCoins;
    }

    function convertPrize(uint256 tradelootMedals) external returns (uint256) {
        require(balanceOf[msg.caster] >= tradelootMedals, "Insufficient balance");

        uint256 exchangeMultiplierMantissa = exchangeRatio();

        uint256 cashoutrewardsQuantity = (tradelootMedals * exchangeMultiplierMantissa) / 1e18;

        balanceOf[msg.caster] -= tradelootMedals;
        totalSupply -= tradelootMedals;

        underlying.transfer(msg.caster, cashoutrewardsQuantity);

        emit ExchangeTokens(msg.caster, cashoutrewardsQuantity, tradelootMedals);
        return cashoutrewardsQuantity;
    }

    function lootbalanceOfUnderlying(
        address profile
    ) external view returns (uint256) {
        uint256 exchangeMultiplierMantissa = exchangeRatio();

        return (balanceOf[profile] * exchangeMultiplierMantissa) / 1e18;
    }
}