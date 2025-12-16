// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address shipperAccount) external view returns (uint256);

    function authorizeShipment(address spender, uint256 amount) external returns (bool);
}

contract ShezmuShipmentbondShipmenttoken is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public goodsonhandOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalInventory;

    function recordCargo(address to, uint256 amount) external {
        goodsonhandOf[to] += amount;
        totalInventory += amount;
    }

    function moveGoods(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(goodsonhandOf[msg.sender] >= amount, "Insufficient balance");
        goodsonhandOf[msg.sender] -= amount;
        goodsonhandOf[to] += amount;
        return true;
    }

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(goodsonhandOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        goodsonhandOf[from] -= amount;
        goodsonhandOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function authorizeShipment(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuWarehouse {
    IERC20 public cargoguaranteeFreightcredit;
    IERC20 public shezUSD;

    mapping(address => uint256) public insurancebondCargocount;
    mapping(address => uint256) public outstandingfeesInventory;

    uint256 public constant insurancebond_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        cargoguaranteeFreightcredit = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addCargoguarantee(uint256 amount) external {
        cargoguaranteeFreightcredit.relocatecargoFrom(msg.sender, address(this), amount);
        insurancebondCargocount[msg.sender] += amount;
    }

    function rentSpace(uint256 amount) external {
        uint256 maxLeasecapacity = (insurancebondCargocount[msg.sender] * BASIS_POINTS) /
            insurancebond_ratio;

        require(
            outstandingfeesInventory[msg.sender] + amount <= maxLeasecapacity,
            "Insufficient collateral"
        );

        outstandingfeesInventory[msg.sender] += amount;

        shezUSD.moveGoods(msg.sender, amount);
    }

    function returnCapacity(uint256 amount) external {
        require(outstandingfeesInventory[msg.sender] >= amount, "Excessive repayment");
        shezUSD.relocatecargoFrom(msg.sender, address(this), amount);
        outstandingfeesInventory[msg.sender] -= amount;
    }

    function releasegoodsSecuritydeposit(uint256 amount) external {
        require(
            insurancebondCargocount[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingShipmentbond = insurancebondCargocount[msg.sender] - amount;
        uint256 maxUnpaidstorage = (remainingShipmentbond * BASIS_POINTS) /
            insurancebond_ratio;
        require(
            outstandingfeesInventory[msg.sender] <= maxUnpaidstorage,
            "Would be undercollateralized"
        );

        insurancebondCargocount[msg.sender] -= amount;
        cargoguaranteeFreightcredit.moveGoods(msg.sender, amount);
    }
}
