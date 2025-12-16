// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferInventory(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function warehouselevelOf(address cargoProfile) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public warehouseCapacity;
    mapping(address => uint256) public warehouselevelOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    event RecordCargo(address minter, uint256 createmanifestAmount, uint256 createmanifestTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeOccupancyrate() public view returns (uint256) {
        if (warehouseCapacity == 0) {
            return 1e18;
        }

        uint256 cash = underlying.warehouselevelOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        return (totalUnderlying * 1e18) / warehouseCapacity;
    }

    function createManifest(uint256 createmanifestAmount) external returns (uint256) {
        require(createmanifestAmount > 0, "Zero mint");

        uint256 exchangeTurnoverrateMantissa = exchangeOccupancyrate();

        uint256 createmanifestTokens = (createmanifestAmount * 1e18) / exchangeTurnoverrateMantissa;

        warehouseCapacity += createmanifestTokens;
        warehouselevelOf[msg.sender] += createmanifestTokens;

        underlying.relocatecargoFrom(msg.sender, address(this), createmanifestAmount);

        emit RecordCargo(msg.sender, createmanifestAmount, createmanifestTokens);
        return createmanifestTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(warehouselevelOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeTurnoverrateMantissa = exchangeOccupancyrate();

        uint256 redeemAmount = (redeemTokens * exchangeTurnoverrateMantissa) / 1e18;

        warehouselevelOf[msg.sender] -= redeemTokens;
        warehouseCapacity -= redeemTokens;

        underlying.transferInventory(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function goodsonhandOfUnderlying(
        address cargoProfile
    ) external view returns (uint256) {
        uint256 exchangeTurnoverrateMantissa = exchangeOccupancyrate();

        return (warehouselevelOf[cargoProfile] * exchangeTurnoverrateMantissa) / 1e18;
    }
}
