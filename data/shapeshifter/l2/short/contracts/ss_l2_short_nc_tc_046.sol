pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address l, uint256 i) external returns (bool);

    function e(address h) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public j;

    mapping(address => bool) public a;

    event Withdrawal(address k, address l, uint256 i);

    constructor() {
        j = msg.sender;
    }

    modifier d() {
        require(msg.sender == j, "Not owner");
        _;
    }

    function f(
        address k,
        address l,
        uint256 i
    ) external d {
        if (k == address(0)) {
            payable(l).transfer(i);
        } else {
            IERC20(k).transfer(l, i);
        }

        emit Withdrawal(k, l, i);
    }

    function b(address k) external d {
        uint256 balance;
        if (k == address(0)) {
            balance = address(this).balance;
            payable(j).transfer(balance);
        } else {
            balance = IERC20(k).e(address(this));
            IERC20(k).transfer(j, balance);
        }

        emit Withdrawal(k, j, balance);
    }

    function c(address g) external d {
        j = g;
    }

    receive() external payable {}
}