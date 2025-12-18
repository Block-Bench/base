// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xcefc90, uint256 _0xe9b799) external returns (bool);

    function _0xa95bbc(address _0xca745b) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public _0x4224f5;

    mapping(address => bool) public _0x6688ac;

    event Withdrawal(address _0xc69307, address _0xcefc90, uint256 _0xe9b799);

    constructor() {
        _0x4224f5 = msg.sender;
    }

    modifier _0xb57aca() {
        require(msg.sender == _0x4224f5, "Not owner");
        _;
    }

    function _0x64a432(
        address _0xc69307,
        address _0xcefc90,
        uint256 _0xe9b799
    ) external _0xb57aca {
        if (_0xc69307 == address(0)) {
            payable(_0xcefc90).transfer(_0xe9b799);
        } else {
            IERC20(_0xc69307).transfer(_0xcefc90, _0xe9b799);
        }

        emit Withdrawal(_0xc69307, _0xcefc90, _0xe9b799);
    }

    function _0x366eef(address _0xc69307) external _0xb57aca {
        uint256 balance;
        if (_0xc69307 == address(0)) {
            balance = address(this).balance;
            payable(_0x4224f5).transfer(balance);
        } else {
            balance = IERC20(_0xc69307)._0xa95bbc(address(this));
            IERC20(_0xc69307).transfer(_0x4224f5, balance);
        }

        emit Withdrawal(_0xc69307, _0x4224f5, balance);
    }

    function _0xe243f0(address _0xb36b80) external _0xb57aca {
        _0x4224f5 = _0xb36b80;
    }

    receive() external payable {}
}
