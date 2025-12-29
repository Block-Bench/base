// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract BZXLoanToken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    uint256 public totalAssetBorrow;
    uint256 public totalAssetSupply;

    /**
     * @notice Mint loan tokens by depositing ETH
     */
    function mintWithEther(
        address receiver
    ) external payable returns (uint256 mintAmount) {
        uint256 currentPrice = _tokenPrice();
        mintAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += mintAmount;
        totalSupply += mintAmount;
        totalAssetSupply += msg.value;

        return mintAmount;
    }

    /**
     * @notice Transfer tokens to another address
     * @param to Recipient address
     * @param amount Amount to transfer
     *
     * The function updates balances and then calls _notifyTransfer which
     * can trigger callbacks to the recipient. During this callback, the
     * contract's state is in an inconsistent state - balances are updated
     * but totalSupply hasn't been recalculated if needed.
     *
     * 1. Update sender balance (line 82)
     * 2. Update receiver balance (line 83)
     * 3. Call _notifyTransfer (line 85) <- CALLBACK
     * 4. During callback, recipient can call transfer() again
     * 5. New transfer() sees inconsistent state
     * 6. Calculations based on this state are wrong
     * 7. After 4-5 iterations, balances inflate
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        _notifyTransfer(msg.sender, to, amount);

        return true;
    }

    /**
     * @notice Internal function that triggers callback
     * @dev This is where the reentrancy/callback happens
     */
    function _notifyTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        // If 'to' is a contract, it might have a callback
        // During this callback, contract state is inconsistent

        // Simulate callback by calling a function on recipient if it's a contract
        if (_isContract(to)) {
            // This would trigger fallback/receive on recipient
            // During that callback, recipient can call transfer() again
            (bool success, ) = to.call("");
            success; // Suppress warning
        }
    }

    /**
     * @notice Burn tokens back to ETH
     */
    function burnToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        totalSupply -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).transfer(ethAmount);

        return ethAmount;
    }

    /**
     * @notice Calculate current token price
     * @dev Price is based on total supply and total assets
     */
    function _tokenPrice() internal view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18; // Initial price 1:1
        }
        return (totalAssetSupply * 1e18) / totalSupply;
    }

    /**
     * @notice Check if address is a contract
     */
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    receive() external payable {}
}
