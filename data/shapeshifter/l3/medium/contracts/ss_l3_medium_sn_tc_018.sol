// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x4fcf21(address _0x673e3d) external view returns (uint256);

    function transfer(address _0x6f6bd8, uint256 _0xf18e28) external returns (bool);
}

contract TokenPool {
    struct Token {
        address _0xe07574;
        uint256 balance;
        uint256 _0xbf766c;
    }

    mapping(address => Token) public _0x6e86b8;
    address[] public _0xcf0f5a;
    uint256 public _0xf54272;

    constructor() {
        _0xf54272 = 100;
    }

    function _0xa00609(address _0x0198b5, uint256 _0x9506db) external {
        _0x6e86b8[_0x0198b5] = Token({_0xe07574: _0x0198b5, balance: 0, _0xbf766c: _0x9506db});
        _0xcf0f5a.push(_0x0198b5);
    }

    function _0x1c9e57(
        address _0x483290,
        address _0xebd25b,
        uint256 _0xb50946
    ) external returns (uint256 _0xc5ed63) {
        require(_0x6e86b8[_0x483290]._0xe07574 != address(0), "Invalid token");
        require(_0x6e86b8[_0xebd25b]._0xe07574 != address(0), "Invalid token");

        IERC20(_0x483290).transfer(address(this), _0xb50946);
        _0x6e86b8[_0x483290].balance += _0xb50946;

        _0xc5ed63 = _0x9ea37f(_0x483290, _0xebd25b, _0xb50946);

        require(
            _0x6e86b8[_0xebd25b].balance >= _0xc5ed63,
            "Insufficient liquidity"
        );
        _0x6e86b8[_0xebd25b].balance -= _0xc5ed63;
        IERC20(_0xebd25b).transfer(msg.sender, _0xc5ed63);

        _0x2b51b5();

        return _0xc5ed63;
    }

    function _0x9ea37f(
        address _0x483290,
        address _0xebd25b,
        uint256 _0xb50946
    ) public view returns (uint256) {
        uint256 _0x7ceef4 = _0x6e86b8[_0x483290]._0xbf766c;
        uint256 _0x471dfc = _0x6e86b8[_0xebd25b]._0xbf766c;
        uint256 _0x8048e2 = _0x6e86b8[_0xebd25b].balance;

        uint256 _0x0f8eab = _0x8048e2 * _0xb50946 * _0x471dfc;
        uint256 _0x31de7a = _0x6e86b8[_0x483290].balance *
            _0x7ceef4 +
            _0xb50946 *
            _0x471dfc;

        return _0x0f8eab / _0x31de7a;
    }

    function _0x2b51b5() internal {
        uint256 _0xac3b03 = 0;

        for (uint256 i = 0; i < _0xcf0f5a.length; i++) {
            address _0x0198b5 = _0xcf0f5a[i];
            _0xac3b03 += _0x6e86b8[_0x0198b5].balance;
        }

        for (uint256 i = 0; i < _0xcf0f5a.length; i++) {
            address _0x0198b5 = _0xcf0f5a[i];
            _0x6e86b8[_0x0198b5]._0xbf766c = (_0x6e86b8[_0x0198b5].balance * 100) / _0xac3b03;
        }
    }

    function _0x016c7d(address _0x0198b5) external view returns (uint256) {
        return _0x6e86b8[_0x0198b5]._0xbf766c;
    }

    function _0xd6dbe6(address _0x0198b5, uint256 _0xf18e28) external {
        require(_0x6e86b8[_0x0198b5]._0xe07574 != address(0), "Invalid token");
        IERC20(_0x0198b5).transfer(address(this), _0xf18e28);
        _0x6e86b8[_0x0198b5].balance += _0xf18e28;
        _0x2b51b5();
    }
}
