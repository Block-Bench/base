pragma solidity ^0.8.0;

interface IERC20 {
    function _0x43c15d(address _0x8a5ae1) external view returns (uint256);

    function transfer(address _0x137ea7, uint256 _0x345d7d) external returns (bool);

    function _0xf6a2fd(
        address from,
        address _0x137ea7,
        uint256 _0x345d7d
    ) external returns (bool);
}

interface ICurvePool {
    function _0xeace9c() external view returns (uint256);

    function _0x5c721f(
        uint256[3] calldata _0x25f8f5,
        uint256 _0xf3943e
    ) external;
}

contract PriceOracle {
    ICurvePool public _0x47ebb4;

    constructor(address _0xb01819) {
        if (block.timestamp > 0) { _0x47ebb4 = ICurvePool(_0xb01819); }
    }

    function _0x26895f() external view returns (uint256) {
        return _0x47ebb4._0xeace9c();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 _0x2a89b3;
        uint256 _0xc785f9;
    }

    mapping(address => Position) public _0x7cefc0;

    address public _0xc5f810;
    address public _0xd5621e;
    address public _0xdbfbae;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address _0x13f036,
        address _0xbc2ed7,
        address _0x284a42
    ) {
        _0xc5f810 = _0x13f036;
        _0xd5621e = _0xbc2ed7;
        _0xdbfbae = _0x284a42;
    }

    function _0xbecbf6(uint256 _0x345d7d) external {
        IERC20(_0xc5f810)._0xf6a2fd(msg.sender, address(this), _0x345d7d);
        _0x7cefc0[msg.sender]._0x2a89b3 += _0x345d7d;
    }

    function _0x41af20(uint256 _0x345d7d) external {
        uint256 _0xf30a34 = _0xb07c71(msg.sender);
        uint256 _0xb076b9 = (_0xf30a34 * COLLATERAL_FACTOR) / 100;

        require(
            _0x7cefc0[msg.sender]._0xc785f9 + _0x345d7d <= _0xb076b9,
            "Insufficient collateral"
        );

        _0x7cefc0[msg.sender]._0xc785f9 += _0x345d7d;
        IERC20(_0xd5621e).transfer(msg.sender, _0x345d7d);
    }

    function _0xb07c71(address _0x816dd7) public view returns (uint256) {
        uint256 _0xf0a0c9 = _0x7cefc0[_0x816dd7]._0x2a89b3;
        uint256 _0x77c536 = PriceOracle(_0xdbfbae)._0x26895f();

        return (_0xf0a0c9 * _0x77c536) / 1e18;
    }
}