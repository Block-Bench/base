// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x094642(address _0x4ffa69) external view returns (uint256);
    function transfer(address _0xc7d3a3, uint256 _0xdb810b) external returns (bool);
    function _0xd93cf2(address from, address _0xc7d3a3, uint256 _0xdb810b) external returns (bool);
}

contract TokenVault {
    address public _0x869f76;
    mapping(address => uint256) public _0x79f17b;

    constructor(address _0xebc97f) {
        _0x869f76 = _0xebc97f;
    }

    function _0x2b9577(uint256 _0xdb810b) external {
        IERC20(_0x869f76)._0xd93cf2(msg.sender, address(this), _0xdb810b);

        _0x79f17b[msg.sender] += _0xdb810b;
    }

    function _0xe95949(uint256 _0xdb810b) external {
        require(_0x79f17b[msg.sender] >= _0xdb810b, "Insufficient");

        _0x79f17b[msg.sender] -= _0xdb810b;

        IERC20(_0x869f76).transfer(msg.sender, _0xdb810b);
    }
}
