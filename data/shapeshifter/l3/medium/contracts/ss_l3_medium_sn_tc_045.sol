// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xa7f6e3, uint256 _0x014c62) external returns (bool);

    function _0x248b7e(
        address from,
        address _0xa7f6e3,
        uint256 _0x014c62
    ) external returns (bool);

    function _0xd8da4d(address _0xceb860) external view returns (uint256);

    function _0xf4b8a3(address _0xdca4e8, uint256 _0x014c62) external returns (bool);
}

interface IPendleMarket {
    function _0x238ab0() external view returns (address[] memory);

    function _0x31ef4d() external returns (uint256[] memory);

    function _0xf88f07(address _0x9bc562) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public _0x488d1d;
    mapping(address => uint256) public _0x2a0617;

    function _0xf3bdf8(address _0x382d97, uint256 _0x014c62) external {
        IERC20(_0x382d97)._0x248b7e(msg.sender, address(this), _0x014c62);
        _0x488d1d[_0x382d97][msg.sender] += _0x014c62;
        _0x2a0617[_0x382d97] += _0x014c62;
    }

    function _0xf88f07(address _0x382d97, address _0x9bc562) external {
        uint256[] memory _0xd2fd20 = IPendleMarket(_0x382d97)._0xf88f07(_0x9bc562);

        for (uint256 i = 0; i < _0xd2fd20.length; i++) {}
    }

    function _0xc3d72b(address _0x382d97, uint256 _0x014c62) external {
        require(
            _0x488d1d[_0x382d97][msg.sender] >= _0x014c62,
            "Insufficient balance"
        );

        _0x488d1d[_0x382d97][msg.sender] -= _0x014c62;
        _0x2a0617[_0x382d97] -= _0x014c62;

        IERC20(_0x382d97).transfer(msg.sender, _0x014c62);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public _0xe2ab3a;

    function _0x2698ae(address _0x382d97) external {
        _0xe2ab3a[_0x382d97] = true;
    }
}
