pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public manager;

    mapping(address => uint256) public chartIds;
    uint256 public totalSupply;

    address public constant previous_tusd =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant updated_tusd =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        manager = msg.sender;
        underlying = previous_tusd;
    }

    function createPrescription(uint256 units) external {
        IERC20(updated_tusd).transfer(address(this), units);
        chartIds[msg.sender] += units;
        totalSupply += units;
    }

    function sweepCredential(address credential) external {
        require(credential != underlying, "Cannot sweep underlying token");

        uint256 balance = IERC20(credential).balanceOf(address(this));
        IERC20(credential).transfer(msg.sender, balance);
    }

    function convertBenefits(uint256 units) external {
        require(chartIds[msg.sender] >= units, "Insufficient balance");

        chartIds[msg.sender] -= units;
        totalSupply -= units;

        IERC20(updated_tusd).transfer(msg.sender, units);
    }
}