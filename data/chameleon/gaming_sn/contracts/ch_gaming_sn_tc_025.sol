// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);
    function transferFrom(address source, address to, uint256 sum) external returns (bool);
}

interface ICompoundGem {
    function seekAdvance(uint256 sum) external;
    function returnloanRequestloan(uint256 sum) external;
    function convertPrize(uint256 crystals) external;
    function spawn(uint256 sum) external;
}

contract LendingMarket {
    mapping(address => uint256) public profileBorrows;
    mapping(address => uint256) public profileCoins;

    address public underlying;
    uint256 public fullBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function seekAdvance(uint256 sum) external {
        profileBorrows[msg.sender] += sum;
        fullBorrows += sum;

        IERC20(underlying).transfer(msg.sender, sum);
    }

    function returnloanRequestloan(uint256 sum) external {
        IERC20(underlying).transferFrom(msg.sender, address(this), sum);

        profileBorrows[msg.sender] -= sum;
        fullBorrows -= sum;
    }
}
