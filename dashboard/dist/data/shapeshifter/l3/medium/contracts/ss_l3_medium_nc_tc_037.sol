pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x735784, uint256 _0xf8b920) external returns (bool);

    function _0x15276c(
        address from,
        address _0x735784,
        uint256 _0xf8b920
    ) external returns (bool);

    function _0xe6bd56(address _0x633999) external view returns (uint256);

    function _0xbb9a0d(address _0x1a901c, uint256 _0xf8b920) external returns (bool);
}

interface IAaveOracle {
    function _0x38d585(address _0x2430a3) external view returns (uint256);

    function _0xdefc97(
        address[] calldata _0x060d06,
        address[] calldata _0x3701de
    ) external;
}

interface ICurvePool {
    function _0xedc64e(
        int128 i,
        int128 j,
        uint256 _0x0a448c,
        uint256 _0xa05dc7
    ) external returns (uint256);

    function _0xdf7f15(
        int128 i,
        int128 j,
        uint256 _0x0a448c
    ) external view returns (uint256);

    function _0x68ecd9(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function _0xeefb99(
        address _0x2430a3,
        uint256 _0xf8b920,
        address _0x1e6567,
        uint16 _0x03b9af
    ) external;

    function _0xb4b3f4(
        address _0x2430a3,
        uint256 _0xf8b920,
        uint256 _0x7dcef1,
        uint16 _0x03b9af,
        address _0x1e6567
    ) external;

    function _0x8cf6cc(
        address _0x2430a3,
        uint256 _0xf8b920,
        address _0x735784
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public _0x3a3f99;
    mapping(address => uint256) public _0x3e80f2;
    mapping(address => uint256) public _0x33a9ae;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function _0xeefb99(
        address _0x2430a3,
        uint256 _0xf8b920,
        address _0x1e6567,
        uint16 _0x03b9af
    ) external override {
        IERC20(_0x2430a3)._0x15276c(msg.sender, address(this), _0xf8b920);
        _0x3e80f2[_0x1e6567] += _0xf8b920;
    }

    function _0xb4b3f4(
        address _0x2430a3,
        uint256 _0xf8b920,
        uint256 _0x7dcef1,
        uint16 _0x03b9af,
        address _0x1e6567
    ) external override {
        uint256 _0x670f52 = _0x3a3f99._0x38d585(msg.sender);
        uint256 _0x4ab089 = _0x3a3f99._0x38d585(_0x2430a3);

        uint256 _0x660f12 = (_0x3e80f2[msg.sender] * _0x670f52) /
            1e18;
        uint256 _0xe4af4c = (_0x660f12 * LTV) / BASIS_POINTS;

        uint256 _0xd7bcd8 = (_0xf8b920 * _0x4ab089) / 1e18;

        require(_0xd7bcd8 <= _0xe4af4c, "Insufficient collateral");

        _0x33a9ae[msg.sender] += _0xf8b920;
        IERC20(_0x2430a3).transfer(_0x1e6567, _0xf8b920);
    }

    function _0x8cf6cc(
        address _0x2430a3,
        uint256 _0xf8b920,
        address _0x735784
    ) external override returns (uint256) {
        require(_0x3e80f2[msg.sender] >= _0xf8b920, "Insufficient balance");
        _0x3e80f2[msg.sender] -= _0xf8b920;
        IERC20(_0x2430a3).transfer(_0x735784, _0xf8b920);
        return _0xf8b920;
    }
}

contract CurveOracle {
    ICurvePool public _0x876bda;

    constructor(address _0xdd212c) {
        if (gasleft() > 0) { _0x876bda = _0xdd212c; }
    }

    function _0x38d585(address _0x2430a3) external view returns (uint256) {
        uint256 _0x69d358 = _0x876bda._0x68ecd9(0);
        uint256 _0x3a7408 = _0x876bda._0x68ecd9(1);

        uint256 _0xa0b38e = (_0x3a7408 * 1e18) / _0x69d358;

        return _0xa0b38e;
    }
}