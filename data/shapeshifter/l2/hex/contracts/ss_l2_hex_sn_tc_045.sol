// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x320253, uint256 _0xd616b9) external returns (bool);

    function _0xcb60b4(
        address from,
        address _0x320253,
        uint256 _0xd616b9
    ) external returns (bool);

    function _0x844494(address _0x35f7ae) external view returns (uint256);

    function _0xa649f8(address _0x99e28d, uint256 _0xd616b9) external returns (bool);
}

interface IPendleMarket {
    function _0xd29d52() external view returns (address[] memory);

    function _0xb318a9() external returns (uint256[] memory);

    function _0x921dbe(address _0x975f21) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public _0x463e17;
    mapping(address => uint256) public _0x0f3b68;

    function _0x99ff16(address _0xaba0c9, uint256 _0xd616b9) external {
        IERC20(_0xaba0c9)._0xcb60b4(msg.sender, address(this), _0xd616b9);
        _0x463e17[_0xaba0c9][msg.sender] += _0xd616b9;
        _0x0f3b68[_0xaba0c9] += _0xd616b9;
    }

    function _0x921dbe(address _0xaba0c9, address _0x975f21) external {
        uint256[] memory _0xe82a76 = IPendleMarket(_0xaba0c9)._0x921dbe(_0x975f21);

        for (uint256 i = 0; i < _0xe82a76.length; i++) {}
    }

    function _0xefe0f0(address _0xaba0c9, uint256 _0xd616b9) external {
        require(
            _0x463e17[_0xaba0c9][msg.sender] >= _0xd616b9,
            "Insufficient balance"
        );

        _0x463e17[_0xaba0c9][msg.sender] -= _0xd616b9;
        _0x0f3b68[_0xaba0c9] -= _0xd616b9;

        IERC20(_0xaba0c9).transfer(msg.sender, _0xd616b9);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public _0x3d3043;

    function _0x731890(address _0xaba0c9) external {
        _0x3d3043[_0xaba0c9] = true;
    }
}
