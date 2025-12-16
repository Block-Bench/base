// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function cargocountOf(address logisticsAccount) external view returns (uint256);
    function relocateCargo(address to, uint256 amount) external returns (bool);
    function shiftstockFrom(address from, address to, uint256 amount) external returns (bool);
}

contract CargotokenWarehouse {
    address public cargoToken;
    mapping(address => uint256) public deposits;

    constructor(address _shipmenttoken) {
        cargoToken = _shipmenttoken;
    }

    function warehouseItems(uint256 amount) external {
        IERC20(cargoToken).shiftstockFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function deliverGoods(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(cargoToken).relocateCargo(msg.sender, amount);
    }
}
