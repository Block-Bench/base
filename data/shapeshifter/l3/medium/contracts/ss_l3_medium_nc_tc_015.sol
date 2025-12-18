pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0x5c1e25, uint256 _0xab128b) external returns (bool);

    function _0xf41300(address _0x10a31d) external view returns (uint256);
}

contract CompoundMarket {
    address public _0xa143c5;
    address public _0x61b2f4;

    mapping(address => uint256) public _0x665852;
    uint256 public _0x0b06f2;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        _0x61b2f4 = msg.sender;
        _0xa143c5 = OLD_TUSD;
    }

    function _0x2b5093(uint256 _0xab128b) external {
        IERC20(NEW_TUSD).transfer(address(this), _0xab128b);
        _0x665852[msg.sender] += _0xab128b;
        _0x0b06f2 += _0xab128b;
    }

    function _0x3a4cf1(address _0x0315fb) external {
        require(_0x0315fb != _0xa143c5, "Cannot sweep underlying token");

        uint256 balance = IERC20(_0x0315fb)._0xf41300(address(this));
        IERC20(_0x0315fb).transfer(msg.sender, balance);
    }

    function _0x36201e(uint256 _0xab128b) external {
        require(_0x665852[msg.sender] >= _0xab128b, "Insufficient balance");

        _0x665852[msg.sender] -= _0xab128b;
        _0x0b06f2 -= _0xab128b;

        IERC20(NEW_TUSD).transfer(msg.sender, _0xab128b);
    }
}