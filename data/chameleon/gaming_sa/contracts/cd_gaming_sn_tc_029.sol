// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function itemcountOf(address playerAccount) external view returns (uint256);
    function giveItems(address to, uint256 amount) external returns (bool);
    function sharetreasureFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address questToken) external view returns (uint256);
}

contract ItemvaultStrategy {
    address public wantGamecoin;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantGamecoin = _want;
        oracle = _oracle;
    }

    function bankGold(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 bountyPool = IERC20(wantGamecoin).itemcountOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantGamecoin);
            sharesAdded = (amount * totalShares * 1e18) / (bountyPool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantGamecoin).sharetreasureFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function redeemGold(uint256 sharesAmount) external {
        uint256 bountyPool = IERC20(wantGamecoin).itemcountOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantGamecoin);
        uint256 amount = (sharesAmount * bountyPool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantGamecoin).giveItems(msg.sender, amount);
    }
}
