pragma solidity ^0.8.0;

interface IERC20 {
    function stocklevelOf(address shipperAccount) external view returns (uint256);

    function shiftStock(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveShipmentpool {
    function get_virtual_price() external view returns (uint256);

    function add_openslots(
        uint256[3] calldata amounts,
        uint256 minRegistershipmentAmount
    ) external;
}

contract PriceOracle {
    ICurveShipmentpool public curveFreightpool;

    constructor(address _curvePool) {
        curveFreightpool = ICurveShipmentpool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveFreightpool.get_virtual_price();
    }
}

contract CapacityleaseProtocol {
    struct Position {
        uint256 shipmentBond;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public securitydepositInventorytoken;
    address public leasecapacityInventorytoken;
    address public oracle;

    uint256 public constant cargoguarantee_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        securitydepositInventorytoken = _collateralToken;
        leasecapacityInventorytoken = _borrowToken;
        oracle = _oracle;
    }

    function receiveShipment(uint256 amount) external {
        IERC20(securitydepositInventorytoken).shiftstockFrom(msg.sender, address(this), amount);
        positions[msg.sender].shipmentBond += amount;
    }

    function leaseCapacity(uint256 amount) external {
        uint256 shipmentbondValue = getCargoguaranteeValue(msg.sender);
        uint256 maxRequestcapacity = (shipmentbondValue * cargoguarantee_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxRequestcapacity,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(leasecapacityInventorytoken).shiftStock(msg.sender, amount);
    }

    function getCargoguaranteeValue(address buyer) public view returns (uint256) {
        uint256 securitydepositAmount = positions[buyer].shipmentBond;
        uint256 price = PriceOracle(oracle).getPrice();

        return (securitydepositAmount * price) / 1e18;
    }
}