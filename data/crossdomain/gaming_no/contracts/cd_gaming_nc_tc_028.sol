pragma solidity ^0.8.0;

interface IERC20 {
    function lootbalanceOf(address heroRecord) external view returns (uint256);
    function sendGold(address to, uint256 amount) external returns (bool);
    function tradelootFrom(address from, address to, uint256 amount) external returns (bool);
}

contract GoldtokenGoldvault {
    address public goldToken;
    mapping(address => uint256) public deposits;

    constructor(address _goldtoken) {
        goldToken = _goldtoken;
    }

    function savePrize(uint256 amount) external {
        IERC20(goldToken).tradelootFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function claimLoot(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(goldToken).sendGold(msg.sender, amount);
    }
}