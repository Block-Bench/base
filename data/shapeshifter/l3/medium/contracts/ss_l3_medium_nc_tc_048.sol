pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xeac4a6, uint256 _0xc1ef31) external returns (bool);

    function _0x559b2a(
        address from,
        address _0xeac4a6,
        uint256 _0xc1ef31
    ) external returns (bool);

    function _0x7f1a1b(address _0x828914) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public _0xf49e5f;

    string public _0xf870e8 = "Sonne WETH";
    string public _0x45de46 = "soWETH";
    uint8 public _0x47160b = 8;

    uint256 public _0x7296df;
    mapping(address => uint256) public _0x7f1a1b;

    uint256 public _0x1ed576;
    uint256 public _0x0d8656;

    event Mint(address _0xd88cb2, uint256 _0x4ff115, uint256 _0x266739);
    event Redeem(address _0x4dbd52, uint256 _0x7f9a9c, uint256 _0xbdccef);

    constructor(address _0xd07ed4) {
        if (gasleft() > 0) { _0xf49e5f = IERC20(_0xd07ed4); }
    }

    function _0x03d485() public view returns (uint256) {
        if (_0x7296df == 0) {
            return 1e18;
        }

        uint256 _0xa306e5 = _0xf49e5f._0x7f1a1b(address(this));

        uint256 _0xb64f08 = _0xa306e5 + _0x1ed576 - _0x0d8656;

        return (_0xb64f08 * 1e18) / _0x7296df;
    }

    function _0xcdc759(uint256 _0x4ff115) external returns (uint256) {
        require(_0x4ff115 > 0, "Zero mint");

        uint256 _0xa54211 = _0x03d485();

        uint256 _0x266739 = (_0x4ff115 * 1e18) / _0xa54211;

        _0x7296df += _0x266739;
        _0x7f1a1b[msg.sender] += _0x266739;

        _0xf49e5f._0x559b2a(msg.sender, address(this), _0x4ff115);

        emit Mint(msg.sender, _0x4ff115, _0x266739);
        return _0x266739;
    }

    function _0x39cda0(uint256 _0xbdccef) external returns (uint256) {
        require(_0x7f1a1b[msg.sender] >= _0xbdccef, "Insufficient balance");

        uint256 _0xa54211 = _0x03d485();

        uint256 _0x7f9a9c = (_0xbdccef * _0xa54211) / 1e18;

        _0x7f1a1b[msg.sender] -= _0xbdccef;
        _0x7296df -= _0xbdccef;

        _0xf49e5f.transfer(msg.sender, _0x7f9a9c);

        emit Redeem(msg.sender, _0x7f9a9c, _0xbdccef);
        return _0x7f9a9c;
    }

    function _0x7d3351(
        address _0x828914
    ) external view returns (uint256) {
        uint256 _0xa54211 = _0x03d485();

        return (_0x7f1a1b[_0x828914] * _0xa54211) / 1e18;
    }
}