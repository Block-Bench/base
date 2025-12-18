pragma solidity ^0.8.0;

interface IERC20 {
    function _0x40cdb3(address _0xc4e2e2) external view returns (uint256);

    function transfer(address _0x463049, uint256 _0xa603ea) external returns (bool);

    function _0xdb391c(
        address from,
        address _0x463049,
        uint256 _0xa603ea
    ) external returns (bool);
}

contract LiquidityPool {
    address public _0x1f21c7;
    address public _0xe873dd;
    address public _0xae2feb;

    uint256 public _0x0dc1d6;
    uint256 public _0xe73952;
    uint256 public _0x15b6ef;

    bool public _0xbec0eb;

    event Initialized(address _0x1f21c7, address _0x4c85fa, address _0xe9d8e3);

    function _0x4973cf(
        address _0x164dfe,
        address _0x1c06c5,
        address _0x8cc525,
        uint256 _0x48dfed
    ) external {
        _0x1f21c7 = _0x164dfe;
        _0xe873dd = _0x1c06c5;
        _0xae2feb = _0x8cc525;
        _0x0dc1d6 = _0x48dfed;

        _0xbec0eb = true;

        emit Initialized(_0x164dfe, _0x1c06c5, _0x8cc525);
    }

    function _0x773d83(uint256 _0x015598, uint256 _0x0ed6fd) external {
        require(_0xbec0eb, "Not initialized");

        IERC20(_0xe873dd)._0xdb391c(msg.sender, address(this), _0x015598);
        IERC20(_0xae2feb)._0xdb391c(msg.sender, address(this), _0x0ed6fd);

        _0xe73952 += _0x015598;
        _0x15b6ef += _0x0ed6fd;
    }

    function _0x4f5d6c(
        address _0xf947c2,
        address _0xdfca67,
        uint256 _0xda9b57
    ) external returns (uint256 _0xeffe69) {
        require(_0xbec0eb, "Not initialized");
        require(
            (_0xf947c2 == _0xe873dd && _0xdfca67 == _0xae2feb) ||
                (_0xf947c2 == _0xae2feb && _0xdfca67 == _0xe873dd),
            "Invalid token pair"
        );

        IERC20(_0xf947c2)._0xdb391c(msg.sender, address(this), _0xda9b57);

        if (_0xf947c2 == _0xe873dd) {
            _0xeffe69 = (_0x15b6ef * _0xda9b57) / (_0xe73952 + _0xda9b57);
            _0xe73952 += _0xda9b57;
            _0x15b6ef -= _0xeffe69;
        } else {
            _0xeffe69 = (_0xe73952 * _0xda9b57) / (_0x15b6ef + _0xda9b57);
            _0x15b6ef += _0xda9b57;
            _0xe73952 -= _0xeffe69;
        }

        uint256 _0x4d3340 = (_0xeffe69 * _0x0dc1d6) / 10000;
        _0xeffe69 -= _0x4d3340;

        IERC20(_0xdfca67).transfer(msg.sender, _0xeffe69);
        IERC20(_0xdfca67).transfer(_0x1f21c7, _0x4d3340);

        return _0xeffe69;
    }

    function _0xfbc5f7() external {
        require(msg.sender == _0x1f21c7, "Only maintainer");

        uint256 _0xd0c969 = IERC20(_0xe873dd)._0x40cdb3(address(this));
        uint256 _0x23a3e5 = IERC20(_0xae2feb)._0x40cdb3(address(this));

        if (_0xd0c969 > _0xe73952) {
            uint256 _0xa8e0f6 = _0xd0c969 - _0xe73952;
            IERC20(_0xe873dd).transfer(_0x1f21c7, _0xa8e0f6);
        }

        if (_0x23a3e5 > _0x15b6ef) {
            uint256 _0xa8e0f6 = _0x23a3e5 - _0x15b6ef;
            IERC20(_0xae2feb).transfer(_0x1f21c7, _0xa8e0f6);
        }
    }
}