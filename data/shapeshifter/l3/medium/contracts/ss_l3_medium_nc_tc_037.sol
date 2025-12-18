pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x6557aa, uint256 _0x476e7b) external returns (bool);

    function _0x30ae51(
        address from,
        address _0x6557aa,
        uint256 _0x476e7b
    ) external returns (bool);

    function _0x51c6ce(address _0x9e3952) external view returns (uint256);

    function _0x202253(address _0xbcfee4, uint256 _0x476e7b) external returns (bool);
}

interface IAaveOracle {
    function _0xa87a44(address _0xb7cb1d) external view returns (uint256);

    function _0x6d6c94(
        address[] calldata _0x538e4a,
        address[] calldata _0xd61835
    ) external;
}

interface ICurvePool {
    function _0xb88a84(
        int128 i,
        int128 j,
        uint256 _0x2ae82b,
        uint256 _0xac91d1
    ) external returns (uint256);

    function _0x14c2bc(
        int128 i,
        int128 j,
        uint256 _0x2ae82b
    ) external view returns (uint256);

    function _0xb3a7c0(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function _0x2b3bec(
        address _0xb7cb1d,
        uint256 _0x476e7b,
        address _0xbfea67,
        uint16 _0x932bce
    ) external;

    function _0x12b189(
        address _0xb7cb1d,
        uint256 _0x476e7b,
        uint256 _0x778e02,
        uint16 _0x932bce,
        address _0xbfea67
    ) external;

    function _0xce304e(
        address _0xb7cb1d,
        uint256 _0x476e7b,
        address _0x6557aa
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public _0x2adfaf;
    mapping(address => uint256) public _0xae4b45;
    mapping(address => uint256) public _0x56a282;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function _0x2b3bec(
        address _0xb7cb1d,
        uint256 _0x476e7b,
        address _0xbfea67,
        uint16 _0x932bce
    ) external override {
        IERC20(_0xb7cb1d)._0x30ae51(msg.sender, address(this), _0x476e7b);
        _0xae4b45[_0xbfea67] += _0x476e7b;
    }

    function _0x12b189(
        address _0xb7cb1d,
        uint256 _0x476e7b,
        uint256 _0x778e02,
        uint16 _0x932bce,
        address _0xbfea67
    ) external override {
        uint256 _0x37c312 = _0x2adfaf._0xa87a44(msg.sender);
        uint256 _0xb8026b = _0x2adfaf._0xa87a44(_0xb7cb1d);

        uint256 _0xab9bd8 = (_0xae4b45[msg.sender] * _0x37c312) /
            1e18;
        uint256 _0x38f92f = (_0xab9bd8 * LTV) / BASIS_POINTS;

        uint256 _0x788c6c = (_0x476e7b * _0xb8026b) / 1e18;

        require(_0x788c6c <= _0x38f92f, "Insufficient collateral");

        _0x56a282[msg.sender] += _0x476e7b;
        IERC20(_0xb7cb1d).transfer(_0xbfea67, _0x476e7b);
    }

    function _0xce304e(
        address _0xb7cb1d,
        uint256 _0x476e7b,
        address _0x6557aa
    ) external override returns (uint256) {
        require(_0xae4b45[msg.sender] >= _0x476e7b, "Insufficient balance");
        _0xae4b45[msg.sender] -= _0x476e7b;
        IERC20(_0xb7cb1d).transfer(_0x6557aa, _0x476e7b);
        return _0x476e7b;
    }
}

contract CurveOracle {
    ICurvePool public _0xe60f47;

    constructor(address _0x037c99) {
        if (block.timestamp > 0) { _0xe60f47 = _0x037c99; }
    }

    function _0xa87a44(address _0xb7cb1d) external view returns (uint256) {
        uint256 _0xcd75ae = _0xe60f47._0xb3a7c0(0);
        uint256 _0xd27b28 = _0xe60f47._0xb3a7c0(1);

        uint256 _0x0213b2 = (_0xd27b28 * 1e18) / _0xcd75ae;

        return _0x0213b2;
    }
}