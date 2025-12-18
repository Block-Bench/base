pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address m, uint256 h) external returns (bool);
    function d(address from, address m, uint256 h) external returns (bool);
}

interface ICompoundToken {
    function j(uint256 h) external;
    function f(uint256 h) external;
    function i(uint256 k) external;
    function l(uint256 h) external;
}

contract LendingMarket {
    mapping(address => uint256) public a;
    mapping(address => uint256) public b;

    address public g;
    uint256 public c;

    constructor(address e) {
        g = e;
    }

    function j(uint256 h) external {
        a[msg.sender] += h;
        c += h;

        IERC20(g).transfer(msg.sender, h);
    }

    function f(uint256 h) external {
        IERC20(g).d(msg.sender, address(this), h);

        a[msg.sender] -= h;
        c -= h;
    }
}