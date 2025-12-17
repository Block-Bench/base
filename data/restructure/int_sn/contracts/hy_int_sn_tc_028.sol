// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenVault {
    address public token;
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        token = _token;
    }

    function deposit(uint256 amount) external {
        _handleDepositLogic(msg.sender, amount);
    }

    function _handleDepositLogic(address _sender, uint256 amount) internal {
        IERC20(token).transferFrom(_sender, address(this), amount);
        deposits[_sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(token).transfer(msg.sender, amount);
    }
}
