// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

/**
 */
contract FixedFloatHotWallet {
    address public owner;

    // No multi-sig, no timelock, no withdrawal limits

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address token, address to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    /**
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     */
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {

        if (token == address(0)) {
            // Withdraw ETH
            payable(to).transfer(amount);
        } else {
            // Withdraw ERC20 tokens
            IERC20(token).transfer(to, amount);
        }

        emit Withdrawal(token, to, amount);
    }

    /**
     */
    function emergencyWithdraw(address token) external onlyOwner {

        uint256 balance;
        if (token == address(0)) {
            balance = address(this).balance;
            payable(owner).transfer(balance);
        } else {
            balance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(owner, balance);
        }

        emit Withdrawal(token, owner, balance);
    }

    /**
     * @dev Transfer ownership - critical function with no protection
     */
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    receive() external payable {}
}
