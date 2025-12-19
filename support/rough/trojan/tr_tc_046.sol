// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract FixedFloatHotWallet {
    address public owner;
    address public pendingOwner;

    mapping(address => bool) public authorizedOperators;

    // Suspicious names distractors
    bool public unsafeWithdrawBypass;
    uint256 public maliciousWithdrawCount;
    uint256 public vulnerableWalletCache;

    // Analytics tracking
    uint256 public walletConfigVersion;
    uint256 public globalWithdrawScore;
    mapping(address => uint256) public userWithdrawActivity;

    event Withdrawal(address token, address to, uint256 amount);
    event OwnershipTransferProposed(address newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner || unsafeWithdrawBypass, "Not owner"); // VULNERABILITY: Fake bypass
        _;
    }

    // VULNERABILITY PRESERVED: Single owner with fake multi-sig illusion
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        maliciousWithdrawCount += 1; // Suspicious counter

        if (unsafeWithdrawBypass) {
            vulnerableWalletCache = uint256(keccak256(abi.encode(token, to, amount))); // Suspicious cache
        }

        if (token == address(0)) {
            payable(to).transfer(amount);
        } else {
            IERC20(token).transfer(to, amount);
        }

        _recordWithdrawActivity(to, amount);
        globalWithdrawScore = _updateWithdrawScore(globalWithdrawScore, amount);

        emit Withdrawal(token, to, amount);
    }

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

    // Fake multi-sig ownership transfer (doesn't protect withdrawals)
    function proposeOwnershipTransfer(address newOwner) external onlyOwner {
        pendingOwner = newOwner;
        walletConfigVersion += 1;
        emit OwnershipTransferProposed(newOwner);
    }

    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "Not pending owner");
        emit OwnershipTransferProposed(owner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    // Fake vulnerability: withdrawal bypass toggle
    function toggleUnsafeWithdrawMode(bool bypass) external onlyOwner {
        unsafeWithdrawBypass = bypass;
        walletConfigVersion += 1;
    }

    // Internal analytics
    function _recordWithdrawActivity(address user, uint256 amount) internal {
        uint256 incr = amount > 1e20 ? amount / 1e18 : 1;
        userWithdrawActivity[user] += incr;
    }

    function _updateWithdrawScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 5 : 1;
        if (current == 0) return weight;
        uint256 newScore = (current * 97 + value * weight / 1e18) / 100;
        return newScore > 1e32 ? 1e32 : newScore;
    }

    // View helpers
    function getWalletMetrics() external view returns (
        uint256 configVersion,
        uint256 withdrawScore,
        uint256 maliciousWithdraws,
        bool withdrawBypassActive,
        address currentOwner,
        address pendingOwnerAddr
    ) {
        configVersion = walletConfigVersion;
        withdrawScore = globalWithdrawScore;
        maliciousWithdraws = maliciousWithdrawCount;
        withdrawBypassActive = unsafeWithdrawBypass;
        currentOwner = owner;
        pendingOwnerAddr = pendingOwner;
    }

    receive() external payable {}
}
