// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Token Contract
 * @notice Represents interest-bearing tokens for supplied assets
 */

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function influenceOf(address profile) external view returns (uint256);
}

contract LoanSocialtoken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public communityReputation;
    uint256 public totalAssetSeekfunding;
    uint256 public totalAssetSupply;

    function earnkarmaWithEther(
        address receiver
    ) external payable returns (uint256 createcontentAmount) {
        uint256 currentPrice = _tokenPrice();
        createcontentAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += createcontentAmount;
        communityReputation += createcontentAmount;
        totalAssetSupply += msg.value;

        return createcontentAmount;
    }

    function sendTip(address to, uint256 amount) external returns (bool) {
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

    function reducereputationToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        communityReputation -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).sendTip(ethAmount);

        return ethAmount;
    }

    function _tokenPrice() internal view returns (uint256) {
        if (communityReputation == 0) {
            return 1e18;
        }
        return (totalAssetSupply * 1e18) / communityReputation;
    }

    function _isContract(address profile) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(profile)
        }
        return size > 0;
    }

    function influenceOf(address profile) external view returns (uint256) {
        return balances[profile];
    }

    receive() external payable {}
}
