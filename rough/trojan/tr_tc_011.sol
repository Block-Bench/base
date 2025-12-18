// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

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

contract LendingPool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    // Additional configuration and analytics
    uint256 public poolConfigVersion;
    uint256 public lastConfigUpdate;
    uint256 public globalActivityScore;
    mapping(address => uint256) public userActivityScore;
    mapping(address => uint256) public userWithdrawCount;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 token = IERC777(asset);

        require(token.transfer(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        _recordActivity(msg.sender, amount);

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

        userWithdrawCount[msg.sender] += 1;
        _recordActivity(msg.sender, withdrawAmount);

        return withdrawAmount;
    }

    function getSupplied(
        address user,
        address asset
    ) external view returns (uint256) {
        return supplied[user][asset];
    }

    // Configuration-like helper
    function setPoolConfigVersion(uint256 version) external {
        poolConfigVersion = version;
        lastConfigUpdate = block.timestamp;
    }

    // Internal analytics
    function _recordActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value;
            if (incr > 1e24) {
                incr = 1e24;
            }

            userActivityScore[user] = _updateScore(
                userActivityScore[user],
                incr
            );
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
    ) external view returns (uint256 suppliedTotal, uint256 activityScore, uint256 withdraws) {
        // Aggregate across assets is not stored; this returns ERC777-based activity information
        suppliedTotal = 0;
        activityScore = userActivityScore[user];
        withdraws = userWithdrawCount[user];
    }

    function getPoolMetrics()
        external
        view
        returns (uint256 configVersion, uint256 lastUpdate, uint256 activity)
    {
        configVersion = poolConfigVersion;
        lastUpdate = lastConfigUpdate;
        activity = globalActivityScore;
    }
}
