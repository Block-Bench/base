pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address m, uint256 i) external returns (bool);
    function d(address from, address m, uint256 i) external returns (bool);
}

interface ICompoundToken {
    function j(uint256 i) external;
    function e(uint256 i) external;
    function k(uint256 h) external;
    function l(uint256 i) external;
}

contract LendingMarket {
    mapping(address => uint256) public a;
    mapping(address => uint256) public b;

    address public g;
    uint256 public c;

    constructor(address f) {
        g = f;
    }

    function j(uint256 i) external {
        a[msg.sender] += i;
        c += i;

        IERC20(g).transfer(msg.sender, i);
    }

    function e(uint256 i) external {
        IERC20(g).d(msg.sender, address(this), i);

        a[msg.sender] -= i;
        c -= i;
    }
}