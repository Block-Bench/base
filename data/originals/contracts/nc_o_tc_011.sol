pragma solidity ^0.8.0;

interface IERC777 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address account,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract VulnerableLendingPool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;


    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 token = IERC777(asset);


        require(token.transfer(address(this), amount), "Transfer failed");


        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }


    function withdraw(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 userBalance = supplied[msg.sender][asset];
        require(userBalance > 0, "No balance");


        uint256 withdrawAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            withdrawAmount = userBalance;
        }
        require(withdrawAmount <= userBalance, "Insufficient balance");



        IERC777(asset).transfer(msg.sender, withdrawAmount);


        supplied[msg.sender][asset] -= withdrawAmount;
        totalSupplied[asset] -= withdrawAmount;

        return withdrawAmount;
    }


    function getSupplied(
        address user,
        address asset
    ) external view returns (uint256) {
        return supplied[user][asset];
    }
}

