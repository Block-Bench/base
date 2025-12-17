// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x4ae5f1, uint256 _0xfe4855) external returns (bool);

    function _0xfd9a2e(
        address from,
        address _0x4ae5f1,
        uint256 _0xfe4855
    ) external returns (bool);

    function _0x9f0eef(address _0x4082c8) external view returns (uint256);

    function _0xa17bdf(address _0x5f273e, uint256 _0xfe4855) external returns (bool);
}

interface IPriceOracle {
    function _0xe78efd(address _0x93070b) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool _0x10fcbf;
        uint256 _0xb2dd20;
        mapping(address => uint256) _0xef50b3;
        mapping(address => uint256) _0x7e6408;
    }

    mapping(address => Market) public _0x471c45;
    IPriceOracle public _0xc29940;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function _0xff0c17(
        address[] calldata _0xa56717
    ) external returns (uint256[] memory) {
        uint256[] memory _0x1acf14 = new uint256[](_0xa56717.length);
        for (uint256 i = 0; i < _0xa56717.length; i++) {
            _0x471c45[_0xa56717[i]]._0x10fcbf = true;
            _0x1acf14[i] = 0;
        }
        return _0x1acf14;
    }

    function _0xbcd73c(address _0x93070b, uint256 _0xfe4855) external returns (uint256) {
        IERC20(_0x93070b)._0xfd9a2e(msg.sender, address(this), _0xfe4855);

        uint256 _0x27964a = _0xc29940._0xe78efd(_0x93070b);

        _0x471c45[_0x93070b]._0xef50b3[msg.sender] += _0xfe4855;
        return 0;
    }

    function _0x9fae3e(
        address _0xe4d25c,
        uint256 _0x278cac
    ) external returns (uint256) {
        uint256 _0xb95599 = 0;

        uint256 _0xc9b8ed = _0xc29940._0xe78efd(_0xe4d25c);
        uint256 _0x5b9091 = (_0x278cac * _0xc9b8ed) / 1e18;

        uint256 _0xa9f26e = (_0xb95599 * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(_0x5b9091 <= _0xa9f26e, "Insufficient collateral");

        _0x471c45[_0xe4d25c]._0x7e6408[msg.sender] += _0x278cac;
        IERC20(_0xe4d25c).transfer(msg.sender, _0x278cac);

        return 0;
    }

    function _0xf533b2(
        address _0x29dbe3,
        address _0x3dc47a,
        uint256 _0xa3153e,
        address _0x262810
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public _0x99174a;

    function _0xe78efd(address _0x93070b) external view override returns (uint256) {
        return _0x99174a[_0x93070b];
    }

    function _0xd8b756(address _0x93070b, uint256 _0x27964a) external {
        _0x99174a[_0x93070b] = _0x27964a;
    }
}
