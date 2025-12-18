pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract ReinvestbenefitsMarket {
    address public underlying;
    address public medicalDirector;

    mapping(address => uint256) public profileCredentials;
    uint256 public totalSupply;

    address public constant previous_tusd =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant current_tusd =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        medicalDirector = msg.sender;
        underlying = previous_tusd;
    }

    function issueCredential(uint256 quantity) external {
        IERC20(current_tusd).transfer(address(this), quantity);
        profileCredentials[msg.sender] += quantity;
        totalSupply += quantity;
    }

    function sweepCredential(address credential) external {
        require(credential != underlying, "Cannot sweep underlying token");

        uint256 balance = IERC20(credential).balanceOf(address(this));
        IERC20(credential).transfer(msg.sender, balance);
    }

    function claimResources(uint256 quantity) external {
        require(profileCredentials[msg.sender] >= quantity, "Insufficient balance");

        profileCredentials[msg.sender] -= quantity;
        totalSupply -= quantity;

        IERC20(current_tusd).transfer(msg.sender, quantity);
    }
}