pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xb8bf49, uint256 _0x8ae3e4) external returns (bool);

    function _0x96a256(
        address from,
        address _0xb8bf49,
        uint256 _0x8ae3e4
    ) external returns (bool);

    function _0xe085ea(address _0x0e13c3) external view returns (uint256);

    function _0xf896c2(address _0x19eaed, uint256 _0x8ae3e4) external returns (bool);
}

interface IPriceOracle {
    function _0xdb9c99(address _0x10ffd3) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool _0xb8ab21;
        uint256 _0xdcee47;
        mapping(address => uint256) _0xa52878;
        mapping(address => uint256) _0xdbe55c;
    }

    mapping(address => Market) public _0x8d07e5;
    IPriceOracle public _0x89c216;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function _0x167684(
        address[] calldata _0x51e36c
    ) external returns (uint256[] memory) {
        uint256[] memory _0x8beafa = new uint256[](_0x51e36c.length);
        for (uint256 i = 0; i < _0x51e36c.length; i++) {
            _0x8d07e5[_0x51e36c[i]]._0xb8ab21 = true;
            _0x8beafa[i] = 0;
        }
        return _0x8beafa;
    }

    function _0xc928e2(address _0x10ffd3, uint256 _0x8ae3e4) external returns (uint256) {
        IERC20(_0x10ffd3)._0x96a256(msg.sender, address(this), _0x8ae3e4);

        uint256 _0xc4b7f4 = _0x89c216._0xdb9c99(_0x10ffd3);

        _0x8d07e5[_0x10ffd3]._0xa52878[msg.sender] += _0x8ae3e4;
        return 0;
    }

    function _0x91038e(
        address _0x65b837,
        uint256 _0x206d87
    ) external returns (uint256) {
        uint256 _0x948507 = 0;

        uint256 _0x478cb8 = _0x89c216._0xdb9c99(_0x65b837);
        uint256 _0x519a3a = (_0x206d87 * _0x478cb8) / 1e18;

        uint256 _0x23ed4f = (_0x948507 * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(_0x519a3a <= _0x23ed4f, "Insufficient collateral");

        _0x8d07e5[_0x65b837]._0xdbe55c[msg.sender] += _0x206d87;
        IERC20(_0x65b837).transfer(msg.sender, _0x206d87);

        return 0;
    }

    function _0xceff45(
        address _0x852ffc,
        address _0x8368d9,
        uint256 _0x96b36a,
        address _0x9324e8
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public _0x6161f0;

    function _0xdb9c99(address _0x10ffd3) external view override returns (uint256) {
        return _0x6161f0[_0x10ffd3];
    }

    function _0xaee776(address _0x10ffd3, uint256 _0xc4b7f4) external {
        _0x6161f0[_0x10ffd3] = _0xc4b7f4;
    }
}