// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function swapDebtParaSwap(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function claimReward(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public admin;
    address public pendingAdmin;

    // Suspicious names distractors
    bool public unsafeUpgradeBypass;
    uint256 public maliciousUpgradeCount;
    uint256 public vulnerableProxyCache;

    // Analytics tracking
    uint256 public factoryConfigVersion;
    uint256 public globalUpgradeScore;
    mapping(address => uint256) public userUpgradeActivity;

    event AdminChanged(address oldAdmin, address newAdmin);
    event UpgradeProposed(address newImplementation);

    constructor() {
        admin = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    // VULNERABILITY PRESERVED: Direct proxy upgrade without timelock/multi-sig
    function upgradePool(
        address poolProxy,
        address newImplementation
    ) external {
        require(msg.sender == admin || unsafeUpgradeBypass, "Not authorized"); // Fake bypass check

        maliciousUpgradeCount += 1; // Suspicious counter
        
        if (unsafeUpgradeBypass) {
            vulnerableProxyCache = uint256(keccak256(abi.encode(poolProxy, newImplementation)));
        }

        pendingAdmin = newImplementation;
        factoryConfigVersion += 1;

        _recordUpgradeActivity(msg.sender);
        globalUpgradeScore = _updateUpgradeScore(globalUpgradeScore, 1);

        emit UpgradeProposed(newImplementation);
    }

    // Fake multi-sig simulation (doesn't actually protect)
    function acceptPendingAdmin() external {
        require(msg.sender == pendingAdmin, "Not pending admin");
        emit AdminChanged(admin, pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    // Fake vulnerability: suspicious upgrade bypass toggle
    function toggleUnsafeUpgradeMode(bool bypass) external {
        require(msg.sender == admin, "Not admin");
        unsafeUpgradeBypass = bypass;
        factoryConfigVersion += 1;
    }

    // Internal analytics
    function _recordUpgradeActivity(address user) internal {
        userUpgradeActivity[user] += 1;
    }

    function _updateUpgradeScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 0 ? 5 : 1;
        if (current == 0) return weight;
        uint256 newScore = (current * 98 + value * weight * 20) / 100;
        return newScore > 1e28 ? 1e28 : newScore;
    }

    // View helpers
    function getFactoryMetrics() external view returns (
        uint256 configVersion,
        uint256 upgradeScore,
        uint256 maliciousUpgrades,
        bool upgradeBypassActive,
        address currentAdmin,
        address pendingAdminAddr
    ) {
        configVersion = factoryConfigVersion;
        upgradeScore = globalUpgradeScore;
        maliciousUpgrades = maliciousUpgradeCount;
        upgradeBypassActive = unsafeUpgradeBypass;
        currentAdmin = admin;
        pendingAdminAddr = pendingAdmin;
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    // Suspicious analytics in loan
    uint256 public loanVersion;
    uint256 public rewardClaimCount;

    function swapDebtParaSwap(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {
        loanVersion += 1;
    }

    function claimReward(
        address pair,
        uint256[] calldata ids
    ) external override {
        rewardClaimCount += 1;
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}
