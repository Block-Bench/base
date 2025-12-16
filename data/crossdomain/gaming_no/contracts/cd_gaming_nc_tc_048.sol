pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function lootbalanceOf(address gamerProfile) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public combinedLoot;
    mapping(address => uint256) public lootbalanceOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    event CreateItem(address minter, uint256 forgeweaponAmount, uint256 forgeweaponTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeBonusrate() public view returns (uint256) {
        if (combinedLoot == 0) {
            return 1e18;
        }

        uint256 cash = underlying.lootbalanceOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        return (totalUnderlying * 1e18) / combinedLoot;
    }

    function createItem(uint256 forgeweaponAmount) external returns (uint256) {
        require(forgeweaponAmount > 0, "Zero mint");

        uint256 exchangeMultiplierMantissa = exchangeBonusrate();

        uint256 forgeweaponTokens = (forgeweaponAmount * 1e18) / exchangeMultiplierMantissa;

        combinedLoot += forgeweaponTokens;
        lootbalanceOf[msg.sender] += forgeweaponTokens;

        underlying.sendgoldFrom(msg.sender, address(this), forgeweaponAmount);

        emit CreateItem(msg.sender, forgeweaponAmount, forgeweaponTokens);
        return forgeweaponTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(lootbalanceOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeMultiplierMantissa = exchangeBonusrate();

        uint256 redeemAmount = (redeemTokens * exchangeMultiplierMantissa) / 1e18;

        lootbalanceOf[msg.sender] -= redeemTokens;
        combinedLoot -= redeemTokens;

        underlying.shareTreasure(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function treasurecountOfUnderlying(
        address gamerProfile
    ) external view returns (uint256) {
        uint256 exchangeMultiplierMantissa = exchangeBonusrate();

        return (lootbalanceOf[gamerProfile] * exchangeMultiplierMantissa) / 1e18;
    }
}