// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IBorrowerOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address account,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address account) external;
}

interface ITroveManager {
    function getTroveCollAndDebt(
        address _borrower
    ) external view returns (uint256 coll, uint256 debt);

    function liquidate(address _borrower) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public borrowerOperations;
    address public wstETH;
    address public mkUSD;

    // Metrics tracking
    uint256 public configVersion;
    uint256 public lastMigrationBlock;
    uint256 public totalMigrations;
    uint256 public globalThroughputScore;
    mapping(address => uint256) public userMigrationCount;
    mapping(address => uint256) public userActivityScore;

    event MigrationCompleted(address indexed account, uint256 collateral, uint256 debt);
    event ActivityRecorded(address indexed user, uint256 score);
    event ConfigUpdated(uint256 indexed version);

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        borrowerOperations = IBorrowerOperations(_borrowerOperations);
        wstETH = _wstETH;
        mkUSD = _mkUSD;
        configVersion = 1;
    }

    function openTroveAndMigrate(
        address troveManager,
        address account,
        uint256 maxFeePercentage,
        uint256 collateralAmount,
        uint256 debtAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );

        IERC20(wstETH).approve(address(borrowerOperations), collateralAmount);

        borrowerOperations.openTrove(
            troveManager,
            account,
            maxFeePercentage,
            collateralAmount,
            debtAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transfer(msg.sender, debtAmount);

        // Record metrics
        totalMigrations += 1;
        lastMigrationBlock = block.number;
        userMigrationCount[msg.sender] += 1;
        _recordActivity(msg.sender, collateralAmount);

        emit MigrationCompleted(account, collateralAmount, debtAmount);
    }

    function closeTroveFor(address troveManager, address account) external {
        borrowerOperations.closeTrove(troveManager, account);
    }

    // Fake vulnerability: looks dangerous but just updates config
    function emergencyConfigOverride(uint256 newVersion) external {
        configVersion = newVersion;
        emit ConfigUpdated(newVersion);
    }

    // Internal analytics
    function _recordActivity(address user, uint256 amount) internal {
        uint256 score = amount;
        if (score > 1e24) {
            score = 1e24;
        }

        userActivityScore[user] = _updateScore(userActivityScore[user], score);
        globalThroughputScore = _updateScore(globalThroughputScore, score);

        emit ActivityRecorded(user, score);
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

        if (updated > 1e30) {
            updated = 1e30;
        }

        return updated;
    }

    // View helpers
    function getMigrationMetrics()
        external
        view
        returns (
            uint256 total,
            uint256 lastBlock,
            uint256 throughput,
            uint256 version
        )
    {
        total = totalMigrations;
        lastBlock = lastMigrationBlock;
        throughput = globalThroughputScore;
        version = configVersion;
    }

    function getUserMetrics(
        address user
    ) external view returns (uint256 migrations, uint256 activityScore) {
        migrations = userMigrationCount[user];
        activityScore = userActivityScore[user];
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    // Additional configuration and metrics
    uint256 public operationCount;
    uint256 public lastOperationBlock;
    mapping(address => uint256) public accountOperationCount;

    event DelegateApprovalSet(address indexed owner, address indexed delegate, bool approved);
    event OperationRecorded(address indexed account, uint256 count);

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
        emit DelegateApprovalSet(msg.sender, _delegate, _isApproved);
    }

    function openTrove(
        address _troveManager,
        address account,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == account || delegates[account][msg.sender],
            "Not authorized"
        );

        // Record operation
        operationCount += 1;
        lastOperationBlock = block.number;
        accountOperationCount[account] += 1;

        emit OperationRecorded(account, accountOperationCount[account]);
    }

    function closeTrove(address _troveManager, address account) external {
        require(
            msg.sender == account || delegates[account][msg.sender],
            "Not authorized"
        );

        // Record operation
        operationCount += 1;
        lastOperationBlock = block.number;
    }

    // View helpers
    function getOperationStats()
        external
        view
        returns (uint256 total, uint256 lastBlock)
    {
        total = operationCount;
        lastBlock = lastOperationBlock;
    }

    function getAccountStats(
        address account
    ) external view returns (uint256 operations, bool isDelegate) {
        operations = accountOperationCount[account];
        isDelegate = delegates[account][msg.sender];
    }
}
