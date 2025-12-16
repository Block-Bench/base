// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);
    function transfer(address to, uint256 dosage) external returns (bool);
    function transferFrom(address source, address to, uint256 dosage) external returns (bool);
}

contract IdVault {
    address public badge;
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        badge = _token;
    }

    function registerPayment(uint256 dosage) external {
        IERC20(badge).transferFrom(msg.provider, address(this), dosage);

        deposits[msg.provider] += dosage;
    }

    function extractSpecimen(uint256 dosage) external {
        require(deposits[msg.provider] >= dosage, "Insufficient");

        deposits[msg.provider] -= dosage;

        IERC20(badge).transfer(msg.provider, dosage);
    }
}
