pragma solidity ^0.8.0;

interface IERC20 {
    function _0x549b44(address _0xb766ca) external view returns (uint256);

    function transfer(address _0x29a4c9, uint256 _0xaffb9c) external returns (bool);
}

contract TokenPool {
    struct Token {
        address _0x465e88;
        uint256 balance;
        uint256 _0xfc29d9;
    }

    mapping(address => Token) public _0xb89f3b;
    address[] public _0x1cf30d;
    uint256 public _0x6ee6f2;

    constructor() {
        _0x6ee6f2 = 100;
    }

    function _0x1db16f(address _0xe7baea, uint256 _0x51c0bb) external {
        _0xb89f3b[_0xe7baea] = Token({_0x465e88: _0xe7baea, balance: 0, _0xfc29d9: _0x51c0bb});
        _0x1cf30d.push(_0xe7baea);
    }

    function _0x3bd051(
        address _0xdd1809,
        address _0xb4492d,
        uint256 _0x99a6c6
    ) external returns (uint256 _0xd282fd) {
        require(_0xb89f3b[_0xdd1809]._0x465e88 != address(0), "Invalid token");
        require(_0xb89f3b[_0xb4492d]._0x465e88 != address(0), "Invalid token");

        IERC20(_0xdd1809).transfer(address(this), _0x99a6c6);
        _0xb89f3b[_0xdd1809].balance += _0x99a6c6;

        _0xd282fd = _0xd1ff57(_0xdd1809, _0xb4492d, _0x99a6c6);

        require(
            _0xb89f3b[_0xb4492d].balance >= _0xd282fd,
            "Insufficient liquidity"
        );
        _0xb89f3b[_0xb4492d].balance -= _0xd282fd;
        IERC20(_0xb4492d).transfer(msg.sender, _0xd282fd);

        _0x884262();

        return _0xd282fd;
    }

    function _0xd1ff57(
        address _0xdd1809,
        address _0xb4492d,
        uint256 _0x99a6c6
    ) public view returns (uint256) {
        uint256 _0x699dac = _0xb89f3b[_0xdd1809]._0xfc29d9;
        uint256 _0xe198a3 = _0xb89f3b[_0xb4492d]._0xfc29d9;
        uint256 _0x2da5ad = _0xb89f3b[_0xb4492d].balance;

        uint256 _0x7b8044 = _0x2da5ad * _0x99a6c6 * _0xe198a3;
        uint256 _0x84ffc7 = _0xb89f3b[_0xdd1809].balance *
            _0x699dac +
            _0x99a6c6 *
            _0xe198a3;

        return _0x7b8044 / _0x84ffc7;
    }

    function _0x884262() internal {
        uint256 _0x46bbd4 = 0;

        for (uint256 i = 0; i < _0x1cf30d.length; i++) {
            address _0xe7baea = _0x1cf30d[i];
            _0x46bbd4 += _0xb89f3b[_0xe7baea].balance;
        }

        for (uint256 i = 0; i < _0x1cf30d.length; i++) {
            address _0xe7baea = _0x1cf30d[i];
            _0xb89f3b[_0xe7baea]._0xfc29d9 = (_0xb89f3b[_0xe7baea].balance * 100) / _0x46bbd4;
        }
    }

    function _0x091792(address _0xe7baea) external view returns (uint256) {
        return _0xb89f3b[_0xe7baea]._0xfc29d9;
    }

    function _0x7285ef(address _0xe7baea, uint256 _0xaffb9c) external {
        require(_0xb89f3b[_0xe7baea]._0x465e88 != address(0), "Invalid token");
        IERC20(_0xe7baea).transfer(address(this), _0xaffb9c);
        _0xb89f3b[_0xe7baea].balance += _0xaffb9c;
        _0x884262();
    }
}