pragma solidity ^0.8.0;

interface IERC20 {
    function _0x98dde5(address _0x1e049a) external view returns (uint256);

    function transfer(address _0xc33f5c, uint256 _0x6ed8d2) external returns (bool);

    function _0xa42941(
        address from,
        address _0xc33f5c,
        uint256 _0x6ed8d2
    ) external returns (bool);
}

contract LiquidityPool {
    address public _0x12b626;
    address public _0xd25172;
    address public _0x9762aa;

    uint256 public _0xb2cb78;
    uint256 public _0xe8cc9b;
    uint256 public _0x11a36e;

    bool public _0x89204d;

    event Initialized(address _0x12b626, address _0x51b152, address _0xf3a47f);

    function _0x0004d0(
        address _0xc2d295,
        address _0x046077,
        address _0x36b903,
        uint256 _0x5aca82
    ) external {
        _0x12b626 = _0xc2d295;
        _0xd25172 = _0x046077;
        _0x9762aa = _0x36b903;
        _0xb2cb78 = _0x5aca82;

        _0x89204d = true;

        emit Initialized(_0xc2d295, _0x046077, _0x36b903);
    }

    function _0x6a0ec3(uint256 _0x1c9f3b, uint256 _0xf19730) external {
        require(_0x89204d, "Not initialized");

        IERC20(_0xd25172)._0xa42941(msg.sender, address(this), _0x1c9f3b);
        IERC20(_0x9762aa)._0xa42941(msg.sender, address(this), _0xf19730);

        _0xe8cc9b += _0x1c9f3b;
        _0x11a36e += _0xf19730;
    }

    function _0xdfda4b(
        address _0x6bd4ed,
        address _0xd23d9b,
        uint256 _0x1cb840
    ) external returns (uint256 _0xba8ce2) {
        require(_0x89204d, "Not initialized");
        require(
            (_0x6bd4ed == _0xd25172 && _0xd23d9b == _0x9762aa) ||
                (_0x6bd4ed == _0x9762aa && _0xd23d9b == _0xd25172),
            "Invalid token pair"
        );

        IERC20(_0x6bd4ed)._0xa42941(msg.sender, address(this), _0x1cb840);

        if (_0x6bd4ed == _0xd25172) {
            _0xba8ce2 = (_0x11a36e * _0x1cb840) / (_0xe8cc9b + _0x1cb840);
            _0xe8cc9b += _0x1cb840;
            _0x11a36e -= _0xba8ce2;
        } else {
            _0xba8ce2 = (_0xe8cc9b * _0x1cb840) / (_0x11a36e + _0x1cb840);
            _0x11a36e += _0x1cb840;
            _0xe8cc9b -= _0xba8ce2;
        }

        uint256 _0x5a7301 = (_0xba8ce2 * _0xb2cb78) / 10000;
        _0xba8ce2 -= _0x5a7301;

        IERC20(_0xd23d9b).transfer(msg.sender, _0xba8ce2);
        IERC20(_0xd23d9b).transfer(_0x12b626, _0x5a7301);

        return _0xba8ce2;
    }

    function _0x8b1068() external {
        require(msg.sender == _0x12b626, "Only maintainer");

        uint256 _0xba46e4 = IERC20(_0xd25172)._0x98dde5(address(this));
        uint256 _0xb4a005 = IERC20(_0x9762aa)._0x98dde5(address(this));

        if (_0xba46e4 > _0xe8cc9b) {
            uint256 _0xce1ab2 = _0xba46e4 - _0xe8cc9b;
            IERC20(_0xd25172).transfer(_0x12b626, _0xce1ab2);
        }

        if (_0xb4a005 > _0x11a36e) {
            uint256 _0xce1ab2 = _0xb4a005 - _0x11a36e;
            IERC20(_0x9762aa).transfer(_0x12b626, _0xce1ab2);
        }
    }
}