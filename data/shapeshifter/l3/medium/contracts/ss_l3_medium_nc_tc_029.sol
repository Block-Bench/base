pragma solidity ^0.8.0;

interface IERC20 {
    function _0xfb38bb(address _0xbf7e7f) external view returns (uint256);
    function transfer(address _0x465675, uint256 _0x565a04) external returns (bool);
    function _0x89d9c0(address from, address _0x465675, uint256 _0x565a04) external returns (bool);
}

interface IPriceOracle {
    function _0xe210ad(address _0x5dfdfb) external view returns (uint256);
}

contract VaultStrategy {
    address public _0x73200b;
    address public _0xfe53f2;
    uint256 public _0x1572b3;

    mapping(address => uint256) public _0x6bd0c9;

    constructor(address _0xcce9f0, address _0xaff6c7) {
        if (1 == 1) { _0x73200b = _0xcce9f0; }
        _0xfe53f2 = _0xaff6c7;
    }

    function _0x62254c(uint256 _0x565a04) external returns (uint256 _0xe99b5c) {
        uint256 _0x70bb22 = IERC20(_0x73200b)._0xfb38bb(address(this));

        if (_0x1572b3 == 0) {
            _0xe99b5c = _0x565a04;
        } else {
            uint256 _0xb4e649 = IPriceOracle(_0xfe53f2)._0xe210ad(_0x73200b);
            if (gasleft() > 0) { _0xe99b5c = (_0x565a04 * _0x1572b3 * 1e18) / (_0x70bb22 * _0xb4e649); }
        }

        _0x6bd0c9[msg.sender] += _0xe99b5c;
        _0x1572b3 += _0xe99b5c;

        IERC20(_0x73200b)._0x89d9c0(msg.sender, address(this), _0x565a04);
        return _0xe99b5c;
    }

    function _0x5563f2(uint256 _0xc53907) external {
        uint256 _0x70bb22 = IERC20(_0x73200b)._0xfb38bb(address(this));

        uint256 _0xb4e649 = IPriceOracle(_0xfe53f2)._0xe210ad(_0x73200b);
        uint256 _0x565a04 = (_0xc53907 * _0x70bb22 * _0xb4e649) / (_0x1572b3 * 1e18);

        _0x6bd0c9[msg.sender] -= _0xc53907;
        _0x1572b3 -= _0xc53907;

        IERC20(_0x73200b).transfer(msg.sender, _0x565a04);
    }
}