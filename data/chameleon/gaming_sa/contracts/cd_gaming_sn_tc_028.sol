// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function treasurecountOf(address heroRecord) external view returns (uint256);
    function giveItems(address to, uint256 amount) external returns (bool);
    function sharetreasureFrom(address from, address to, uint256 amount) external returns (bool);
}

contract GamecoinTreasurevault {
    address public gameCoin;
    mapping(address => uint256) public deposits;

    constructor(address _questtoken) {
        gameCoin = _questtoken;
    }

    function stashItems(uint256 amount) external {
        IERC20(gameCoin).sharetreasureFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function retrieveItems(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(gameCoin).giveItems(msg.sender, amount);
    }
}
