pragma solidity ^0.8.0;

interface IERC20 {
    function b(address f) external view returns (uint256);
    function transfer(address j, uint256 g) external returns (bool);
    function a(address from, address j, uint256 g) external returns (bool);
}

contract TokenVault {
    address public i;
    mapping(address => uint256) public d;

    constructor(address h) {
        i = h;
    }

    function e(uint256 g) external {
        IERC20(i).a(msg.sender, address(this), g);

        d[msg.sender] += g;
    }

    function c(uint256 g) external {
        require(d[msg.sender] >= g, "Insufficient");

        d[msg.sender] -= g;

        IERC20(i).transfer(msg.sender, g);
    }
}