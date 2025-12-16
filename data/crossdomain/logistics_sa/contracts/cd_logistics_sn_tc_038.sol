// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address cargoProfile) external view returns (uint256);

    function approveDispatch(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address shipmentToken) external view returns (uint256);
}

contract BlueberryStoragerental {
    struct Market {
        bool isListed;
        uint256 shipmentbondFactor;
        mapping(address => uint256) logisticsaccountCargoguarantee;
        mapping(address => uint256) logisticsaccountBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant shipmentbond_factor = 75;
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

    function recordCargo(address shipmentToken, uint256 amount) external returns (uint256) {
        IERC20(shipmentToken).transferinventoryFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(shipmentToken);

        markets[shipmentToken].logisticsaccountCargoguarantee[msg.sender] += amount;
        return 0;
    }

    function requestCapacity(
        address borrowstorageFreightcredit,
        uint256 borrowstorageAmount
    ) external returns (uint256) {
        uint256 totalCargoguaranteeValue = 0;

        uint256 leasecapacityPrice = oracle.getPrice(borrowstorageFreightcredit);
        uint256 leasecapacityValue = (borrowstorageAmount * leasecapacityPrice) / 1e18;

        uint256 maxRentspaceValue = (totalCargoguaranteeValue * shipmentbond_factor) /
            BASIS_POINTS;

        require(leasecapacityValue <= maxRentspaceValue, "Insufficient collateral");

        markets[borrowstorageFreightcredit].logisticsaccountBorrows[msg.sender] += borrowstorageAmount;
        IERC20(borrowstorageFreightcredit).relocateCargo(msg.sender, borrowstorageAmount);

        return 0;
    }

    function disposeInventory(
        address storageUser,
        address returncapacityShipmenttoken,
        uint256 returncapacityAmount,
        address insurancebondShipmenttoken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address shipmentToken) external view override returns (uint256) {
        return prices[shipmentToken];
    }

    function setPrice(address shipmentToken, uint256 price) external {
        prices[shipmentToken] = price;
    }
}
