// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x0da3db, uint256 _0xfb5802) external returns (bool);

    function _0x0ed7d5(
        address from,
        address _0x0da3db,
        uint256 _0xfb5802
    ) external returns (bool);

    function _0x6ce656(address _0xf5df28) external view returns (uint256);

    function _0x1740c2(address _0x437bfb, uint256 _0xfb5802) external returns (bool);
}

interface IPriceOracle {
    function _0x711060(address _0x3ed061) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool _0x159137;
        uint256 _0xadd19f;
        mapping(address => uint256) _0x84fac8;
        mapping(address => uint256) _0xd5e7b9;
    }

    mapping(address => Market) public _0x84ff46;
    IPriceOracle public _0x7d162f;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function _0x0b8b40(
        address[] calldata _0x9d7b33
    ) external returns (uint256[] memory) {
        uint256[] memory _0x293e33 = new uint256[](_0x9d7b33.length);
        for (uint256 i = 0; i < _0x9d7b33.length; i++) {
            _0x84ff46[_0x9d7b33[i]]._0x159137 = true;
            _0x293e33[i] = 0;
        }
        return _0x293e33;
    }

    function _0x70c37c(address _0x3ed061, uint256 _0xfb5802) external returns (uint256) {
        IERC20(_0x3ed061)._0x0ed7d5(msg.sender, address(this), _0xfb5802);

        uint256 _0xc358b2 = _0x7d162f._0x711060(_0x3ed061);

        _0x84ff46[_0x3ed061]._0x84fac8[msg.sender] += _0xfb5802;
        return 0;
    }

    function _0xf87221(
        address _0x22b3ca,
        uint256 _0xfd980e
    ) external returns (uint256) {
        uint256 _0x8c3d5a = 0;

        uint256 _0xae7572 = _0x7d162f._0x711060(_0x22b3ca);
        uint256 _0xcf464f = (_0xfd980e * _0xae7572) / 1e18;

        uint256 _0x6007e4 = (_0x8c3d5a * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(_0xcf464f <= _0x6007e4, "Insufficient collateral");

        _0x84ff46[_0x22b3ca]._0xd5e7b9[msg.sender] += _0xfd980e;
        IERC20(_0x22b3ca).transfer(msg.sender, _0xfd980e);

        return 0;
    }

    function _0x0a50c9(
        address _0x745516,
        address _0xc02da3,
        uint256 _0xbbb330,
        address _0x1adaf7
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public _0xc439b6;

    function _0x711060(address _0x3ed061) external view override returns (uint256) {
        return _0xc439b6[_0x3ed061];
    }

    function _0x3ffac7(address _0x3ed061, uint256 _0xc358b2) external {
        _0xc439b6[_0x3ed061] = _0xc358b2;
    }
}
