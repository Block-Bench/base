pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address cargoProfile) external view returns (uint256);

    function clearCargo(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurveFreightpool {
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

interface IStoragerentalInventorypool {
    function receiveShipment(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function requestCapacity(
        address asset,
        uint256 amount,
        uint256 storagerateTurnoverrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function releaseGoods(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuSpaceloanFreightpool is IStoragerentalInventorypool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function receiveShipment(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).shiftstockFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function requestCapacity(
        address asset,
        uint256 amount,
        uint256 storagerateTurnoverrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 cargoguaranteePrice = oracle.getAssetPrice(msg.sender);
        uint256 rentspacePrice = oracle.getAssetPrice(asset);

        uint256 cargoguaranteeValue = (deposits[msg.sender] * cargoguaranteePrice) /
            1e18;
        uint256 maxRequestcapacity = (cargoguaranteeValue * LTV) / BASIS_POINTS;

        uint256 rentspaceValue = (amount * rentspacePrice) / 1e18;

        require(rentspaceValue <= maxRequestcapacity, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).relocateCargo(onBehalfOf, amount);
    }

    function releaseGoods(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).relocateCargo(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurveFreightpool public curveShipmentpool;

    constructor(address _inventorypool) {
        curveShipmentpool = _inventorypool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 stocklevel0 = curveShipmentpool.balances(0);
        uint256 cargocount1 = curveShipmentpool.balances(1);

        uint256 price = (cargocount1 * 1e18) / stocklevel0;

        return price;
    }
}