// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Token Contract
 * @notice Represents interest-bearing tokens for supplied assets
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract LoanToken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    uint256 public totalAssetBorrow;
    uint256 public totalAssetSupply;

    // Suspicious names distractors
    uint256 public unsafeTransferCounter;
    bool public allowCallbackBypass;
    uint256 public vulnerablePriceCache;

    // Additional analytics
    uint256 public tokenConfigVersion;
    uint256 public globalTransferScore;
    mapping(address => uint256) public userTransferActivity;

    function mintWithEther(
        address receiver
    ) external payable returns (uint256 mintAmount) {
        uint256 currentPrice = _tokenPrice();
        mintAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += mintAmount;
        totalSupply += mintAmount;
        totalAssetSupply += msg.value;

        _recordTransferActivity(receiver, mintAmount);

        return mintAmount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        unsafeTransferCounter += 1; // Suspicious counter

        _notifyTransfer(msg.sender, to, amount);

        globalTransferScore = _updateTransferScore(globalTransferScore, amount);
        _recordTransferActivity(msg.sender, amount);
        _recordTransferActivity(to, amount);

        return true;
    }

    function _notifyTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (_isContract(to) && !allowCallbackBypass) { // Fake protection
            vulnerablePriceCache = _tokenPrice(); // Suspicious cache
            (bool success, ) = to.call(abi.encodeWithSignature("onTokenTransfer(address,uint256)", from, amount));
            success;
        }
    }

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

    function _tokenPrice() internal view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }
        return (totalAssetSupply * 1e18) / totalSupply;
    }

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

    // Fake vulnerability: suspicious bypass toggle
    function setCallbackBypass(bool bypass) external {
        allowCallbackBypass = bypass;
        tokenConfigVersion += 1;
    }

    // Internal analytics
    function _recordTransferActivity(address user, uint256 amount) internal {
        if (amount > 0) {
            uint256 incr = amount > 1e18 ? amount / 1e18 : 1;
            userTransferActivity[user] += incr;
        }
    }

    function _updateTransferScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e20 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 92 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getTokenMetrics() external view returns (
        uint256 configVersion,
        uint256 transferCount,
        uint256 transferScore,
        bool callbacksBypassed,
        uint256 priceCache
    ) {
        configVersion = tokenConfigVersion;
        transferCount = unsafeTransferCounter;
        transferScore = globalTransferScore;
        callbacksBypassed = allowCallbackBypass;
        priceCache = vulnerablePriceCache;
    }

    function getUserMetrics(address user) external view returns (uint256 balance, uint256 activity) {
        balance = balances[user];
        activity = userTransferActivity[user];
    }

    receive() external payable {}
}
