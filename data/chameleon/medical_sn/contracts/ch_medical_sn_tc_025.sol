// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);
    function transferFrom(address source, address to, uint256 units) external returns (bool);
}

interface ICompoundId {
    function requestAdvance(uint256 units) external;
    function settlebalanceRequestadvance(uint256 units) external;
    function exchangeCredits(uint256 badges) external;
    function createPrescription(uint256 units) external;
}

contract LendingMarket {
    mapping(address => uint256) public chartBorrows;
    mapping(address => uint256) public chartCredentials;

    address public underlying;
    uint256 public aggregateBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function requestAdvance(uint256 units) external {
        chartBorrows[msg.sender] += units;
        aggregateBorrows += units;

        IERC20(underlying).transfer(msg.sender, units);
    }

    function settlebalanceRequestadvance(uint256 units) external {
        IERC20(underlying).transferFrom(msg.sender, address(this), units);

        chartBorrows[msg.sender] -= units;
        aggregateBorrows -= units;
    }
}
