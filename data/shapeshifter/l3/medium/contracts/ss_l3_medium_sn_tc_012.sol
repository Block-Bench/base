// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Manages collateral deposits and borrowing
 */

interface IComptroller {
    function _0x25e70c(
        address[] memory _0xf9477b
    ) external returns (uint256[] memory);

    function _0xefedec(address _0xdf69a4) external returns (uint256);

    function _0x074b78(
        address _0xfec17d
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public _0x78465f;

    mapping(address => uint256) public _0xc9e5ab;
    mapping(address => uint256) public _0x7b7aea;
    mapping(address => bool) public _0x4ea777;

    uint256 public _0xd75c64;
    uint256 public _0x8e2242;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address _0x8b6028) {
        _0x78465f = IComptroller(_0x8b6028);
    }

    function _0xf0233f() external payable {
        _0xc9e5ab[msg.sender] += msg.value;
        _0xd75c64 += msg.value;
        _0x4ea777[msg.sender] = true;
    }

    function _0xeb84ce(
        address _0xfec17d,
        uint256 _0x774a64
    ) public view returns (bool) {
        uint256 _0x106fa8 = _0x7b7aea[_0xfec17d] + _0x774a64;
        if (_0x106fa8 == 0) return true;

        if (!_0x4ea777[_0xfec17d]) return false;

        uint256 _0x157065 = _0xc9e5ab[_0xfec17d];
        return _0x157065 >= (_0x106fa8 * COLLATERAL_FACTOR) / 100;
    }

    function _0x25084b(uint256 _0xa188b1) external {
        require(_0xa188b1 > 0, "Invalid amount");
        require(address(this).balance >= _0xa188b1, "Insufficient funds");

        require(_0xeb84ce(msg.sender, _0xa188b1), "Insufficient collateral");

        _0x7b7aea[msg.sender] += _0xa188b1;
        _0x8e2242 += _0xa188b1;

        (bool _0x77b5bd, ) = payable(msg.sender).call{value: _0xa188b1}("");
        require(_0x77b5bd, "Transfer failed");

        require(_0xeb84ce(msg.sender, 0), "Health check failed");
    }

    function _0xefedec() external {
        require(_0x7b7aea[msg.sender] == 0, "Outstanding debt");
        _0x4ea777[msg.sender] = false;
    }

    function _0x0db652(uint256 _0xa188b1) external {
        require(_0xc9e5ab[msg.sender] >= _0xa188b1, "Insufficient deposits");
        require(!_0x4ea777[msg.sender], "Exit market first");

        _0xc9e5ab[msg.sender] -= _0xa188b1;
        _0xd75c64 -= _0xa188b1;

        payable(msg.sender).transfer(_0xa188b1);
    }

    receive() external payable {}
}
