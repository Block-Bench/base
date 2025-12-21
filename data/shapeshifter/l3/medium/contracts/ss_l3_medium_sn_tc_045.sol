// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x6e63f1, uint256 _0x1434c8) external returns (bool);

    function _0xdb1f5c(
        address from,
        address _0x6e63f1,
        uint256 _0x1434c8
    ) external returns (bool);

    function _0x3a47b6(address _0xe90c8a) external view returns (uint256);

    function _0x996188(address _0x9eb404, uint256 _0x1434c8) external returns (bool);
}

interface IPendleMarket {
    function _0x43950b() external view returns (address[] memory);

    function _0xfbde48() external returns (uint256[] memory);

    function _0xe61e99(address _0x57a8a9) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public _0x07a13a;
    mapping(address => uint256) public _0x128d7b;

    function _0x223d65(address _0x16a995, uint256 _0x1434c8) external {
        IERC20(_0x16a995)._0xdb1f5c(msg.sender, address(this), _0x1434c8);
        _0x07a13a[_0x16a995][msg.sender] += _0x1434c8;
        _0x128d7b[_0x16a995] += _0x1434c8;
    }

    function _0xe61e99(address _0x16a995, address _0x57a8a9) external {
        uint256[] memory _0x801684 = IPendleMarket(_0x16a995)._0xe61e99(_0x57a8a9);

        for (uint256 i = 0; i < _0x801684.length; i++) {}
    }

    function _0x5151c2(address _0x16a995, uint256 _0x1434c8) external {
        require(
            _0x07a13a[_0x16a995][msg.sender] >= _0x1434c8,
            "Insufficient balance"
        );

        _0x07a13a[_0x16a995][msg.sender] -= _0x1434c8;
        _0x128d7b[_0x16a995] -= _0x1434c8;

        IERC20(_0x16a995).transfer(msg.sender, _0x1434c8);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public _0xdedc57;

    function _0x121611(address _0x16a995) external {
        _0xdedc57[_0x16a995] = true;
    }
}
