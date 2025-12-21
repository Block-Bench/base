pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address l, uint256 i) external returns (bool);

    function e(address h) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public k;

    mapping(address => bool) public a;

    event Withdrawal(address j, address l, uint256 i);

    constructor() {
        k = msg.sender;
    }

    modifier d() {
        require(msg.sender == k, "Not owner");
        _;
    }

    function f(
        address j,
        address l,
        uint256 i
    ) external d {
        if (j == address(0)) {
            payable(l).transfer(i);
        } else {
            IERC20(j).transfer(l, i);
        }

        emit Withdrawal(j, l, i);
    }

    function c(address j) external d {
        uint256 balance;
        if (j == address(0)) {
            balance = address(this).balance;
            payable(k).transfer(balance);
        } else {
            balance = IERC20(j).e(address(this));
            IERC20(j).transfer(k, balance);
        }

        emit Withdrawal(j, k, balance);
    }

    function b(address g) external d {
        k = g;
    }

    receive() external payable {}
}