// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundToken {
    function borrow(uint256 amount) external;
    function repayBorrow(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function mint(uint256 amount) external;
}

contract HundredFinanceMarket {
    mapping(address => uint256) public accountBorrows;
    mapping(address => uint256) public accountTokens;

    address public underlying;
    uint256 public totalBorrows;

    bool private _locked;

    modifier nonReentrant() {
        require(!_locked, "Reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function borrow(uint256 amount) external nonReentrant {
        accountBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).transfer(msg.sender, amount);
    }

    function repayBorrow(uint256 amount) external {
        IERC20(underlying).transferFrom(msg.sender, address(this), amount);

        accountBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}
