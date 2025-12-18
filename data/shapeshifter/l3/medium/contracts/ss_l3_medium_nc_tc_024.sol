pragma solidity ^0.8.0;

interface IERC20 {
    function _0xa59b9c(address _0x93f93f) external view returns (uint256);

    function transfer(address _0x7f793c, uint256 _0xa14f75) external returns (bool);

    function _0xfe28b5(
        address from,
        address _0x7f793c,
        uint256 _0xa14f75
    ) external returns (bool);
}

interface ICurvePool {
    function _0x9116df() external view returns (uint256);

    function _0x257431(
        uint256[3] calldata _0xaaa65b,
        uint256 _0xaff95f
    ) external;
}

contract PriceOracle {
    ICurvePool public _0xa1ae39;

    constructor(address _0xa4c433) {
        _0xa1ae39 = ICurvePool(_0xa4c433);
    }

    function _0xb2b1d7() external view returns (uint256) {
        return _0xa1ae39._0x9116df();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 _0x9d3de5;
        uint256 _0xaf9706;
    }

    mapping(address => Position) public _0xc2308c;

    address public _0xe491cd;
    address public _0x674d9a;
    address public _0x4c4f07;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address _0x27581f,
        address _0xd4add6,
        address _0xb72716
    ) {
        _0xe491cd = _0x27581f;
        _0x674d9a = _0xd4add6;
        _0x4c4f07 = _0xb72716;
    }

    function _0x65b1f7(uint256 _0xa14f75) external {
        IERC20(_0xe491cd)._0xfe28b5(msg.sender, address(this), _0xa14f75);
        _0xc2308c[msg.sender]._0x9d3de5 += _0xa14f75;
    }

    function _0xd05ebc(uint256 _0xa14f75) external {
        uint256 _0xb068ee = _0x083824(msg.sender);
        uint256 _0xcdfb21 = (_0xb068ee * COLLATERAL_FACTOR) / 100;

        require(
            _0xc2308c[msg.sender]._0xaf9706 + _0xa14f75 <= _0xcdfb21,
            "Insufficient collateral"
        );

        _0xc2308c[msg.sender]._0xaf9706 += _0xa14f75;
        IERC20(_0x674d9a).transfer(msg.sender, _0xa14f75);
    }

    function _0x083824(address _0xc51368) public view returns (uint256) {
        uint256 _0x339012 = _0xc2308c[_0xc51368]._0x9d3de5;
        uint256 _0x05a59b = PriceOracle(_0x4c4f07)._0xb2b1d7();

        return (_0x339012 * _0x05a59b) / 1e18;
    }
}