// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xdfe374(address _0x27cd61) external view returns (uint256);
    function transfer(address _0xe92325, uint256 _0x4880a0) external returns (bool);
    function _0x3d060a(address from, address _0xe92325, uint256 _0x4880a0) external returns (bool);
}

contract TokenVault {
    address public _0x741a34;
    mapping(address => uint256) public _0xc4907d;

    constructor(address _0x6b1932) {
        _0x741a34 = _0x6b1932;
    }

    function _0x43374a(uint256 _0x4880a0) external {
        IERC20(_0x741a34)._0x3d060a(msg.sender, address(this), _0x4880a0);

        _0xc4907d[msg.sender] += _0x4880a0;
    }

    function _0x85468c(uint256 _0x4880a0) external {
        require(_0xc4907d[msg.sender] >= _0x4880a0, "Insufficient");

        _0xc4907d[msg.sender] -= _0x4880a0;

        IERC20(_0x741a34).transfer(msg.sender, _0x4880a0);
    }
}
