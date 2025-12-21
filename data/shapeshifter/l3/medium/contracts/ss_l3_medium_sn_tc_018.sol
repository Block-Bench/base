// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xde418b(address _0xee7832) external view returns (uint256);

    function transfer(address _0x215cd3, uint256 _0x324ec2) external returns (bool);
}

contract TokenPool {
    struct Token {
        address _0x6561ef;
        uint256 balance;
        uint256 _0x3b4c97;
    }

    mapping(address => Token) public _0x0678d3;
    address[] public _0x2b5f08;
    uint256 public _0xfb5a99;

    constructor() {
        _0xfb5a99 = 100;
    }

    function _0xe092a4(address _0x852539, uint256 _0xfb4296) external {
        _0x0678d3[_0x852539] = Token({_0x6561ef: _0x852539, balance: 0, _0x3b4c97: _0xfb4296});
        _0x2b5f08.push(_0x852539);
    }

    function _0x6208d8(
        address _0x02a494,
        address _0xcc6ccf,
        uint256 _0x182624
    ) external returns (uint256 _0xb9944f) {
        require(_0x0678d3[_0x02a494]._0x6561ef != address(0), "Invalid token");
        require(_0x0678d3[_0xcc6ccf]._0x6561ef != address(0), "Invalid token");

        IERC20(_0x02a494).transfer(address(this), _0x182624);
        _0x0678d3[_0x02a494].balance += _0x182624;

        _0xb9944f = _0xd59a8f(_0x02a494, _0xcc6ccf, _0x182624);

        require(
            _0x0678d3[_0xcc6ccf].balance >= _0xb9944f,
            "Insufficient liquidity"
        );
        _0x0678d3[_0xcc6ccf].balance -= _0xb9944f;
        IERC20(_0xcc6ccf).transfer(msg.sender, _0xb9944f);

        _0x2c0e15();

        return _0xb9944f;
    }

    function _0xd59a8f(
        address _0x02a494,
        address _0xcc6ccf,
        uint256 _0x182624
    ) public view returns (uint256) {
        uint256 _0x0d47d3 = _0x0678d3[_0x02a494]._0x3b4c97;
        uint256 _0x20254c = _0x0678d3[_0xcc6ccf]._0x3b4c97;
        uint256 _0x6f2791 = _0x0678d3[_0xcc6ccf].balance;

        uint256 _0xbdaa05 = _0x6f2791 * _0x182624 * _0x20254c;
        uint256 _0xeca12c = _0x0678d3[_0x02a494].balance *
            _0x0d47d3 +
            _0x182624 *
            _0x20254c;

        return _0xbdaa05 / _0xeca12c;
    }

    function _0x2c0e15() internal {
        uint256 _0x6c89d4 = 0;

        for (uint256 i = 0; i < _0x2b5f08.length; i++) {
            address _0x852539 = _0x2b5f08[i];
            _0x6c89d4 += _0x0678d3[_0x852539].balance;
        }

        for (uint256 i = 0; i < _0x2b5f08.length; i++) {
            address _0x852539 = _0x2b5f08[i];
            _0x0678d3[_0x852539]._0x3b4c97 = (_0x0678d3[_0x852539].balance * 100) / _0x6c89d4;
        }
    }

    function _0xee499d(address _0x852539) external view returns (uint256) {
        return _0x0678d3[_0x852539]._0x3b4c97;
    }

    function _0xe2c607(address _0x852539, uint256 _0x324ec2) external {
        require(_0x0678d3[_0x852539]._0x6561ef != address(0), "Invalid token");
        IERC20(_0x852539).transfer(address(this), _0x324ec2);
        _0x0678d3[_0x852539].balance += _0x324ec2;
        _0x2c0e15();
    }
}
