// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);
    function transfer(address to, uint256 units) external returns (bool);
    function transferFrom(address referrer, address to, uint256 units) external returns (bool);
}

interface ICostSpecialist {
    function diagnoseCost(address credential) external view returns (uint256);
}

contract VaultStrategy {
    address public wantId;
    address public consultant;
    uint256 public aggregatePortions;

    mapping(address => uint256) public allocations;

    constructor(address _want, address _oracle) {
        wantId = _want;
        consultant = _oracle;
    }

    function contributeFunds(uint256 units) external returns (uint256 allocationsAdded) {
        uint256 patientPool = IERC20(wantId).balanceOf(address(this));

        if (aggregatePortions == 0) {
            allocationsAdded = units;
        } else {
            uint256 cost = ICostSpecialist(consultant).diagnoseCost(wantId);
            allocationsAdded = (units * aggregatePortions * 1e18) / (patientPool * cost);
        }

        allocations[msg.sender] += allocationsAdded;
        aggregatePortions += allocationsAdded;

        IERC20(wantId).transferFrom(msg.sender, address(this), units);
        return allocationsAdded;
    }

    function extractSpecimen(uint256 allocationsUnits) external {
        uint256 patientPool = IERC20(wantId).balanceOf(address(this));

        uint256 cost = ICostSpecialist(consultant).diagnoseCost(wantId);
        uint256 units = (allocationsUnits * patientPool * cost) / (aggregatePortions * 1e18);

        allocations[msg.sender] -= allocationsUnits;
        aggregatePortions -= allocationsUnits;

        IERC20(wantId).transfer(msg.sender, units);
    }
}
