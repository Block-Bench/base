// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract FixedFloatHotWallet {
    address public owner;

    mapping(address => bool) public authorizedOperators;

    // Timelock for large withdrawals
    uint256 public constant TIMELOCK_DELAY = 24 hours;
    uint256 public constant LARGE_WITHDRAWAL_THRESHOLD = 10 ether;

    struct PendingWithdrawal {
        address token;
        address to;
        uint256 amount;
        uint256 executeAfter;
        bool executed;
    }

    mapping(bytes32 => PendingWithdrawal) public pendingWithdrawals;

    event Withdrawal(address token, address to, uint256 amount);
    event WithdrawalQueued(bytes32 indexed id, address token, address to, uint256 amount, uint256 executeAfter);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (amount >= LARGE_WITHDRAWAL_THRESHOLD) {
            bytes32 id = keccak256(abi.encodePacked(token, to, amount, block.timestamp));
            pendingWithdrawals[id] = PendingWithdrawal({
                token: token,
                to: to,
                amount: amount,
                executeAfter: block.timestamp + TIMELOCK_DELAY,
                executed: false
            });
            emit WithdrawalQueued(id, token, to, amount, block.timestamp + TIMELOCK_DELAY);
            return;
        }

        _executeWithdrawal(token, to, amount);
    }

    function executeQueuedWithdrawal(bytes32 id) external onlyOwner {
        PendingWithdrawal storage pending = pendingWithdrawals[id];
        require(pending.executeAfter > 0, "Withdrawal not found");
        require(!pending.executed, "Already executed");
        require(block.timestamp >= pending.executeAfter, "Timelock not expired");

        pending.executed = true;
        _executeWithdrawal(pending.token, pending.to, pending.amount);
    }

    function _executeWithdrawal(address token, address to, uint256 amount) internal {
        if (token == address(0)) {
            payable(to).transfer(amount);
        } else {
            IERC20(token).transfer(to, amount);
        }

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

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    receive() external payable {}
}
