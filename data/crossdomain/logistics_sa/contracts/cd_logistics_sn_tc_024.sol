// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function cargocountOf(address cargoProfile) external view returns (uint256);

    function shiftStock(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveInventorypool {
    function get_virtual_price() external view returns (uint256);

    function add_openslots(
        uint256[3] calldata amounts,
        uint256 minRecordcargoAmount
    ) external;
}

contract PriceOracle {
    ICurveInventorypool public curveInventorypool;

    constructor(address _curvePool) {
        curveInventorypool = ICurveInventorypool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveInventorypool.get_virtual_price();
    }
}

contract CapacityleaseProtocol {
    struct Position {
        uint256 insuranceBond;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public insurancebondCargotoken;
    address public requestcapacityShipmenttoken;
    address public oracle;

    uint256 public constant insurancebond_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        insurancebondCargotoken = _collateralToken;
        requestcapacityShipmenttoken = _borrowToken;
        oracle = _oracle;
    }

    function storeGoods(uint256 amount) external {
        IERC20(insurancebondCargotoken).relocatecargoFrom(msg.sender, address(this), amount);
        positions[msg.sender].insuranceBond += amount;
    }

    function leaseCapacity(uint256 amount) external {
        uint256 securitydepositValue = getInsurancebondValue(msg.sender);
        uint256 maxRentspace = (securitydepositValue * insurancebond_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxRentspace,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(requestcapacityShipmenttoken).shiftStock(msg.sender, amount);
    }

    function getInsurancebondValue(address merchant) public view returns (uint256) {
        uint256 securitydepositAmount = positions[merchant].insuranceBond;
        uint256 price = PriceOracle(oracle).getPrice();

        return (securitydepositAmount * price) / 1e18;
    }
}
