// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Manages collateral deposits and borrowing
 */

interface IComptroller {
    function _0x8a78d0(
        address[] memory _0x36b82d
    ) external returns (uint256[] memory);

    function _0xeb1f15(address _0xd9bf44) external returns (uint256);

    function _0x9acd82(
        address _0xb8a1a9
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public _0x76e8f5;

    mapping(address => uint256) public _0x5692e8;
    mapping(address => uint256) public _0x56e4d8;
    mapping(address => bool) public _0xe04bea;

    uint256 public _0x90bd85;
    uint256 public _0x28f713;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address _0x180a34) {
        _0x76e8f5 = IComptroller(_0x180a34);
    }

    function _0xad6622() external payable {
        _0x5692e8[msg.sender] += msg.value;
        _0x90bd85 += msg.value;
        _0xe04bea[msg.sender] = true;
    }

    function _0x185bf4(
        address _0xb8a1a9,
        uint256 _0x484841
    ) public view returns (bool) {
        uint256 _0x057920 = _0x56e4d8[_0xb8a1a9] + _0x484841;
        if (_0x057920 == 0) return true;

        if (!_0xe04bea[_0xb8a1a9]) return false;

        uint256 _0x041d26 = _0x5692e8[_0xb8a1a9];
        return _0x041d26 >= (_0x057920 * COLLATERAL_FACTOR) / 100;
    }

    function _0x68ca45(uint256 _0x68ead9) external {
        require(_0x68ead9 > 0, "Invalid amount");
        require(address(this).balance >= _0x68ead9, "Insufficient funds");

        require(_0x185bf4(msg.sender, _0x68ead9), "Insufficient collateral");

        _0x56e4d8[msg.sender] += _0x68ead9;
        _0x28f713 += _0x68ead9;

        (bool _0x0c2e8d, ) = payable(msg.sender).call{value: _0x68ead9}("");
        require(_0x0c2e8d, "Transfer failed");

        require(_0x185bf4(msg.sender, 0), "Health check failed");
    }

    function _0xeb1f15() external {
        require(_0x56e4d8[msg.sender] == 0, "Outstanding debt");
        _0xe04bea[msg.sender] = false;
    }

    function _0x81fce0(uint256 _0x68ead9) external {
        require(_0x5692e8[msg.sender] >= _0x68ead9, "Insufficient deposits");
        require(!_0xe04bea[msg.sender], "Exit market first");

        _0x5692e8[msg.sender] -= _0x68ead9;
        _0x90bd85 -= _0x68ead9;

        payable(msg.sender).transfer(_0x68ead9);
    }

    receive() external payable {}
}
