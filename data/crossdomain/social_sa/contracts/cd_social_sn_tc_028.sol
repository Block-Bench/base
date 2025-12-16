// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function influenceOf(address socialProfile) external view returns (uint256);
    function passInfluence(address to, uint256 amount) external returns (bool);
    function sendtipFrom(address from, address to, uint256 amount) external returns (bool);
}

contract KarmatokenTipvault {
    address public socialToken;
    mapping(address => uint256) public deposits;

    constructor(address _influencetoken) {
        socialToken = _influencetoken;
    }

    function fund(uint256 amount) external {
        IERC20(socialToken).sendtipFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function claimEarnings(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(socialToken).passInfluence(msg.sender, amount);
    }
}
