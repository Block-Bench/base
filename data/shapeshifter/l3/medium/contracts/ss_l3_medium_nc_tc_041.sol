pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xe43e0c, uint256 _0x94d8f4) external returns (bool);

    function _0x5b917e(
        address from,
        address _0xe43e0c,
        uint256 _0x94d8f4
    ) external returns (bool);

    function _0xa91593(address _0xd81d8b) external view returns (uint256);

    function _0x30a003(address _0x286d49, uint256 _0x94d8f4) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public _0x2fddca = "Shezmu Collateral Token";
    string public _0x5e5b5c = "SCT";
    uint8 public _0x5a6c2f = 18;

    mapping(address => uint256) public _0xa91593;
    mapping(address => mapping(address => uint256)) public _0xbf708b;
    uint256 public _0xe702d3;

    function _0x2de33e(address _0xe43e0c, uint256 _0x94d8f4) external {
        _0xa91593[_0xe43e0c] += _0x94d8f4;
        _0xe702d3 += _0x94d8f4;
    }

    function transfer(
        address _0xe43e0c,
        uint256 _0x94d8f4
    ) external override returns (bool) {
        require(_0xa91593[msg.sender] >= _0x94d8f4, "Insufficient balance");
        _0xa91593[msg.sender] -= _0x94d8f4;
        _0xa91593[_0xe43e0c] += _0x94d8f4;
        return true;
    }

    function _0x5b917e(
        address from,
        address _0xe43e0c,
        uint256 _0x94d8f4
    ) external override returns (bool) {
        require(_0xa91593[from] >= _0x94d8f4, "Insufficient balance");
        require(
            _0xbf708b[from][msg.sender] >= _0x94d8f4,
            "Insufficient allowance"
        );
        _0xa91593[from] -= _0x94d8f4;
        _0xa91593[_0xe43e0c] += _0x94d8f4;
        _0xbf708b[from][msg.sender] -= _0x94d8f4;
        return true;
    }

    function _0x30a003(
        address _0x286d49,
        uint256 _0x94d8f4
    ) external override returns (bool) {
        _0xbf708b[msg.sender][_0x286d49] = _0x94d8f4;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public _0xc7727a;
    IERC20 public _0x6af719;

    mapping(address => uint256) public _0x6b5ca6;
    mapping(address => uint256) public _0x2fb58c;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _0xe00e4d, address _0xeb1ecd) {
        _0xc7727a = IERC20(_0xe00e4d);
        _0x6af719 = IERC20(_0xeb1ecd);
    }

    function _0xda65b9(uint256 _0x94d8f4) external {
        _0xc7727a._0x5b917e(msg.sender, address(this), _0x94d8f4);
        _0x6b5ca6[msg.sender] += _0x94d8f4;
    }

    function _0xbb7d16(uint256 _0x94d8f4) external {
        uint256 _0xb08a6d = (_0x6b5ca6[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            _0x2fb58c[msg.sender] + _0x94d8f4 <= _0xb08a6d,
            "Insufficient collateral"
        );

        _0x2fb58c[msg.sender] += _0x94d8f4;

        _0x6af719.transfer(msg.sender, _0x94d8f4);
    }

    function _0xb20a50(uint256 _0x94d8f4) external {
        require(_0x2fb58c[msg.sender] >= _0x94d8f4, "Excessive repayment");
        _0x6af719._0x5b917e(msg.sender, address(this), _0x94d8f4);
        _0x2fb58c[msg.sender] -= _0x94d8f4;
    }

    function _0xdac9c9(uint256 _0x94d8f4) external {
        require(
            _0x6b5ca6[msg.sender] >= _0x94d8f4,
            "Insufficient collateral"
        );
        uint256 _0x8a2114 = _0x6b5ca6[msg.sender] - _0x94d8f4;
        uint256 _0x4877f1 = (_0x8a2114 * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            _0x2fb58c[msg.sender] <= _0x4877f1,
            "Would be undercollateralized"
        );

        _0x6b5ca6[msg.sender] -= _0x94d8f4;
        _0xc7727a.transfer(msg.sender, _0x94d8f4);
    }
}