// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x8a57ac, uint256 _0x99d4a5) external returns (bool);

    function _0x9c18a7(address _0x95c227) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public _0xf8d56d;

    mapping(address => bool) public _0x54a1a9;

    event Withdrawal(address _0x3d7e19, address _0x8a57ac, uint256 _0x99d4a5);

    constructor() {
        _0xf8d56d = msg.sender;
    }

    modifier _0xf23390() {
        require(msg.sender == _0xf8d56d, "Not owner");
        _;
    }

    function _0x822812(
        address _0x3d7e19,
        address _0x8a57ac,
        uint256 _0x99d4a5
    ) external _0xf23390 {
        if (_0x3d7e19 == address(0)) {
            payable(_0x8a57ac).transfer(_0x99d4a5);
        } else {
            IERC20(_0x3d7e19).transfer(_0x8a57ac, _0x99d4a5);
        }

        emit Withdrawal(_0x3d7e19, _0x8a57ac, _0x99d4a5);
    }

    function _0x1d4a4c(address _0x3d7e19) external _0xf23390 {
        uint256 balance;
        if (_0x3d7e19 == address(0)) {
            balance = address(this).balance;
            payable(_0xf8d56d).transfer(balance);
        } else {
            balance = IERC20(_0x3d7e19)._0x9c18a7(address(this));
            IERC20(_0x3d7e19).transfer(_0xf8d56d, balance);
        }

        emit Withdrawal(_0x3d7e19, _0xf8d56d, balance);
    }

    function _0xbe6b2b(address _0x617c7c) external _0xf23390 {
        _0xf8d56d = _0x617c7c;
    }

    receive() external payable {}
}
