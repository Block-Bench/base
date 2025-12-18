// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xcfc888, uint256 _0x0ce9f5) external returns (bool);

    function _0xfeddb2(
        address from,
        address _0xcfc888,
        uint256 _0x0ce9f5
    ) external returns (bool);

    function _0x6d9b58(address _0xd63d5e) external view returns (uint256);

    function _0x2aa3a8(address _0x374665, uint256 _0x0ce9f5) external returns (bool);
}

interface IPriceOracle {
    function _0xdf1238(address _0x11a577) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool _0xa107c1;
        uint256 _0x3e584f;
        mapping(address => uint256) _0x2cc301;
        mapping(address => uint256) _0x1969ff;
    }

    mapping(address => Market) public _0x166318;
    IPriceOracle public _0x1a6caf;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function _0x6d093e(
        address[] calldata _0x8bdfdd
    ) external returns (uint256[] memory) {
        uint256[] memory _0xaf1096 = new uint256[](_0x8bdfdd.length);
        for (uint256 i = 0; i < _0x8bdfdd.length; i++) {
            _0x166318[_0x8bdfdd[i]]._0xa107c1 = true;
            _0xaf1096[i] = 0;
        }
        return _0xaf1096;
    }

    function _0x7635f4(address _0x11a577, uint256 _0x0ce9f5) external returns (uint256) {
        IERC20(_0x11a577)._0xfeddb2(msg.sender, address(this), _0x0ce9f5);

        uint256 _0xe09a5d = _0x1a6caf._0xdf1238(_0x11a577);

        _0x166318[_0x11a577]._0x2cc301[msg.sender] += _0x0ce9f5;
        return 0;
    }

    function _0xaeca7b(
        address _0xf6313b,
        uint256 _0xab999b
    ) external returns (uint256) {
        uint256 _0xe015d6 = 0;

        uint256 _0x288ec9 = _0x1a6caf._0xdf1238(_0xf6313b);
        uint256 _0x23103a = (_0xab999b * _0x288ec9) / 1e18;

        uint256 _0x926769 = (_0xe015d6 * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(_0x23103a <= _0x926769, "Insufficient collateral");

        _0x166318[_0xf6313b]._0x1969ff[msg.sender] += _0xab999b;
        IERC20(_0xf6313b).transfer(msg.sender, _0xab999b);

        return 0;
    }

    function _0x2de7d2(
        address _0x7a8f29,
        address _0xfeaf95,
        uint256 _0xc30b53,
        address _0x94d89d
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public _0xae9083;

    function _0xdf1238(address _0x11a577) external view override returns (uint256) {
        return _0xae9083[_0x11a577];
    }

    function _0x71e763(address _0x11a577, uint256 _0xe09a5d) external {
        _0xae9083[_0x11a577] = _0xe09a5d;
    }
}
