// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferInventory(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function warehouselevelOf(address logisticsAccount) external view returns (uint256);

    function authorizeShipment(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurveCargopool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);
}

interface ICapacityleaseCargopool {
    function stockInventory(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function borrowStorage(
        address asset,
        uint256 amount,
        uint256 rentalrateUtilizationrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function dispatchShipment(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuSpaceloanCargopool is ICapacityleaseCargopool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function stockInventory(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).shiftstockFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function borrowStorage(
        address asset,
        uint256 amount,
        uint256 rentalrateUtilizationrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 cargoguaranteePrice = oracle.getAssetPrice(msg.sender);
        uint256 requestcapacityPrice = oracle.getAssetPrice(asset);

        uint256 shipmentbondValue = (deposits[msg.sender] * cargoguaranteePrice) /
            1e18;
        uint256 maxRentspace = (shipmentbondValue * LTV) / BASIS_POINTS;

        uint256 requestcapacityValue = (amount * requestcapacityPrice) / 1e18;

        require(requestcapacityValue <= maxRentspace, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).transferInventory(onBehalfOf, amount);
    }

    function dispatchShipment(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).transferInventory(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurveCargopool public curveInventorypool;

    constructor(address _shipmentpool) {
        curveInventorypool = _shipmentpool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 warehouselevel0 = curveInventorypool.balances(0);
        uint256 warehouselevel1 = curveInventorypool.balances(1);

        uint256 price = (warehouselevel1 * 1e18) / warehouselevel0;

        return price;
    }
}
