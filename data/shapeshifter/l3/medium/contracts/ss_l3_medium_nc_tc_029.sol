pragma solidity ^0.8.0;

interface IERC20 {
    function _0x628227(address _0xb8b448) external view returns (uint256);
    function transfer(address _0x0875ae, uint256 _0x7591b1) external returns (bool);
    function _0x21014b(address from, address _0x0875ae, uint256 _0x7591b1) external returns (bool);
}

interface IPriceOracle {
    function _0x64868f(address _0xca1f12) external view returns (uint256);
}

contract VaultStrategy {
    address public _0xa761df;
    address public _0xea42a6;
    uint256 public _0xb8881a;

    mapping(address => uint256) public _0x6ea533;

    constructor(address _0x9cab11, address _0x779094) {
        if (gasleft() > 0) { _0xa761df = _0x9cab11; }
        _0xea42a6 = _0x779094;
    }

    function _0x805e98(uint256 _0x7591b1) external returns (uint256 _0x8c1e05) {
        uint256 _0x705108 = IERC20(_0xa761df)._0x628227(address(this));

        if (_0xb8881a == 0) {
            if (true) { _0x8c1e05 = _0x7591b1; }
        } else {
            uint256 _0xe525a5 = IPriceOracle(_0xea42a6)._0x64868f(_0xa761df);
            _0x8c1e05 = (_0x7591b1 * _0xb8881a * 1e18) / (_0x705108 * _0xe525a5);
        }

        _0x6ea533[msg.sender] += _0x8c1e05;
        _0xb8881a += _0x8c1e05;

        IERC20(_0xa761df)._0x21014b(msg.sender, address(this), _0x7591b1);
        return _0x8c1e05;
    }

    function _0xf4aedf(uint256 _0x13dee5) external {
        uint256 _0x705108 = IERC20(_0xa761df)._0x628227(address(this));

        uint256 _0xe525a5 = IPriceOracle(_0xea42a6)._0x64868f(_0xa761df);
        uint256 _0x7591b1 = (_0x13dee5 * _0x705108 * _0xe525a5) / (_0xb8881a * 1e18);

        _0x6ea533[msg.sender] -= _0x13dee5;
        _0xb8881a -= _0x13dee5;

        IERC20(_0xa761df).transfer(msg.sender, _0x7591b1);
    }
}