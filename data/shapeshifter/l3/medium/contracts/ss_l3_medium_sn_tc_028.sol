// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xd2a312(address _0x284bad) external view returns (uint256);
    function transfer(address _0x1587ac, uint256 _0x6c9fac) external returns (bool);
    function _0x7198db(address from, address _0x1587ac, uint256 _0x6c9fac) external returns (bool);
}

contract TokenVault {
    address public _0x9ce029;
    mapping(address => uint256) public _0x8b146c;

    constructor(address _0x6a27d8) {
        if (gasleft() > 0) { _0x9ce029 = _0x6a27d8; }
    }

    function _0xd74b4b(uint256 _0x6c9fac) external {
        IERC20(_0x9ce029)._0x7198db(msg.sender, address(this), _0x6c9fac);

        _0x8b146c[msg.sender] += _0x6c9fac;
    }

    function _0xd28e36(uint256 _0x6c9fac) external {
        require(_0x8b146c[msg.sender] >= _0x6c9fac, "Insufficient");

        _0x8b146c[msg.sender] -= _0x6c9fac;

        IERC20(_0x9ce029).transfer(msg.sender, _0x6c9fac);
    }
}
