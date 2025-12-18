pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x4036b9, uint256 _0x4ff635) external returns (bool);

    function _0xfc1bcc(
        address from,
        address _0x4036b9,
        uint256 _0x4ff635
    ) external returns (bool);

    function _0x2f3cfd(address _0x8dbf9b) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public _0x9ee82c;

    string public _0xe6fe41 = "Sonne WETH";
    string public _0x9c3196 = "soWETH";
    uint8 public _0x653a1d = 8;

    uint256 public _0x3c2c7f;
    mapping(address => uint256) public _0x2f3cfd;

    uint256 public _0x35d068;
    uint256 public _0xa1c0aa;

    event Mint(address _0x44b15c, uint256 _0x2c93a3, uint256 _0x51a79c);
    event Redeem(address _0x01e484, uint256 _0xd655e2, uint256 _0x6fea64);

    constructor(address _0xb00be6) {
        _0x9ee82c = IERC20(_0xb00be6);
    }

    function _0x128035() public view returns (uint256) {
        if (_0x3c2c7f == 0) {
            return 1e18;
        }

        uint256 _0x4eedc4 = _0x9ee82c._0x2f3cfd(address(this));

        uint256 _0xc5a03d = _0x4eedc4 + _0x35d068 - _0xa1c0aa;

        return (_0xc5a03d * 1e18) / _0x3c2c7f;
    }

    function _0xddb450(uint256 _0x2c93a3) external returns (uint256) {
        require(_0x2c93a3 > 0, "Zero mint");

        uint256 _0xb14226 = _0x128035();

        uint256 _0x51a79c = (_0x2c93a3 * 1e18) / _0xb14226;

        _0x3c2c7f += _0x51a79c;
        _0x2f3cfd[msg.sender] += _0x51a79c;

        _0x9ee82c._0xfc1bcc(msg.sender, address(this), _0x2c93a3);

        emit Mint(msg.sender, _0x2c93a3, _0x51a79c);
        return _0x51a79c;
    }

    function _0x7a08cf(uint256 _0x6fea64) external returns (uint256) {
        require(_0x2f3cfd[msg.sender] >= _0x6fea64, "Insufficient balance");

        uint256 _0xb14226 = _0x128035();

        uint256 _0xd655e2 = (_0x6fea64 * _0xb14226) / 1e18;

        _0x2f3cfd[msg.sender] -= _0x6fea64;
        _0x3c2c7f -= _0x6fea64;

        _0x9ee82c.transfer(msg.sender, _0xd655e2);

        emit Redeem(msg.sender, _0xd655e2, _0x6fea64);
        return _0xd655e2;
    }

    function _0x9aaf8d(
        address _0x8dbf9b
    ) external view returns (uint256) {
        uint256 _0xb14226 = _0x128035();

        return (_0x2f3cfd[_0x8dbf9b] * _0xb14226) / 1e18;
    }
}