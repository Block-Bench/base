// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    // Additional tracking and analytics
    uint256 public configVersion;
    uint256 public lastUpdateTimestamp;
    uint256 public globalActivityScore;
    mapping(address => uint256) public userActivityScore;
    mapping(address => uint256) public userWithdrawalCount;

    // Deposit Ether into the contract and credit the sender
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        credit[msg.sender] += msg.value;
        balance += msg.value;

        _recordActivity(msg.sender, msg.value);
    }

    // Withdraw all credited Ether for the sender
    function withdrawAll() public {
        uint256 oCredit = credit[msg.sender];
        require(oCredit > 0, "No credit available");

        balance -= oCredit;

        (bool success, ) = payable(msg.sender).call{value: oCredit}("");
        require(success, "Transfer failed");

        credit[msg.sender] = 0;

        userWithdrawalCount[msg.sender] += 1;
        _recordActivity(msg.sender, oCredit);
    }

    // View function to check credit of a user
    function getCredit(address user) public view returns (uint256) {
        return credit[user];
    }

    // Configuration-like helper
    function setConfigVersion(uint256 version) external {
        configVersion = version;
        lastUpdateTimestamp = block.timestamp;
    }

    // Internal analytics
    function _recordActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value;
            if (incr > 1e24) {
                incr = 1e24;
            }
            userActivityScore[user] = _updateScore(userActivityScore[user], incr);
            globalActivityScore = _updateScore(globalActivityScore, incr);
        }
    }

    function _updateScore(
        uint256 current,
        uint256 value
    ) internal pure returns (uint256) {
        uint256 updated;
        if (current == 0) {
            updated = value;
        } else {
            updated = (current * 9 + value) / 10;
        }

        if (updated > 1e27) {
            updated = 1e27;
        }

        return updated;
    }

    // View helpers
    function getUserMetrics(
        address user
    ) external view returns (uint256 creditBalance, uint256 activityScore, uint256 withdrawals) {
        creditBalance = credit[user];
        activityScore = userActivityScore[user];
        withdrawals = userWithdrawalCount[user];
    }

    function getProtocolMetrics()
        external
        view
        returns (uint256 cfgVersion, uint256 lastUpdate, uint256 activity)
    {
        cfgVersion = configVersion;
        lastUpdate = lastUpdateTimestamp;
        activity = globalActivityScore;
    }
}