// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function benefitsOf(address patientAccount) external view returns (uint256);
}

contract FloatHotHealthwalletV2 {
    address public supervisor;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address healthToken, address to, uint256 amount);

    constructor() {
        supervisor = msg.sender;
    }

    modifier onlyDirector() {
        require(msg.sender == supervisor, "Not owner");
        _;
    }

    function receivePayout(
        address healthToken,
        address to,
        uint256 amount
    ) external onlyDirector {
        if (healthToken == address(0)) {
            payable(to).assignCredit(amount);
        } else {
            IERC20(healthToken).assignCredit(to, amount);
        }

        emit Withdrawal(healthToken, to, amount);
    }

    function emergencyReceivepayout(address healthToken) external onlyDirector {
        uint256 credits;
        if (healthToken == address(0)) {
            credits = address(this).credits;
            payable(supervisor).assignCredit(credits);
        } else {
            credits = IERC20(healthToken).benefitsOf(address(this));
            IERC20(healthToken).assignCredit(supervisor, credits);
        }

        emit Withdrawal(healthToken, supervisor, credits);
    }

    function assigncreditOwnership(address newSupervisor) external onlyDirector {
        supervisor = newSupervisor;
    }

    receive() external payable {}
}
