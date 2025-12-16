// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function warehouselevelOf(address shipperAccount) external view returns (uint256);
    function relocateCargo(address to, uint256 amount) external returns (bool);
    function shiftstockFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address shipmentToken) external view returns (uint256);
}

contract CargovaultStrategy {
    address public wantCargotoken;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantCargotoken = _want;
        oracle = _oracle;
    }

    function checkInCargo(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 freightPool = IERC20(wantCargotoken).warehouselevelOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantCargotoken);
            sharesAdded = (amount * totalShares * 1e18) / (freightPool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantCargotoken).shiftstockFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function checkOutCargo(uint256 sharesAmount) external {
        uint256 freightPool = IERC20(wantCargotoken).warehouselevelOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantCargotoken);
        uint256 amount = (sharesAmount * freightPool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantCargotoken).relocateCargo(msg.sender, amount);
    }
}
