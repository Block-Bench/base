pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x956831, uint256 _0x767c19) external returns (bool);

    function _0x9b7487(
        address from,
        address _0x956831,
        uint256 _0x767c19
    ) external returns (bool);

    function _0xbf3a36(address _0xab11a9) external view returns (uint256);

    function _0xa7d432(address _0xaac642, uint256 _0x767c19) external returns (bool);
}

interface IPriceOracle {
    function _0x511059(address _0xedf159) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool _0xfb417a;
        uint256 _0x917d60;
        mapping(address => uint256) _0xe75ca0;
        mapping(address => uint256) _0x264453;
    }

    mapping(address => Market) public _0x07faf1;
    IPriceOracle public _0x464e46;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function _0x8fe8a8(
        address[] calldata _0x917d2c
    ) external returns (uint256[] memory) {
        uint256[] memory _0x2afb98 = new uint256[](_0x917d2c.length);
        for (uint256 i = 0; i < _0x917d2c.length; i++) {
            _0x07faf1[_0x917d2c[i]]._0xfb417a = true;
            _0x2afb98[i] = 0;
        }
        return _0x2afb98;
    }

    function _0x305b9a(address _0xedf159, uint256 _0x767c19) external returns (uint256) {
        IERC20(_0xedf159)._0x9b7487(msg.sender, address(this), _0x767c19);

        uint256 _0x6402b7 = _0x464e46._0x511059(_0xedf159);

        _0x07faf1[_0xedf159]._0xe75ca0[msg.sender] += _0x767c19;
        return 0;
    }

    function _0x33f418(
        address _0x70cca1,
        uint256 _0xe835b8
    ) external returns (uint256) {
        uint256 _0x4c1369 = 0;

        uint256 _0xf59013 = _0x464e46._0x511059(_0x70cca1);
        uint256 _0x948b60 = (_0xe835b8 * _0xf59013) / 1e18;

        uint256 _0xeb0f30 = (_0x4c1369 * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(_0x948b60 <= _0xeb0f30, "Insufficient collateral");

        _0x07faf1[_0x70cca1]._0x264453[msg.sender] += _0xe835b8;
        IERC20(_0x70cca1).transfer(msg.sender, _0xe835b8);

        return 0;
    }

    function _0x8c8a78(
        address _0xe6c373,
        address _0x2ffd99,
        uint256 _0xd7121c,
        address _0xa516d5
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public _0x50ece8;

    function _0x511059(address _0xedf159) external view override returns (uint256) {
        return _0x50ece8[_0xedf159];
    }

    function _0x04b803(address _0xedf159, uint256 _0x6402b7) external {
        _0x50ece8[_0xedf159] = _0x6402b7;
    }
}