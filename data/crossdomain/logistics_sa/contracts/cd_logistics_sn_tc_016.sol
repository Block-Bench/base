// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Token Contract
 * @notice Represents interest-bearing tokens for supplied assets
 */

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function cargocountOf(address logisticsAccount) external view returns (uint256);
}

contract LoanCargotoken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public totalGoods;
    uint256 public totalAssetBorrowstorage;
    uint256 public totalAssetSupply;

    function recordcargoWithEther(
        address receiver
    ) external payable returns (uint256 registershipmentAmount) {
        uint256 currentPrice = _tokenPrice();
        registershipmentAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += registershipmentAmount;
        totalGoods += registershipmentAmount;
        totalAssetSupply += msg.value;

        return registershipmentAmount;
    }

    function moveGoods(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        _notifyTransfer(msg.sender, to, amount);

        return true;
    }

    function _notifyTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (_isContract(to)) {
            (bool success, ) = to.call("");
            success;
        }
    }

    function archiveshipmentToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        totalGoods -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).moveGoods(ethAmount);

        return ethAmount;
    }

    function _tokenPrice() internal view returns (uint256) {
        if (totalGoods == 0) {
            return 1e18;
        }
        return (totalAssetSupply * 1e18) / totalGoods;
    }

    function _isContract(address logisticsAccount) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(logisticsAccount)
        }
        return size > 0;
    }

    function cargocountOf(address logisticsAccount) external view returns (uint256) {
        return balances[logisticsAccount];
    }

    receive() external payable {}
}
