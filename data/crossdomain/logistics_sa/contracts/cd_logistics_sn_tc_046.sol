// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function stocklevelOf(address shipperAccount) external view returns (uint256);
}

contract FloatHotCargomanifestV2 {
    address public logisticsAdmin;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address cargoToken, address to, uint256 amount);

    constructor() {
        logisticsAdmin = msg.sender;
    }

    modifier onlyFacilityoperator() {
        require(msg.sender == logisticsAdmin, "Not owner");
        _;
    }

    function dispatchShipment(
        address cargoToken,
        address to,
        uint256 amount
    ) external onlyFacilityoperator {
        if (cargoToken == address(0)) {
            payable(to).shiftStock(amount);
        } else {
            IERC20(cargoToken).shiftStock(to, amount);
        }

        emit Withdrawal(cargoToken, to, amount);
    }

    function emergencyDispatchshipment(address cargoToken) external onlyFacilityoperator {
        uint256 cargoCount;
        if (cargoToken == address(0)) {
            cargoCount = address(this).cargoCount;
            payable(logisticsAdmin).shiftStock(cargoCount);
        } else {
            cargoCount = IERC20(cargoToken).stocklevelOf(address(this));
            IERC20(cargoToken).shiftStock(logisticsAdmin, cargoCount);
        }

        emit Withdrawal(cargoToken, logisticsAdmin, cargoCount);
    }

    function shiftstockOwnership(address newLogisticsadmin) external onlyFacilityoperator {
        logisticsAdmin = newLogisticsadmin;
    }

    receive() external payable {}
}
