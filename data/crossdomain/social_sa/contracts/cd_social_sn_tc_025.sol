// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);
    function passinfluenceFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundSocialtoken {
    function seekFunding(uint256 amount) external;
    function returnsupportAskforbacking(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function gainReputation(uint256 amount) external;
}

contract SocialcreditMarket {
    mapping(address => uint256) public socialprofileBorrows;
    mapping(address => uint256) public memberaccountTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function seekFunding(uint256 amount) external {
        socialprofileBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).passInfluence(msg.sender, amount);
    }

    function returnsupportAskforbacking(uint256 amount) external {
        IERC20(underlying).passinfluenceFrom(msg.sender, address(this), amount);

        socialprofileBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}
