// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Manages collateral deposits and borrowing
 */

interface IComptroller {
    function enterMarkets(
        address[] memory cTokens
    ) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

    function getAccountLiquidity(
        address account
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public constant COLLATERAL_FACTOR = 150;

    // Additional configuration and analytics
    uint256 public riskConfigVersion;
    uint256 public lastRiskUpdate;
    uint256 public globalActivityScore;
    mapping(address => uint256) public userActivityScore;
    mapping(address => uint256) public userBorrowCount;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
        riskConfigVersion = 1;
        lastRiskUpdate = block.timestamp;
    }

    function depositAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;

        _recordActivity(msg.sender, msg.value);
    }

    function isHealthy(
        address account,
        uint256 additionalBorrow
    ) public view returns (bool) {
        uint256 totalDebt = borrowed[account] + additionalBorrow;
        if (totalDebt == 0) return true;

        if (!inMarket[account]) return false;

        uint256 collateralValue = deposits[account];
        return collateralValue >= (totalDebt * COLLATERAL_FACTOR) / 100;
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).balance >= amount, "Insufficient funds");

        require(isHealthy(msg.sender, amount), "Insufficient collateral");

        borrowed[msg.sender] += amount;
        totalBorrowed += amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        require(isHealthy(msg.sender, 0), "Health check failed");

        userBorrowCount[msg.sender] += 1;
        _recordActivity(msg.sender, amount);
    }

    function exitMarket() external {
        require(borrowed[msg.sender] == 0, "Outstanding debt");
        inMarket[msg.sender] = false;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        payable(msg.sender).transfer(amount);

        _recordActivity(msg.sender, amount);
    }

    // Configuration-like helper
    function setRiskConfigVersion(uint256 version) external {
        riskConfigVersion = version;
        lastRiskUpdate = block.timestamp;
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
    )
        external
        view
        returns (uint256 depositsValue, uint256 borrowsValue, uint256 activity, uint256 borrowsCount)
    {
        depositsValue = deposits[user];
        borrowsValue = borrowed[user];
        activity = userActivityScore[user];
        borrowsCount = userBorrowCount[user];
    }

    function getProtocolMetrics()
        external
        view
        returns (uint256 totalDep, uint256 totalBor, uint256 riskVersion, uint256 lastUpdate, uint256 globalRisk)
    {
        totalDep = totalDeposits;
        totalBor = totalBorrowed;
        riskVersion = riskConfigVersion;
        lastUpdate = lastRiskUpdate;
        globalRisk = globalActivityScore;
    }

    receive() external payable {}
}
