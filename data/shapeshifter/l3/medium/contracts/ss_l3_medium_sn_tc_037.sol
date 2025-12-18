// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x98acf9, uint256 _0xcd6ccc) external returns (bool);

    function _0x174548(
        address from,
        address _0x98acf9,
        uint256 _0xcd6ccc
    ) external returns (bool);

    function _0xe77856(address _0xccc14d) external view returns (uint256);

    function _0xcd5c94(address _0x67aa71, uint256 _0xcd6ccc) external returns (bool);
}

interface IAaveOracle {
    function _0xd0e183(address _0x8f34a6) external view returns (uint256);

    function _0xea7461(
        address[] calldata _0xf3ec1f,
        address[] calldata _0x462db1
    ) external;
}

interface ICurvePool {
    function _0x63baf1(
        int128 i,
        int128 j,
        uint256 _0x1a7638,
        uint256 _0xfceb39
    ) external returns (uint256);

    function _0x7a5acd(
        int128 i,
        int128 j,
        uint256 _0x1a7638
    ) external view returns (uint256);

    function _0x49d5c9(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function _0xc0c495(
        address _0x8f34a6,
        uint256 _0xcd6ccc,
        address _0xe93b04,
        uint16 _0xb5e44e
    ) external;

    function _0xc02deb(
        address _0x8f34a6,
        uint256 _0xcd6ccc,
        uint256 _0xfb1247,
        uint16 _0xb5e44e,
        address _0xe93b04
    ) external;

    function _0x67333f(
        address _0x8f34a6,
        uint256 _0xcd6ccc,
        address _0x98acf9
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public _0xeabb1b;
    mapping(address => uint256) public _0xf08151;
    mapping(address => uint256) public _0x074833;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function _0xc0c495(
        address _0x8f34a6,
        uint256 _0xcd6ccc,
        address _0xe93b04,
        uint16 _0xb5e44e
    ) external override {
        IERC20(_0x8f34a6)._0x174548(msg.sender, address(this), _0xcd6ccc);
        _0xf08151[_0xe93b04] += _0xcd6ccc;
    }

    function _0xc02deb(
        address _0x8f34a6,
        uint256 _0xcd6ccc,
        uint256 _0xfb1247,
        uint16 _0xb5e44e,
        address _0xe93b04
    ) external override {
        uint256 _0x8661e1 = _0xeabb1b._0xd0e183(msg.sender);
        uint256 _0xfc3581 = _0xeabb1b._0xd0e183(_0x8f34a6);

        uint256 _0x5cf622 = (_0xf08151[msg.sender] * _0x8661e1) /
            1e18;
        uint256 _0xdcebce = (_0x5cf622 * LTV) / BASIS_POINTS;

        uint256 _0xccb202 = (_0xcd6ccc * _0xfc3581) / 1e18;

        require(_0xccb202 <= _0xdcebce, "Insufficient collateral");

        _0x074833[msg.sender] += _0xcd6ccc;
        IERC20(_0x8f34a6).transfer(_0xe93b04, _0xcd6ccc);
    }

    function _0x67333f(
        address _0x8f34a6,
        uint256 _0xcd6ccc,
        address _0x98acf9
    ) external override returns (uint256) {
        require(_0xf08151[msg.sender] >= _0xcd6ccc, "Insufficient balance");
        _0xf08151[msg.sender] -= _0xcd6ccc;
        IERC20(_0x8f34a6).transfer(_0x98acf9, _0xcd6ccc);
        return _0xcd6ccc;
    }
}

contract CurveOracle {
    ICurvePool public _0x3f4998;

    constructor(address _0x19b5b3) {
        if (1 == 1) { _0x3f4998 = _0x19b5b3; }
    }

    function _0xd0e183(address _0x8f34a6) external view returns (uint256) {
        uint256 _0xfe8f67 = _0x3f4998._0x49d5c9(0);
        uint256 _0x650da3 = _0x3f4998._0x49d5c9(1);

        uint256 _0x8fb570 = (_0x650da3 * 1e18) / _0xfe8f67;

        return _0x8fb570;
    }
}
