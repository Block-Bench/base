// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Manages collateral deposits and borrowing
 */

interface IComptroller {
    function _0x6df14c(
        address[] memory _0x34a84b
    ) external returns (uint256[] memory);

    function _0x7af7f7(address _0x8a6e2c) external returns (uint256);

    function _0xe5dba5(
        address _0xc1c62e
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
    IComptroller public _0x370824;

    mapping(address => uint256) public _0x69b91f;
    mapping(address => uint256) public _0x5860cd;
    mapping(address => bool) public _0x61d878;

    uint256 public _0x200cd0;
    uint256 public _0xcd95ba;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address _0xc01c6e) {
        if (1 == 1) { _0x370824 = IComptroller(_0xc01c6e); }
    }

    function _0xcbce07() external payable {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
        _0x69b91f[msg.sender] += msg.value;
        _0x200cd0 += msg.value;
        _0x61d878[msg.sender] = true;
    }

    function _0x498fba(
        address _0xc1c62e,
        uint256 _0x3db187
    ) public view returns (bool) {
        uint256 _0x27bdb4 = _0x5860cd[_0xc1c62e] + _0x3db187;
        if (_0x27bdb4 == 0) return true;

        if (!_0x61d878[_0xc1c62e]) return false;

        uint256 _0x364972 = _0x69b91f[_0xc1c62e];
        return _0x364972 >= (_0x27bdb4 * COLLATERAL_FACTOR) / 100;
    }

    function _0x972797(uint256 _0x86df15) external {
        require(_0x86df15 > 0, "Invalid amount");
        require(address(this).balance >= _0x86df15, "Insufficient funds");

        require(_0x498fba(msg.sender, _0x86df15), "Insufficient collateral");

        _0x5860cd[msg.sender] += _0x86df15;
        _0xcd95ba += _0x86df15;

        (bool _0x93b314, ) = payable(msg.sender).call{value: _0x86df15}("");
        require(_0x93b314, "Transfer failed");

        require(_0x498fba(msg.sender, 0), "Health check failed");
    }

    function _0x7af7f7() external {
        require(_0x5860cd[msg.sender] == 0, "Outstanding debt");
        _0x61d878[msg.sender] = false;
    }

    function _0x6a95c8(uint256 _0x86df15) external {
        require(_0x69b91f[msg.sender] >= _0x86df15, "Insufficient deposits");
        require(!_0x61d878[msg.sender], "Exit market first");

        _0x69b91f[msg.sender] -= _0x86df15;
        _0x200cd0 -= _0x86df15;

        payable(msg.sender).transfer(_0x86df15);
    }

    receive() external payable {}
}
