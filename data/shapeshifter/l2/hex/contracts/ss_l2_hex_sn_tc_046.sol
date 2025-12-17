// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x8aac0d, uint256 _0x8892d0) external returns (bool);

    function _0x8b2fa9(address _0xbf0c1d) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public _0x9f4d06;

    mapping(address => bool) public _0xd0cd62;

    event Withdrawal(address _0xcf5e8b, address _0x8aac0d, uint256 _0x8892d0);

    constructor() {
        _0x9f4d06 = msg.sender;
    }

    modifier _0x4cce1b() {
        require(msg.sender == _0x9f4d06, "Not owner");
        _;
    }

    function _0x1be36a(
        address _0xcf5e8b,
        address _0x8aac0d,
        uint256 _0x8892d0
    ) external _0x4cce1b {
        if (_0xcf5e8b == address(0)) {
            payable(_0x8aac0d).transfer(_0x8892d0);
        } else {
            IERC20(_0xcf5e8b).transfer(_0x8aac0d, _0x8892d0);
        }

        emit Withdrawal(_0xcf5e8b, _0x8aac0d, _0x8892d0);
    }

    function _0x98c177(address _0xcf5e8b) external _0x4cce1b {
        uint256 balance;
        if (_0xcf5e8b == address(0)) {
            balance = address(this).balance;
            payable(_0x9f4d06).transfer(balance);
        } else {
            balance = IERC20(_0xcf5e8b)._0x8b2fa9(address(this));
            IERC20(_0xcf5e8b).transfer(_0x9f4d06, balance);
        }

        emit Withdrawal(_0xcf5e8b, _0x9f4d06, balance);
    }

    function _0xbdcde4(address _0x783ce9) external _0x4cce1b {
        _0x9f4d06 = _0x783ce9;
    }

    receive() external payable {}
}
