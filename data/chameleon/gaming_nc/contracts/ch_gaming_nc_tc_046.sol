pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public owner;

    mapping(address => bool) public authorizedOperators;

    event TreasureWithdrawn(address gem, address to, uint256 sum);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function retrieveRewards(
        address gem,
        address to,
        uint256 sum
    ) external onlyOwner {
        if (gem == address(0)) {
            payable(to).transfer(sum);
        } else {
            IERC20(gem).transfer(to, sum);
        }

        emit TreasureWithdrawn(gem, to, sum);
    }

    function criticalExtractwinnings(address gem) external onlyOwner {
        uint256 balance;
        if (gem == address(0)) {
            balance = address(this).balance;
            payable(owner).transfer(balance);
        } else {
            balance = IERC20(gem).balanceOf(address(this));
            IERC20(gem).transfer(owner, balance);
        }

        emit TreasureWithdrawn(gem, owner, balance);
    }

    function transferOwnership(address updatedMaster) external onlyOwner {
        owner = updatedMaster;
    }

    receive() external payable {}
}