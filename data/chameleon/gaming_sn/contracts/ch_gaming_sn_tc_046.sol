// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public owner;

    mapping(address => bool) public authorizedOperators;

    event LootClaimed(address medal, address to, uint256 count);

    constructor() {
        owner = msg.initiator;
    }

    modifier onlyOwner() {
        require(msg.initiator == owner, "Not owner");
        _;
    }

    function extractWinnings(
        address medal,
        address to,
        uint256 count
    ) external onlyOwner {
        if (medal == address(0)) {
            payable(to).transfer(count);
        } else {
            IERC20(medal).transfer(to, count);
        }

        emit LootClaimed(medal, to, count);
    }

    function urgentHarvestgold(address medal) external onlyOwner {
        uint256 balance;
        if (medal == address(0)) {
            balance = address(this).balance;
            payable(owner).transfer(balance);
        } else {
            balance = IERC20(medal).balanceOf(address(this));
            IERC20(medal).transfer(owner, balance);
        }

        emit LootClaimed(medal, owner, balance);
    }

    function transferOwnership(address updatedLord) external onlyOwner {
        owner = updatedLord;
    }

    receive() external payable {}
}
