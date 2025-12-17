// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x14a00e, uint256 _0x05fe19) external returns (bool);
    function _0x675f09(address from, address _0x14a00e, uint256 _0x05fe19) external returns (bool);
}

interface ICompoundToken {
    function _0xc8d25a(uint256 _0x05fe19) external;
    function _0xeb4e15(uint256 _0x05fe19) external;
    function _0x5a49eb(uint256 _0x467ead) external;
    function _0x127374(uint256 _0x05fe19) external;
}

contract LendingMarket {
    mapping(address => uint256) public _0x39264f;
    mapping(address => uint256) public _0xd5bf56;

    address public _0x060239;
    uint256 public _0x3b57a3;

    constructor(address _0x2bf369) {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x060239 = _0x2bf369; }
    }

    function _0xc8d25a(uint256 _0x05fe19) external {
        _0x39264f[msg.sender] += _0x05fe19;
        _0x3b57a3 += _0x05fe19;

        IERC20(_0x060239).transfer(msg.sender, _0x05fe19);
    }

    function _0xeb4e15(uint256 _0x05fe19) external {
        IERC20(_0x060239)._0x675f09(msg.sender, address(this), _0x05fe19);

        _0x39264f[msg.sender] -= _0x05fe19;
        _0x3b57a3 -= _0x05fe19;
    }
}
