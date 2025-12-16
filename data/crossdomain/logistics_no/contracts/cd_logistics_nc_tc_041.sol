pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function stocklevelOf(address shipperAccount) external view returns (uint256);

    function permitRelease(address spender, uint256 amount) external returns (bool);
}

contract ShezmuSecuritydepositShipmenttoken is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public stocklevelOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public warehouseCapacity;

    function logInventory(address to, uint256 amount) external {
        stocklevelOf[to] += amount;
        warehouseCapacity += amount;
    }

    function shiftStock(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(stocklevelOf[msg.sender] >= amount, "Insufficient balance");
        stocklevelOf[msg.sender] -= amount;
        stocklevelOf[to] += amount;
        return true;
    }

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(stocklevelOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        stocklevelOf[from] -= amount;
        stocklevelOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function permitRelease(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuStoragevault {
    IERC20 public shipmentbondShipmenttoken;
    IERC20 public shezUSD;

    mapping(address => uint256) public shipmentbondCargocount;
    mapping(address => uint256) public pendingchargesInventory;

    uint256 public constant securitydeposit_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        shipmentbondShipmenttoken = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addShipmentbond(uint256 amount) external {
        shipmentbondShipmenttoken.movegoodsFrom(msg.sender, address(this), amount);
        shipmentbondCargocount[msg.sender] += amount;
    }

    function requestCapacity(uint256 amount) external {
        uint256 maxRentspace = (shipmentbondCargocount[msg.sender] * BASIS_POINTS) /
            securitydeposit_ratio;

        require(
            pendingchargesInventory[msg.sender] + amount <= maxRentspace,
            "Insufficient collateral"
        );

        pendingchargesInventory[msg.sender] += amount;

        shezUSD.shiftStock(msg.sender, amount);
    }

    function settleStorage(uint256 amount) external {
        require(pendingchargesInventory[msg.sender] >= amount, "Excessive repayment");
        shezUSD.movegoodsFrom(msg.sender, address(this), amount);
        pendingchargesInventory[msg.sender] -= amount;
    }

    function delivergoodsShipmentbond(uint256 amount) external {
        require(
            shipmentbondCargocount[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingInsurancebond = shipmentbondCargocount[msg.sender] - amount;
        uint256 maxUnpaidstorage = (remainingInsurancebond * BASIS_POINTS) /
            securitydeposit_ratio;
        require(
            pendingchargesInventory[msg.sender] <= maxUnpaidstorage,
            "Would be undercollateralized"
        );

        shipmentbondCargocount[msg.sender] -= amount;
        shipmentbondShipmenttoken.shiftStock(msg.sender, amount);
    }
}