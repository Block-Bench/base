// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract FixedFloatHotWallet {
    address public owner;
    mapping(address => bool) public authorizedOperators;
    mapping(bytes32 => bool) public pendingWithdrawals;

    uint256 public constant WITHDRAWAL_DELAY = 2 days;
    uint256 public constant MIN_SIGNERS = 2;
    address[] public signers;

    event Withdrawal(address token, address to, uint256 amount);
    event WithdrawalRequested(bytes32 withdrawalId);

    constructor(address[] memory _signers) {
        require(_signers.length >= MIN_SIGNERS, "Insufficient signers");
        signers = _signers;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlySigner() {
        bool isSigner = false;
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == msg.sender) {
                isSigner = true;
                break;
            }
        }
        require(isSigner, "Not signer");
        _;
    }

    function requestWithdrawal(
        address token,
        address to,
        uint256 amount
    ) external onlySigner {
        bytes32 withdrawalId = keccak256(abi.encodePacked(token, to, amount, block.timestamp));
        pendingWithdrawals[withdrawalId] = true;
        emit WithdrawalRequested(withdrawalId);
    }

    function approveWithdrawal(bytes32 withdrawalId) external onlySigner {
        require(pendingWithdrawals[withdrawalId], "Withdrawal not requested");
        pendingWithdrawals[withdrawalId] = false;
        (address token, address to, uint256 amount) = abi.decode(abi.encodePacked(withdrawalId), (address, address, uint256));
        if (token == address(0)) {
            require(block.timestamp >= WITHDRAWAL_DELAY, "Withdrawal too soon");
            payable(to).transfer(amount);
        } else {
            require(block.timestamp >= WITHDRAWAL_DELAY, "Withdrawal too soon");
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
