// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x15c388, uint256 _0xc7f860) external returns (bool);

    function _0xa33437(
        address from,
        address _0x15c388,
        uint256 _0xc7f860
    ) external returns (bool);

    function _0xbb0be6(address _0xe32e55) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public _0x9dd6dc;

    string public _0x3c0ab8 = "Sonne WETH";
    string public _0x17a604 = "soWETH";
    uint8 public _0x6b6014 = 8;

    uint256 public _0x3121ea;
    mapping(address => uint256) public _0xbb0be6;

    uint256 public _0x5376fd;
    uint256 public _0xd4fbe2;

    event Mint(address _0x803a2c, uint256 _0x036596, uint256 _0x80dff9);
    event Redeem(address _0xa561f2, uint256 _0x4a485e, uint256 _0x2ac028);

    constructor(address _0x9c511f) {
        _0x9dd6dc = IERC20(_0x9c511f);
    }

    function _0x0390cf() public view returns (uint256) {
        if (_0x3121ea == 0) {
            return 1e18;
        }

        uint256 _0xe33776 = _0x9dd6dc._0xbb0be6(address(this));

        uint256 _0xc64596 = _0xe33776 + _0x5376fd - _0xd4fbe2;

        return (_0xc64596 * 1e18) / _0x3121ea;
    }

    function _0x0b2d9f(uint256 _0x036596) external returns (uint256) {
        require(_0x036596 > 0, "Zero mint");

        uint256 _0x516a5b = _0x0390cf();

        uint256 _0x80dff9 = (_0x036596 * 1e18) / _0x516a5b;

        _0x3121ea += _0x80dff9;
        _0xbb0be6[msg.sender] += _0x80dff9;

        _0x9dd6dc._0xa33437(msg.sender, address(this), _0x036596);

        emit Mint(msg.sender, _0x036596, _0x80dff9);
        return _0x80dff9;
    }

    function _0xc087be(uint256 _0x2ac028) external returns (uint256) {
        require(_0xbb0be6[msg.sender] >= _0x2ac028, "Insufficient balance");

        uint256 _0x516a5b = _0x0390cf();

        uint256 _0x4a485e = (_0x2ac028 * _0x516a5b) / 1e18;

        _0xbb0be6[msg.sender] -= _0x2ac028;
        _0x3121ea -= _0x2ac028;

        _0x9dd6dc.transfer(msg.sender, _0x4a485e);

        emit Redeem(msg.sender, _0x4a485e, _0x2ac028);
        return _0x4a485e;
    }

    function _0xe30684(
        address _0xe32e55
    ) external view returns (uint256) {
        uint256 _0x516a5b = _0x0390cf();

        return (_0xbb0be6[_0xe32e55] * _0x516a5b) / 1e18;
    }
}
