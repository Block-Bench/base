pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function inventoryOf(address cargoProfile) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public totalGoods;
    mapping(address => uint256) public inventoryOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    event RegisterShipment(address minter, uint256 createmanifestAmount, uint256 createmanifestTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeTurnoverrate() public view returns (uint256) {
        if (totalGoods == 0) {
            return 1e18;
        }

        uint256 cash = underlying.inventoryOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        return (totalUnderlying * 1e18) / totalGoods;
    }

    function registerShipment(uint256 createmanifestAmount) external returns (uint256) {
        require(createmanifestAmount > 0, "Zero mint");

        uint256 exchangeUtilizationrateMantissa = exchangeTurnoverrate();

        uint256 createmanifestTokens = (createmanifestAmount * 1e18) / exchangeUtilizationrateMantissa;

        totalGoods += createmanifestTokens;
        inventoryOf[msg.sender] += createmanifestTokens;

        underlying.movegoodsFrom(msg.sender, address(this), createmanifestAmount);

        emit RegisterShipment(msg.sender, createmanifestAmount, createmanifestTokens);
        return createmanifestTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(inventoryOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeUtilizationrateMantissa = exchangeTurnoverrate();

        uint256 redeemAmount = (redeemTokens * exchangeUtilizationrateMantissa) / 1e18;

        inventoryOf[msg.sender] -= redeemTokens;
        totalGoods -= redeemTokens;

        underlying.shiftStock(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function cargocountOfUnderlying(
        address cargoProfile
    ) external view returns (uint256) {
        uint256 exchangeUtilizationrateMantissa = exchangeTurnoverrate();

        return (inventoryOf[cargoProfile] * exchangeUtilizationrateMantissa) / 1e18;
    }
}