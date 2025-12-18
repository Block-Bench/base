// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Manages collateral deposits and borrowing
 */

interface IComptroller {
    function _0x0cfa95(
        address[] memory _0xf9aa8a
    ) external returns (uint256[] memory);

    function _0x11c57d(address _0xac4421) external returns (uint256);

    function _0x1f2e2f(
        address _0xda3229
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public _0x8970e6;

    mapping(address => uint256) public _0x684e70;
    mapping(address => uint256) public _0xc8a40e;
    mapping(address => bool) public _0x94a9dd;

    uint256 public _0x76fbc5;
    uint256 public _0x3adfde;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address _0x3218f7) {
        _0x8970e6 = IComptroller(_0x3218f7);
    }

    function _0x21201c() external payable {
        _0x684e70[msg.sender] += msg.value;
        _0x76fbc5 += msg.value;
        _0x94a9dd[msg.sender] = true;
    }

    function _0xdafb03(
        address _0xda3229,
        uint256 _0xb7ca25
    ) public view returns (bool) {
        uint256 _0x02f17a = _0xc8a40e[_0xda3229] + _0xb7ca25;
        if (_0x02f17a == 0) return true;

        if (!_0x94a9dd[_0xda3229]) return false;

        uint256 _0x9cd490 = _0x684e70[_0xda3229];
        return _0x9cd490 >= (_0x02f17a * COLLATERAL_FACTOR) / 100;
    }

    function _0x2d86f1(uint256 _0x03275b) external {
        require(_0x03275b > 0, "Invalid amount");
        require(address(this).balance >= _0x03275b, "Insufficient funds");

        require(_0xdafb03(msg.sender, _0x03275b), "Insufficient collateral");

        _0xc8a40e[msg.sender] += _0x03275b;
        _0x3adfde += _0x03275b;

        (bool _0xf63c1e, ) = payable(msg.sender).call{value: _0x03275b}("");
        require(_0xf63c1e, "Transfer failed");

        require(_0xdafb03(msg.sender, 0), "Health check failed");
    }

    function _0x11c57d() external {
        require(_0xc8a40e[msg.sender] == 0, "Outstanding debt");
        _0x94a9dd[msg.sender] = false;
    }

    function _0xe2df0c(uint256 _0x03275b) external {
        require(_0x684e70[msg.sender] >= _0x03275b, "Insufficient deposits");
        require(!_0x94a9dd[msg.sender], "Exit market first");

        _0x684e70[msg.sender] -= _0x03275b;
        _0x76fbc5 -= _0x03275b;

        payable(msg.sender).transfer(_0x03275b);
    }

    receive() external payable {}
}
